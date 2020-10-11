function ENCRYPT_preprocess_mainfunc_7T(step,prevStep,clusterid,preprocessedpathstem,rawpathstem,subjects,subjcnt,fullid,basedir,blocksin,blocksin_folders,blocksout,minvols,group)
% A mainfunction for preprocessing 7T MRI data
% Designed to run in a modular fashion and in parallel - i.e. pass this
% function a single step and single subject number
% for example:
% Preprocessing_mainfunction_7T('SPM_uni','smooth8','HPC',preprocessedpathstem,rawpathstem,subjects,6,fullid,basedir,blocksin,blocksin_folders,blocksout,minvols,dates,group)
% inherited from Thomas Cope by Coco Newton 8.05.19
% edited for ENCRYPT grid cell data

%% Work out which file we're looking to work on now

%rawpathstem ='/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/raw_data/images';
%preprocessedpathstem = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/preprocessed_data/images';
%ENCRYPT_preprocess_mainfunc_7T('realign','topup','HPHI',preprocessedpathstem,rawpathstem,subjects,1,fullid,basedir,blocksin,blocksin_folders,blocksout,minvols,dates,group)

switch prevStep
    % Here you specify the filenames that you search for after each step.
    case 'raw'
        
        fprintf([ '\n\nCurrent subject = ' subjects{subjcnt} '...\n\n' ]);
        % make output directory if it doesn't exist
        outputfolderpath = [preprocessedpathstem '/' subjects{subjcnt}];
        if ~exist(outputfolderpath,'dir')
            mkdir(outputfolderpath);
        end
        
        % change to input directory
        for i = 1:length(blocksin{subjcnt})
            	%rawfilePath = [rawpathstem basedir{subjcnt} '/' fullid{subjcnt} '/' blocksin_folders{subjcnt}{i} '/' blocksin{subjcnt}{i}];
		rawfilePath = [rawpathstem '/' subjects{subjcnt} '/' fullid{subjcnt} '/' blocksin_folders{subjcnt}{i} '/' blocksin{subjcnt}{i}];         
		outfilePath = [outputfolderpath '/' blocksout{subjcnt}{i} '.nii'];
            if ~exist(outfilePath,'file')
                fprintf([ '\n\nMoving ' blocksin{subjcnt}{i} ' to ' outfilePath '...\n\n' ]);
                copyfile(rawfilePath,outfilePath);
            else
                fprintf([ '\n\n ' outfilePath ' already exists, moving on...\n\n' ]);
            end % blocks
        end
        
        fprintf('\n\nRaw data copied to preprocessing directory! Now working on it.\n\n');      
        prevStep = '';
        pathstem = [preprocessedpathstem '/' subjects{subjcnt} '/'];  
    case 'raw_nocopy'
        prevStep = '';
        pathstem = [preprocessedpathstem '/' subjects{subjcnt} '/'];
    case 'skullstrip'
        prevStep = '';
        pathstem = [preprocessedpathstem '/' subjects{subjcnt} '/'];
    case 'realign'
        prevStep = '';
        pathstem = [preprocessedpathstem '/' subjects{subjcnt} '/'];
    case 'topup'
        prevStep = 'topup_.*';
        pathstem = [preprocessedpathstem '/' subjects{subjcnt} '/'];
    case 'smooth3'
        prevStep = 's3.*';
        smoothing = 3;
        pathstem = [preprocessedpathstem '/' subjects{subjcnt} '/'];
        
end

%% Set up environment
global spmpath fsldir toolboxdir
switch clusterid
        
    case 'HPHI'
%         rawpathstem = '/rds/user/tec31/hpc-work/SERPENT/rawdata/';
%         preprocessedpathstem = '/rds/user/tec31/hpc-work/SERPENT/preprocessed/';
        spmpath = '/applications/spm/spm12_6906/';
        fsldir = '/applications/fsl/fsl-5.0.10/';
        toolboxdir = '/home/tec31/toolboxes/'; % Needs fixing
        addpath(spmpath)
        spm fmri
        scriptdir = '/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/scripts/EPIs/';
        freesurferpath = '/applications/freesurfer/freesurfer_6.0.0/';
        
end

%% Now do the requested step
switch step
        
    case 'topup'
        % Apply topup to distortion correct the EPI
        nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
        %topupworkedcorrectly = zeros(1,nrun);
        for crun = subjcnt
            disp('running topup') 
            base_image_path = [pathstem blocksout{crun}{find(strcmp(blocksout{crun},'Pos_topup'))} '.nii'];
            reversed_image_path = [pathstem blocksout{crun}{find(strcmp(blocksout{crun},'Neg_topup'))} '.nii'];
            outpath = [preprocessedpathstem '/' subjects{crun} '/'];
            theseepis = find(strncmp(blocksout{crun},'Run',3));
            filestocorrect = cell(1,length(theseepis));
            json_path = [rawpathstem '/' subjects{subjcnt} '/' fullid{subjcnt} '/' blocksin_folders{subjcnt}{3}];
            for i = 1:length(theseepis)
                filestocorrect{i} = [outpath blocksout{crun}{theseepis(i)} '.nii']; % pathstem to outpath temp
            end
            module_topup_job_cluster(base_image_path, reversed_image_path, outpath, minvols(crun), filestocorrect,json_path)
            if ~exist([outpath 'epi_topup_results_fieldcoef.nii'],'file')
                error('Topup not successfully calculated!');
            % globbing with star may not work
            elseif ~exist([outpath 'topup_Run_*.nii'],'file')
                error('Topup not successfully applied!');
            end
            
%             try
%                 module_topup_job_cluster(base_image_path, reversed_image_path, outpath, minvols(crun), filestocorrect,json_path)
%                 topupworkedcorrectly(crun) = 1;
%             catch
%                 topupworkedcorrectly(crun) = 0;
%             end
            
        end
        
%         if ~all(topupworkedcorrectly)
%             error('failed at topup');
%         end
        
    case 'realign'
        % Now realign the EPIs
        nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
        realignworkedcorrectly = zeros(1,nrun);
        for crun = subjcnt
            disp('running realign')
            theseepis = find(strncmp(blocksout{crun},'Run',3));
            filestorealign = cell(1,length(theseepis));
            outpath = [preprocessedpathstem '/' subjects{crun} '/']; 
            for i = 1:length(theseepis)
                filestorealign{i} = spm_select('ExtFPList',outpath,['^' prevStep blocksout{crun}{theseepis(i)} '.nii'],1:minvols(crun));
            end
            flags = struct;
            flags.fhwm = 3;
            try
                spm_realign(filestorealign,flags)
                realignworkedcorrectly(crun) = 1;
            catch
                realignworkedcorrectly(crun) = 0;
            end
        end
        
        if ~all(realignworkedcorrectly)
            error('failed at realign');
        end
        
    case 'reslice'
        % Reslice the mean topup corrected image
        nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
        disp('running reslice')
        resliceworkedcorrectly = zeros(1,nrun);
        for crun = subjcnt
            theseepis = find(strncmp(blocksout{crun},'Run',3));
            filestorealign = cell(1,length(theseepis));
            outpath = [preprocessedpathstem '/' subjects{crun} '/'];  
            for i = 1:length(theseepis)
                filestorealign{i} = spm_select('ExtFPList',outpath,['^' prevStep blocksout{crun}{theseepis(i)} '.nii'],1:minvols(crun));
            end
            flags = struct;
            % 0 = no reslice just produce mean, 1 = reslice but not first image, [2 1] =reslice all and produce mean
            %flags.which = 0;
            flags.which = [2 1];
            %flags.which = 1;
            
            try
                spm_reslice(filestorealign,flags)
                resliceworkedcorrectly(crun) = 1;
            catch
                resliceworkedcorrectly(crun) = 0;
            end
        end
        
        if ~all(resliceworkedcorrectly)
            error('failed at reslice');
        end
       
        
%     case 'cat12'
%         % Do cat12 normalisation of the structural to create deformation fields (works better than SPM segment deformation fields, which sometimes produce too-small brains)
%         disp('running cat12 normalisation')
%         nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
%         jobfile = {[scriptdir 'module_cat12_normalise_job_cluster.m']};
%         inputs = cell(1, nrun);
%         for crun = subjcnt
%             outpath = [preprocessedpathstem subjects{crun} '/'];
%             inputs{1, crun} = cellstr([outpath 'structural_skullstripped_csf.nii']);
%         end
%         
%         cat12workedcorrectly = zeros(1,nrun);
%         jobs = repmat(jobfile, 1, 1);
%         
%         for crun = subjcnt
%             spm('defaults', 'fMRI');
%             spm_jobman('initcfg')
%             try
%                 spm_jobman('run', jobs, inputs{:,crun});
%                 cat12workedcorrectly(crun) = 1;
%             catch
%                 cat12workedcorrectly(crun) = 0;
%             end
%         end
%         
%         if ~all(cat12workedcorrectly)
%             error('failed at cat12');
%         end
%         
%     case 'coregister'
%         % co-register estimate, using structural as reference, mean as source and epi as others, then reslice only the mean
%         disp('running co-registration')
%         nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
%         coregisterworkedcorrectly = zeros(1,nrun);
%         
%         for crun = subjcnt
%             job = struct;
%             job.eoptions.cost_fun = 'nmi';
%             job.eoptions.tol = [repmat(0.02,1,3), repmat(0.01,1,6), repmat(0.001,1,3)];
%             job.eoptions.sep = [4 2];
%             job.eoptions.fwhm = [7 7];
%             
%             outpath = [preprocessedpathstem subjects{crun} '/'];
%             job.ref = {[outpath 'structural_skullstripped_csf.nii,1']};
%             theseepis = find(strncmp(blocksout{crun},'Run',3));
%             job.source = {[outpath 'meantopup_' blocksout{crun}{theseepis(1)} '.nii,1']};
%             
%             filestocoregister = cell(1,length(theseepis));
%             filestocoregister_list = [];
%             for i = 1:length(theseepis)
%                 filestocoregister{i} = spm_select('ExtFPList',outpath,['^' prevStep blocksout{crun}{theseepis(i)} '.nii'],1:minvols(crun));
%                 filestocoregister_list = [filestocoregister_list; filestocoregister{i}];
%             end
%             filestocoregister = cellstr(filestocoregister_list);
%             
%             job.other = filestocoregister;
%             
%             try
%                 spm_run_coreg(job)
%                 
%                 % Now co-register reslice the mean EPI
%                 P = char(job.ref{:},job.source{:});
%                 spm_reslice(P)
%                 
%                 coregisterworkedcorrectly(crun) = 1;
%             catch
%                 coregisterworkedcorrectly(crun) = 0;
%             end
%         end
%         
%         if ~all(coregisterworkedcorrectly)
%             error('failed at coregister');
%         end
%         
%     case 'normalisesmooth'
%         % normalise write for visualisation and smooth at 3 and 8
%         disp('running normalisation and smoothing')
%         nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
%         jobfile = {[scriptdir 'module_normalise_smooth_job.m']};
%         inputs = cell(2, nrun);
%         
%         for crun = subjcnt
%             outpath = [preprocessedpathstem subjects{crun} '/'];
%             
%             % % First is for SPM segment, second for CAT12
%             %inputs{1, crun} = cellstr([rawpathstem basedir{crun} '/' fullid{crun} '/' blocksin_folders{crun}{find(strcmp(blocksout{crun},'structural'))} '/y_' blocksin{crun}{find(strcmp(blocksout{crun},'structural'))}]);
%             inputs{1, crun} = cellstr([outpath 'mri/y_structural_skullstripped_csf.nii']);
%             
%             
%             theseepis = find(strncmp(blocksout{crun},'Run',3));
%             filestonormalise = cell(1,length(theseepis));
%             filestonormalise_list = [];
%             for i = 1:length(theseepis)
%                 filestonormalise{i} = spm_select('ExtFPList',outpath,['^' prevStep blocksout{crun}{theseepis(i)} '.nii'],1:minvols(crun));
%                 filestonormalise_list = [filestonormalise_list; filestonormalise{i}];
%             end
%             inputs{2, crun} = cellstr(filestonormalise_list);
%             % % First is for SPM segment, second for CAT12
%             %inputs{3, crun} = cellstr([rawpathstem basedir{crun} '/' fullid{crun} '/' blocksin_folders{crun}{find(strcmp(blocksout{crun},'structural'))} '/y_' blocksin{crun}{find(strcmp(blocksout{crun},'structural'))}]);
%             inputs{3, crun} = cellstr([outpath 'mri/y_structural_skullstripped_csf.nii']);
%             inputs{4, crun} = cellstr([outpath 'structural_skullstripped_csf.nii,1']);
%             % % First is for SPM segment, second for CAT12
%             %inputs{5, crun} = cellstr([rawpathstem basedir{crun} '/' fullid{crun} '/' blocksin_folders{crun}{find(strcmp(blocksout{crun},'structural'))} '/y_' blocksin{crun}{find(strcmp(blocksout{crun},'structural'))}]);
%             inputs{5, crun} = cellstr([outpath 'mri/y_structural_skullstripped_csf.nii']);
%             inputs{6, crun} = cellstr([outpath 'binarised_native_structural_mask.nii,1']);
%         end
%         
%         normalisesmoothworkedcorrectly = zeros(1,nrun);
%         jobs = repmat(jobfile, 1, 1);
%         
%         for crun = subjcnt
%             spm('defaults', 'fMRI');
%             spm_jobman('initcfg')
%             try
%                 spm_jobman('run', jobs, inputs{:,crun});
%                 normalisesmoothworkedcorrectly(crun) = 1;
%             catch
%                 normalisesmoothworkedcorrectly(crun) = 0;
%             end
%         end
%         
%         if ~all(normalisesmoothworkedcorrectly)
%             error('failed at normalise and smooth');
%         end
        
%     case 'make_bids_format'
%         % Copy data to a new folder in BIDS format
%         fprintf([ '\n\nCurrent subject = ' subjects{subjcnt} '...\n\n' ]);
%         % make output directory if it doesn't exist
%         outputfolderpath = [preprocessedpathstem 'bidsformat/'];
%         if ~exist(outputfolderpath,'dir')
%             mkdir(outputfolderpath);
%         end
%         
%         % change to input directory
%         for i = 1:length(blocksin{subjcnt})
%             rawfilePath = [rawpathstem basedir{subjcnt} '/' fullid{subjcnt} '/' blocksin_folders{subjcnt}{i} '/' blocksin{subjcnt}{i}];
%             switch strtok(blocksout{subjcnt}{i}, '_')
% % BIDS 2.0 READY
%                 % case 'structural'
% %                     outfilePath = [outputfolderpath 'sub-' subjects{subjcnt} '/ses-' dates{19} '/anat/sub-' subjects{subjcnt} '_ses-' dates{19} '_acq-mp2ragesag_out-uni_MP2RAGE.nii'];
% %                 case 'INV2'
% %                     outfilePath = [outputfolderpath 'sub-' subjects{subjcnt} '/ses-' dates{19} '/anat/sub-' subjects{subjcnt} '_ses-' dates{19} '_acq-mp2ragesag_out-inv2_MP2RAGE.nii'];
% % BIDS 1.0 FOR NOW
%                 case 'structural'
%                     outfilePath = [outputfolderpath 'sub-' subjects{subjcnt} '/ses-' dates{19} '/anat/sub-' subjects{subjcnt} '_ses-' dates{19} '_acq-mp2ragesag_T1w.nii'];
%                 case 'Run'
%                     split_run_num = strsplit(blocksout{subjcnt}{i},'_');
%                     outfilePath = [outputfolderpath 'sub-' subjects{subjcnt} '/ses-' dates{19} '/func/sub-' subjects{subjcnt} '_ses-' dates{19} '_task-SERPENT_acq-cmrr_run-' split_run_num{end} '_bold.nii'];
%                 otherwise
%                     sprintf([blocksout{subjcnt}{i} ' not part of BIDS format, moving on']);
%                     continue
%             end
%             if ~exist(outfilePath,'file') && ~exist([outfilePath '.gz'],'file')
%                 fprintf([ '\n\nMoving ' blocksin{subjcnt}{i} ' to ' outfilePath '...\n\n' ]);
%                 outfile_folder = fileparts(outfilePath);
%                 if ~exist(outfile_folder,'dir')
%                     mkdir(outfile_folder);
%                 end
%                 module_create_json(rawfilePath,outfilePath) % Create json file from DICOM textheader
%                 copyfile(rawfilePath,outfilePath); % Copy niti to BIDS format
%                 switch strtok(blocksout{subjcnt}{i}, '_')
%                     case {'structural','INV2'} % Stupid hacky way of fixing the error that MP2RAGE is said to have 4 dimensions and this fails the bids validator
%                         struc_vol = spm_vol(outfilePath);
%                         spm_imcalc(struc_vol,struc_vol.fname,'i1'); % Outputs only 3 dimensions
%                 end
%             elseif ~exist([outfilePath(1:end-4) '.json'],'file')
%                 fprintf([ '\n\n ' outfilePath ' already exists, creating matching json file\n\n' ]);
%                 module_create_json(rawfilePath,outfilePath) % Create json file from DICOM textheader
%             else                
%                 fprintf([ '\n\n ' outfilePath ' already exists, moving on...\n\n' ]);
%             end % blocks
%         end
%         if ~exist([outputfolderpath '/participants.tsv'])
%             fileID = fopen([outputfolderpath '/participants.tsv'],'w');
%             fprintf(fileID,'participant_id\n');
%             for i = 1:length(subjects)
%                 fprintf(fileID,[subjects{i} '\n'])
%             end
%         end
%         if ~exist([outputfolderpath '/.bidsignore'])
%             fileID = fopen([outputfolderpath '/.bidsignore'],'w');
%             fprintf(fileID,'*_date_acc.txt\n')
%             fprintf(fileID,'wbic_scan_types_bids.txt\n')
%             fprintf(fileID,'*.dcm\n')
%             fprintf(fileID,'*rest3echoref*\n')
%             fprintf(fileID,'participant_id*_date_acc.txt\n')
%             fprintf(fileID,'participant_id*_date_acc.txt\n')
%         end
%         if ~exist([outputfolderpath '/dataset_description.json'])
%             fileID = fopen([outputfolderpath '/dataset_description.json'],'w');
%             fprintf(fileID,'{\n')
%             fprintf(fileID,'	"Name": "SERPENT P00420",\n')
%             fprintf(fileID,'	"BIDSVersion": "1.0.2"\n')
%             fprintf(fileID,'}\n')
%         end
%         
%         fprintf('\n\nRaw data copied to preprocessing directory! Now working on it.\n\n');
% 
%     case 'skullstrip'
%         % Skullstrip structural
%         nrun = 1; % enter the number of runs here - should be 1 if submitted in parallel, but retain the functionality to bundle subjects
%         
%         jobfile = {[scriptdir 'module_skullstrip_noINV2_job_cluster.m']};
%         inputs = cell(2, nrun);
%         disp('running SPM skullstrip')
%         
%         for crun = subjcnt
%             inputs{1, crun} = cellstr([pathstem blocksout{crun}{find(strcmp(blocksout{crun},'structural'))} '.nii,1']);
%             %inputs{2, crun} = cellstr([pathstem blocksout{crun}{find(strcmp(blocksout{crun},'INV2'))} '.nii,1']);
%             inputs{2, crun} = cellstr([pathstem blocksout{crun}{find(strcmp(blocksout{crun},'structural'))} '.nii']);
%             inputs{3, crun} = 'structural_skullstripped';
%             inputs{4, crun} = cellstr([preprocessedpathstem subjects{crun} '/']);
%             if ~exist(inputs{4, crun}{1})
%                 mkdir(inputs{4, crun}{1});
%             end
%             inputs{5, crun} = 'structural_skullstripped_csf';
%             inputs{6, crun} = cellstr([preprocessedpathstem subjects{crun} '/']);
%             inputs{7, crun} = cellstr([preprocessedpathstem subjects{crun} '/']);
%         end
%         
%         skullstripworkedcorrectly = zeros(1,nrun);
%         jobs = repmat(jobfile, 1, 1);
%         
%         for crun = subjcnt
%             spm('defaults', 'fMRI');
%             spm_jobman('initcfg')
%             try
%                 spm_jobman('run', jobs, inputs{:,crun});
%                 skullstripworkedcorrectly(crun) = 1;
%             catch
%                 skullstripworkedcorrectly(crun) = 0;
%             end
%         end
%         
%         if ~all(skullstripworkedcorrectly)
%             error('failed at skullstrip');
%         end

               
end
end

