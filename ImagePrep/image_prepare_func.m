function image_prepare_func(rawimgdir,outimgdir,subject)

%  Coco Newton 27.08.19
% update for ENCRYPT 22.09.20
% update 2 for ENCRYPT 31.08.21

% function to:
% 1. iterate through rawimgdir HPHI downloaded DICOM files (in seriesvec) and convert to nifti with dcm2niix
% 2. create topup pos and neg blips in topup subdir of EPI run dirs
% 3. prepare mp2rage input files by moving to mp2rage dir and renaming
% 4. in parallel copy needed images to output image dir

% subject must be a double not a str

%% Preamble

fsldir='/usr/local/software/fsl/6.0.4/bin'; % switching from 5.0.10 - not installed on HPC

setenv('FSL_DIR',fsldir);  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI'); % this to tell what the output type
setenv('FSF_OUTPUT_FORMAT', 'nii'); % this to tell what the output type
addpath('/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/scripts/ImagePrep');

% make image paths
% RAW - get UID folder name and add subject
cd([rawimgdir '/' sprintf('%2d',subject)]);
dateUID = strtrim(ls());
rawimagepath = fullfile(rawimgdir,sprintf('%2d',subject),dateUID);
% OUTPUT - add subject
outimagepath = fullfile(outimgdir,sprintf('%2d',subject));

cd(rawimagepath);

% check if output folders exist
if isfolder('mp2rage')
    warning('mp2rage dir already exits! Overwriting files');
    cd mp2rage
    delete *.nii.gz
    delete *.txt
    cd ..
else
    mkdir('mp2rage');
    fprintf('\n Made mp2rage dir. \n');
end

if ~exist(outimagepath,'dir')
    mkdir(outimagepath);
    cd(outimagepath)
    mkdir('T2');
    mkdir('fMRI');
    cd(rawimagepath);
else
    warning('Out image dir already exists! Overwriting files')
    cd(outimagepath)
    rmdir *
    delete *.nii
    delete *.nii.gz
    delete *.json
    cd(rawimagepath);
end

% Need to convert MP2RAGE, T2, all EPIs (run 1 INV, run 1, run 2, run3 - not physio for now)
% list series names here
seriesvec={'MP2RAGE_0.7_UniformSens_MAG',...
'MP2RAGE_0.7_UniformSens_PHS',...
'Highresolution_TSE_PAT2_100',...
'cmrr_ep2d_bold_1.5x1.5x1_run1',...
'cmrr_ep2d_bold_1.5x1.5x1_run1_inv',...
'cmrr_ep2d_bold_1.5x1.5x1_run2',...
'cmrr_ep2d_bold_1.5x1.5x1_run3'};


%% Function start

fprintf(['\nStarting image preparation for subject ' sprintf('%2d',subject) ' ... ']);
fprintf(['Current dir is ' pwd '\n']);

% loop through series (order depends on seriesvec order above)
for i = 1:length(seriesvec)
    
    fprintf('\n**STARTING NEW SERIES**');
    
    series = seriesvec{i};
    d = dir([rawimagepath '/Series_*_' sprintf(series)]);
    
    % check folder for series exists or if duplicates present due to repeat scans
    if ~isfolder([d(1).folder '/' d(1).name])
        error(['Folder missing for ' sprintf('%2d', subject) ': ' series ' ']);
    elseif length(d) > 1
        warning(['Repeat scan for ' sprintf('%2d', subject) ': ' d(1).name ' and ' d(2).name]);
        if length(d) > 2
            error(['More than 2 folders found for ' sprintf('%2d', subject) ': ' series ' ']);
        end
        disp(['Taking most recent version: ' d(2).name]); % assume chronological order
        d(1) = []; % delete first series folder so d(2) becomes d(1)
        fprintf(['\n ' d(1).folder '/' d(1).name '\n']);
        cd([rawimagepath '/' d(1).name]);
    else
        fprintf(['\n ' d(1).folder '/' d(1).name '\n']);
        cd([rawimagepath '/' d(1).name]);
    end
    
    % delete pre-existing niftis to prevent interference
    if ~isempty(dir('*.nii'))
        ls *.nii
        warning('NII already exists! Overwriting');
        delete *.nii
        delete *.json
    end
    
    % for special case of topup subdir with niftis in main EPI run folders
    if isfolder('topup_PosBlip')
        fprintf('Removing existing topup pos blips');
        cd topup_PosBlip
        delete *.nii
        delete *.dcm
        delete *.json
        cd ..
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
        movefile(outnii.name,[outimagepath '/T2/t2.nii']);
        movefile(outjson.name,[outimagepath,'/T2/t2.json']);
	disp('Renamed and moved t2.nii');
    end
        
    %% Make reference EPI blips from run 1 for topup
    
    if contains(d(1).name,'cmrr_ep2d_bold_1.5x1.5x1_run1')
        
        if contains(d(1).name,'inv')
            
            % negative (inverse) blip
            fprintf('\n EPIs: creating neg blip for topup \n');
            cmd = ['fslmaths ' outnii.name ' -Tmean neg_topup'];
            [status,~] = system(cmd);
            if status == 0
                disp('** Neg topup done **');
                delete(outnii.name);
                movefile(outjson.name,[outimagepath '/fMRI/neg_topup.json']);
                movefile('neg_topup.nii',[outimagepath '/fMRI/neg_topup.nii']);
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
                movefile('pos_topup.nii',[outimagepath '/fMRI/pos_topup.nii']);
                movefile(postopupjson.name,[outimagepath '/fMRI/pos_topup.json']);
                delete(postopupnii.name);
            else
                warning('pos topup issue');
            end 
            
        end % of inv blip inner loop
    end % of blip loop
    
    %% Rename .nii of each functional run X to runX
    
    if contains(d(1).name,'cmrr_ep2d_bold_1.5x1.5x1')
        
        cd([rawimagepath '/' d(1).name]);
        
        if contains(d(1).name, 'run1') && ~contains(d(1).name, 'inv')
            movefile(outnii.name,[outimagepath '/fMRI/run1.nii']);
            movefile(outjson.name,[outimagepath '/fMRI/run1.json']);
            disp('EPI prep complete.');
        elseif contains(d(1).name, 'run2')
            movefile(outnii.name,[outimagepath '/fMRI/run2.nii']);
            movefile(outjson.name,[outimagepath '/fMRI/run2.json']);
            disp('EPI prep complete.');
        elseif contains(d(1).name, 'run3')
            movefile(outnii.name,[outimagepath '/fMRI/run3.nii']);
            movefile(outjson.name,[outimagepath '/fMRI/run3.json']);
            disp('EPI prep complete.');
        end
        
    end
    
    cd(rawimagepath);
    
    %% Prepare mp2rage inputs
    
    if contains(d(1).name,'MP2RAGE')
        
        % magnitude image
        if contains(d(1).name, 'MAG')
            
            fprintf('\n\n Now working on mp2rage MAG prep...');
            cd mp2rage
            disp('Inside mp2rage dir, copying images...');
            mag = d(1);
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
            
            cd(rawimagepath)
            
        end % of mag
        
        % phase image
        if contains(d(1).name,'PHS')
            
            fprintf('\n\n Now working on mp2rage PHS prep...');
            cd mp2rage
            disp('Inside mp2rage dir, copying images...');
            phs = d(1);
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
            
            cd(rawimagepath)
            
        end %of phase
        
    end % of if MP2RAGE loop
    
end %of series vec loop

% copy mp2rage dir to outimgdir
cd(rawimagepath)
cmd = ['cp -R mp2rage ' outimagepath '/mp2rage'];
[status,cmdout] = system(cmd);

if status == 0
    fprintf(['\n FINISHED image preparation for subject ' sprintf('%2d',subject) '\n']);
else
    warning(['mp2rage transfer for ' sprintf('%2d',subject) ' unsuccessful']);
end

end %of function








