function image_prepare_func(imgdir,subject,dateID)

%  Coco Newton 27.08.19, update for ENCRYPT 22.09.20
% function to:
% 1. iterate through HPHI downloaded DICOM files (in seriesvec) and convert to nifti with dcm2niix
% 2. create topup pos and neg blips in topup subdir of EPI run dirs
% 3. prepare mp2rage input files by moving to mp2rage dir and renaming

% need to add code that see's if more than one T2 present, or manually go
% through - make notes of which participants have extra files and delete
% them manually

%% Preamble
fsldir='/applications/fsl/fsl-5.0.10/bin/';

setenv('FSL_DIR',fsldir);  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI'); % this to tell what the output type
setenv('FSF_OUTPUT_FORMAT', 'nii'); % this to tell what the output type

imagepathstem = [imgdir '/' sprintf('%2d',subject) '/' dateID];

cd(imagepathstem);
fprintf(['\n STARTING image preparation for subject ' sprintf('%2d',subject) ' ... \n']);
pwd;

if isfolder('mp2rage')
    warning('mp2rage dir already exits!');
else
    mkdir('mp2rage');
    fprintf('\n Made mp2rage dir. \n');
end

% Need to convert MP2RAGE, T2, all EPIs (run 1 INV, run 1, run 2, run3 - not physio for now)
seriesvec={'MP2RAGE_0.7_UniformSens_MAG',...
    'MP2RAGE_0.7_UniformSens_PHS',...
    'Highresolution_TSE_PAT2_100',...
    'cmrr_ep2d_bold_1.5x1.5x1_run1_inv',...
    'cmrr_ep2d_bold_1.5x1.5x1_run1',...
    'cmrr_ep2d_bold_1.5x1.5x1_run2',...
    'cmrr_ep2d_bold_1.5x1.5x1_run3'};

%% Function start

% loop through series (order depends on seriesvec order above)
for i = 1:length(seriesvec)
    
    series = seriesvec{i};
    d = dir([imagepathstem '/Series_*_' sprintf(series)]);
    
    if ~isfolder([d.folder '/' d.name])
        error(['Cannot find the folder for ' sprintf('%2d', subject) ': ' series ', check the folder! ']);
    else
        cd([imagepathstem '/' d.name]);
        fprintf(['\n Moving to... ' d.name '\n']);
    end
    
    %% DCM2NIIX
    
    if ~isempty(dir('*.nii'))
        warning('NII already exists! Overwriting');
        delete *.nii
        delete *.json
    end
       
    cmd = 'dcm2niix -f %f *.dcm';
    [status,cmdout] = system(cmd);
    disp('Converting dicoms to nifti...');
    
    if status == 0
        disp('Done dcm2niix.');
        outnii = dir('*.nii');
        outjson = dir('*.json');
        
%         if ~isempty(dir('*_c32.*'))
%             disp('Removing _c32 suffix...');
%             nifti = dir('*_c32.nii');
%             json = dir('*_c32.json');
%             movefile(nifti.name,[d.name '.nii']);
%             movefile(json.name,[d.name '.json']);
%             disp('Done.');
%         end
        
    else
        warning(['dcm2niix issue for ' sprintf('%2d',subject) ' - check ' d.name 'files']);
        fileid = fopen(['dcm2niixout_' d.name '.txt'],'w');
        fprintf(fileid,cmdout);
        fclose(fileid);
    end
    
    
    
    %% Make reference EPI blips for topup and prepare EPI runs
    
    if contains(d.name,'cmrr_ep2d_bold_1.5x1.5x1')
        
        if contains(d.name,'inv')
            
            % negative (inverse) blip
            fprintf('\n EPIs: creating neg blip for topup \n');
            cmd = ['fslmaths ' outnii.name ' -Tmean neg_topup'];
            [status,~] = system(cmd);
            if status ~= 0
                disp('** Neg topup done **');
            else
                warning('neg topup issue');
            end
            movefile([d.name '.json'],'neg_topup.json');
            
        else
            
            % positive blip
            fprintf('\n EPIs: creating pos blip for topup \n');
            mkdir('topup_PosBlip');
            cd topup_PosBlip
            copyfile('../DATA_*_00001.dcm');
            copyfile('../DATA_*_00002.dcm');
            copyfile('../DATA_*_00003.dcm');
            copyfile('../DATA_*_00004.dcm');
            copyfile('../DATA_*_00005.dcm');
            cmd = 'dcm2niix -f pos_topup_first5 *.dcm';
            system(cmd);
            cmd2 = 'fslmaths pos_topup_first5_c32 -Tmean pos_topup';
            [status,~] = system(cmd2);
            
            if status ~= 0
                disp('** pos topup done **');
                delete('pos_topup_first5.nii')
                delete('pos_topup_first5.json')
            else
                warning('pos topup issue');
            end
            
            cd([imagepathstem '/' d.name]);
            
            % rename .nii of each functional run X to runX
            if contains(d.name, 'run1')
                movefile([d.name '.nii'],'run1.nii');
            elseif contains(d.name, 'run2')
                movefile([d.name '.nii'],'run2.nii');
            elseif contains(d.name, 'run3')
                movefile([d.name '.nii'],'run3.nii');
            end
            disp('EPI prep complete.');
            
        end
    end
    
    cd(imagepathstem);
    
    %% Prepare mp2rage inputs
    
    if contains(d.name,'MP2RAGE_0.7_UniformSens')
        
        fprintf('\n\n Now working on mp2rage prep...');
        
        cd mp2rage
        pwd;
        disp('Inside mp2rage dir, copying images...');
        mag = dir([imagepathstem,'/Series_*_MP2RAGE_0.7_UniformSens_MAG']);
        disp(['Magnitude image going in is ' mag.name]);
        phs = dir([imagepathstem,'/Series_*_MP2RAGE_0.7_UniformSens_PHS']);
        disp(['Phase image going in is ' phs.name]);
        
        % magnitude image
        cmd = ['cp ../' mag.name '/' mag.name '.nii mp2rage_magnitude.nii.gz'];
        [status,cmdout] = system(cmd);
        
        if status == 0
            disp('Done with magnitude image.');
        else
            warning(['Image transfer for ' mag.name ' unsuccessful']);
            fileid = fopen(['imtransfer_' mag.name '.txt'],'w');
            fprintf(fileid,cmdout);
            fclose(fileid);
        end
        
        % phase image
        cmd = ['cp ../' phs.name '/' phs.name '.nii mp2rage_phase.nii.gz'];
        [status,cmdout] = system(cmd);
        
        if status == 0
            disp('Done with phase image.');
        else
            warning(['Image transfer for ' phs.name ' unsuccessful']);
            fileid = fopen(['imtransfer_' phs.name '.txt'],'w');
            fprintf(fileid,cmdout);
            fclose(fileid);
        end
        
    end % of if MP2RAGE loop

end %of series vec loop

fprintf(['\n FINISHED image preparation for subject ' sprintf('%2d',subject) '\n']);

end %of function








