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
addpath('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts/ImagePrep');

imagepathstem = [imgdir '/' sprintf('%2d',subject) '/' dateID];

cd(imagepathstem);
fprintf(['\n STARTING image preparation for subject ' sprintf('%2d',subject) ' ... \n']);
pwd

% uncomment if running for first time
% if isfolder('mp2rage')
%     warning('mp2rage dir already exits! Overwriting files');
%     cd mp2rage
%     delete *.nii.gz
%     delete *.txt
%     cd ..
% else
%     mkdir('mp2rage');
%     fprintf('\n Made mp2rage dir. \n');
% end


% Need to convert MP2RAGE, T2, all EPIs (run 1 INV, run 1, run 2, run3 - not physio for now)
% list series names here
seriesvec={'t2_tse_tra_fast_for_reporting'};
%'b1_mapping_2mm','gre_b0map_more_slices'};
%'MP2RAGE_0.7_UniformSens_MAG',...
% 'MP2RAGE_0.7_UniformSens_PHS',...
%'Highresolution_TSE_PAT2_100',...
%'cmrr_ep2d_bold_1.5x1.5x1_run1',...
%'cmrr_ep2d_bold_1.5x1.5x1_run1_inv',...
%'cmrr_ep2d_bold_1.5x1.5x1_run2',...
%'cmrr_ep2d_bold_1.5x1.5x1_run3'};


%% Function start

% loop through series (order depends on seriesvec order above)
for i = 1:length(seriesvec)
    
    fprintf('\nSTARTING NEW SERIES');
    series = seriesvec{i};
    d = dir([imagepathstem '/Series_*_' sprintf(series)]);
    fprintf(['\n ' d(1).folder '/' d(1).name '\n']);
    
    % check folder for series exists
    if ~isfolder([d(1).folder '/' d(1).name])
        error(['Cannot find the folder for ' sprintf('%2d', subject) ': ' series ', check the folder! ']);
    else
        cd([imagepathstem '/' d(1).name]);
    end
    
    % delete pre-existing niftis to prevent interference
    if ~isempty(dir('*.nii'))
        ls *.nii
        warning('NII already exists! Overwriting');
        delete *.nii
        delete *.json
        
        % for special case of topup subdir with niftis in main EPI run folders
        if isfolder('topup_PosBlip')
            fprintf('Removing existing topup pos blips');
            cd topup_PosBlip
            delete *.nii
            delete *.dcm
            delete *.json
            cd ..
        end
        
    end
    
    %% DCM2NIIX
    
    cmd = 'dcm2niix -f %f *.dcm';
    [status,cmdout] = system(cmd);
    disp('Converting dicoms to nifti...');
    
    if status == 0
        disp('Done dcm2niix.');
        outnii = dir('*.nii');
        outjson = dir('*.json');       
    else
        warning(['dcm2niix issue for ' sprintf('%2d',subject) ' - check ' d(1).name 'files']);
        fileid = fopen(['dcm2niixout_' d(1).name '.txt'],'w');
        fprintf(fileid,cmdout);
        fclose(fileid);
    end
    
    %% Rename T2
    if contains(d(1).name,'Highresolution_TSE_PAT2_100')
        movefile(outnii.name,'t2.nii');
        movefile(outjson.name,'t2.json');
    end
        
    %% Make reference EPI blips for topup and prepare EPI runs
    
    if contains(d(1).name,'cmrr_ep2d_bold_1.5x1.5x1')
        
        if contains(d(1).name,'inv')
            
            % negative (inverse) blip
            fprintf('\n EPIs: creating neg blip for topup \n');
            cmd = ['fslmaths ' outnii.name ' -Tmean neg_topup'];
            [status,~] = system(cmd);
            if status == 0
                disp('** Neg topup done **');
                delete(outnii.name);
                movefile(outjson.name,'neg_topup.json');
            else
                warning('neg topup issue');
            end            
            
        else
            
            % positive blip
            fprintf('\n EPIs: creating pos blip for topup \n');
            
            if ~isfolder('topup_PosBlip')
                mkdir('topup_PosBlip');
            end
            
            cd topup_PosBlip
            copyfile('../DATA_*_00001.dcm');
            copyfile('../DATA_*_00002.dcm');
            copyfile('../DATA_*_00003.dcm');
            copyfile('../DATA_*_00004.dcm');
            copyfile('../DATA_*_00005.dcm');
            cmd = 'dcm2niix -f pos_topup_first5 *.dcm';
            system(cmd);
            postopupnii = dir('*.nii');
            postopupjson = dir('*.json');
            cmd2 = ['fslmaths ' postopupnii.name ' -Tmean pos_topup'];
            [status,~] = system(cmd2);
            
            if status == 0
                disp('** pos topup done **');
                movefile(postopupjson.name,'pos_topup.json');
                delete(postopupnii.name);
            else
                warning('pos topup issue');
            end

            
            cd([imagepathstem '/' d(1).name]);
            
            % rename .nii of each functional run X to runX
            if contains(d(1).name, 'run1')
                movefile(outnii.name,'run1.nii');
                movefile(outjson.name,'run1.json');
            elseif contains(d(1).name, 'run2')
                movefile(outnii.name,'run2.nii');
                movefile(outjson.name,'run2.json');
            elseif contains(d(1).name, 'run3')
                movefile(outnii.name,'run3.nii');
                movefile(outjson.name,'run3.json');
            end
            
            disp('EPI prep complete.');
            
        end
    end
    
    cd(imagepathstem);
    
    %% Prepare mp2rage inputs
    
    if contains(d(1).name,'MP2RAGE')
        
        % magnitude image
        if contains(d(1).name, 'MAG')
            
            fprintf('\n\n Now working on mp2rage MAG prep...');
            cd mp2rage
            pwd
            disp('Inside mp2rage dir, copying images...');
            mag = dir([imagepathstem,'/Series_*_MP2RAGE_0.7_UniformSens_MAG']);
            disp(['Magnitude image going in is ' mag.name]);
            
            
            cmd = ['cp ../' mag.name '/' outnii.name ' mp2rage_magnitude.nii.gz'];
            [status,cmdout] = system(cmd);
            
            if status == 0
                disp('Done with magnitude image.');
            else
                warning(['Image transfer for ' mag.name ' unsuccessful']);
                fileid = fopen(['imtransfer_' mag.name '.txt'],'w');
                fprintf(fileid,cmdout);
                fclose(fileid);
            end
            
            cd(imagepathstem)
            
        end % of mag
        
        % phase image
        if contains(d(1).name,'PHS')
            
            fprintf('\n\n Now working on mp2rage PHS prep...');
            cd mp2rage
            pwd
            disp('Inside mp2rage dir, copying images...');
            phs = dir([imagepathstem,'/Series_*_MP2RAGE_0.7_UniformSens_PHS']);
            disp(['Phase image going in is ' phs.name]);
            
            cmd = ['cp ../' phs.name '/' outnii.name ' mp2rage_phase.nii.gz'];
            [status,cmdout] = system(cmd);
            
            if status == 0
                disp('Done with phase image.');
            else
                warning(['Image transfer for ' phs.name ' unsuccessful']);
                fileid = fopen(['imtransfer_' phs.name '.txt'],'w');
                fprintf(fileid,cmdout);
                fclose(fileid);
            end
            
            cd(imagepathstem)
            
        end %of phase
        
    end % of if MP2RAGE loop
    
end %of series vec loop

fprintf(['\n FINISHED image preparation for subject ' sprintf('%2d',subject) '\n']);

end %of function








