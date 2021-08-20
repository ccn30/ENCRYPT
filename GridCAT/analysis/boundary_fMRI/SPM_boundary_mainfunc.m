function SPM_boundary_mainfunc(clusterid,pathstem,subjects,subjcnt,blocksout,minvols,step)
% Two part script
% 1. creates and runs SPM jobfile per subject: specifies gridCAT task events and distance regressor (step = 'GLM1')
% 2. runs ROI_extract.m to derive metrics (step = 'roi_extract')

% derived from parent SPMuni_subjects_parameters.m, and paths derived from parent bash script SPMuni_prepare.sh

% use these to debug (change steps in command)
% run ENCRYPT_subjects_parameters.m
% pathstem ='/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT';
% SPM_boundary_mainfunc('HPC',pathstem,subjects,1,blocksout,minvols,'GLM1')

% Coco Newton June 2021

%% Set up environment

% initialise
ROI_flag = 'pmEC'; % choose which gridCAT output to use ie right or left pmEC, 6 fold model or other
blocks = {'A','B','C'}; % of three runs
TR = 2.53;
JFlocation = [pathstem '/scripts/GridCAT/analysis/boundary_fMRI/SPMjobfiles/']; %where jobfile should be saved to

global spmpath fsldir toolboxdir
switch clusterid
    
    case 'HPHI'
        spmpath = '/applications/spm/spm12_6906/';
        fsldir = '/applications/fsl/fsl-5.0.10/';
        toolboxdir = '/home/ccn30/toolboxes/'; % Needs fixing
        addpath(spmpath)
        addpath('/home/ccn30/GridCAT');
        spm fmri
        scriptdir = '/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/scripts/SPM_univariate/';
        
    case 'HPC'
        spmpath = '/usr/local/software/spm/spm12';
        fsldir = '/usr/local/software/fsl/6.0.4';
        addpath(spmpath)
        addpath('/home/ccn30/rds/hpc-work/WBIC_home/GridCAT/');
        MTLmaskdir = '/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/segmentation/ECsubdivisions_Mag';
        MTLmaskWholedir = '/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/segmentation/EPI_ASHSMTL_masks';
        ROIresultsDir = '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/boundary_fMRI/GLM1_MTL_ROIs';
        
end

nrun = 1;


for crun = subjcnt
    
    fprintf(['\n Running SPM boundary analysis for subject ' subjects{crun} ' \n'])
    
    %% preallocate variables
    % temporary
    theseepis = find(strncmp(blocksout{crun},'Run',3));
    rawEventType = cell(1,length(theseepis));
    onsets = cell(1,length(theseepis));
    durations = cell(1,length(theseepis));
    angles = cell(1,length(theseepis));
    eventfiles = cell(1,length(theseepis));
    
    % output
    filestoanalyse = cell(1,length(theseepis));
    TransAligned = {};
    TransMisaligned = {};
    Rotation = {};
    rpfiles = cell(1,length(theseepis));
    dist = {};
    
    % set dir and file path stems (updated from pilot)
    scansfilepath = [pathstem '/fMRI/' subjects{crun} '/']; %do these non pilot scans need splitting?
    eventfilepath = [pathstem '/task_data/gridtask/' subjects{crun} '/'];
    gridmetricspath = [pathstem '/results/gridCAT/'];
    outpath = [pathstem '/results/boundary_fMRI/GLM1/' subjects{crun}];
    distRegPath = [pathstem '/task_data/gridtask/' subjects{crun} '/'];
    
    
    %% check if EPIs are prepared/smoothed
    
    if ~exist([scansfilepath 'srtopup_Run_1.nii'],'file')
        if exist([scansfilepath 'rtopup_Run_1.nii'],'file') == 2
            warning('Smoothing EPIs first');
            
            for crun = subjcnt
                filestosmooth = {};
                filestosmooth_list = [];
                
                for i = 1:length(theseepis)
                    for j = 1:minvols(subjcnt)
                        %filestosmooth = spm_select('ExtFPList',outpath,['^' prevStep blocksout{crun}{theseepis(i)} '.nii'],1:minvols(crun));
                        filestosmooth{j,1} = [scansfilepath 'rtopup_' blocksout{crun}{theseepis(i)} '.nii,' num2str(j)];
                    end
                    filestosmooth_list = [filestosmooth_list;filestosmooth];
                end
                smooth.matlabbatch{1}.spm.spatial.smooth.data = filestosmooth_list;
                % Other
                smooth.matlabbatch{1}.spm.spatial.smooth.fwhm = [3 3 2];
                smooth.matlabbatch{1}.spm.spatial.smooth.dtype = 0;
                smooth.matlabbatch{1}.spm.spatial.smooth.im = 0;
                smooth.matlabbatch{1}.spm.spatial.smooth.prefix = 's';
                % Run                
                spm('defaults','fmri');
                spm_jobman('initcfg');
                spm_jobman('run',smooth.matlabbatch);
            end % of for loop
            
        else
            warning('Realigned topup EPIs not present');
        end % of inner if loop
        
    end % of outer if loop
    
    %% load in all data from each session (3 total)
    
    for sess = 1:length(theseepis)
        
        % MOVEMENT REGRESSORS
        rpfiles{sess} = [scansfilepath 'rp_topup_' blocksout{crun}{theseepis(sess)} '.txt'];
        
        % EPIs
        for j = 1:minvols(subjcnt)
            filestoanalyse{sess}{j,1} = [scansfilepath 'srtopup_' blocksout{crun}{theseepis(sess)} '.nii,' num2str(j)];
        end
        
        % TASK TIMING INFORMATION
        eventfiles{sess} = [eventfilepath 'Block' blocks{sess} '/eventTable_movemenEventData.txt']; % want rotations or not?
        fid = fopen(eventfiles{sess});
        data = textscan(fid, '%s %f %f %f','delimiter',';');
        fclose(fid);
        % extract relevant info
        rawEventType{sess} = data{1};
        onsets{sess} = data{2};
        durations{sess} = data{3};
        angles{sess} = data{4};
        
        % GRID METRICS FROM GRIDCAT i.e. estimated mean orientation per subject (in output_cArray variable)
        gridmetrics = load([gridmetricspath '/gridCAT_X_hybrid_results2_global.mat']);
        % get row and column locations where mean orientation is for current subject **FOR CERTAIN ROI** CHANGE!
        [~,meanOriIndex] = find(strcmp(gridmetrics.output_cArray,['MeanOrientation_allRuns_' ROI_flag '_right_6']));
        [subjIndex,~] = find(strcmp(gridmetrics.output_cArray,subjects{crun}));
        
        % DISTANCE REGRESSOR
        distRaw = readtable([distRegPath 'Block' blocks{sess} '/distanceRegressor_' subjects{crun} '_Block' blocks{sess} '.csv']);
        
        %% DETEMINE TRANSLATION EVENT ALIGNMENT
        % compare each translation event angle to subject's mean grid orientation in 60 degree space, algined or misaligned?
        
        for i = 1:length(rawEventType{sess})
            
            if strcmp(rawEventType{sess}{i}, 'translation')
                % alignment = absAngDiff(angles{sess}(i),str2double(gridmetrics.output_cArray{subjIndex,meanOriIndex}),60);
                % Matthias said his absAngDiff func may not work as angles are in 360 degree space not 60 degrees, so use
                % cos(6 * (the event angle - the subject mean grid orientation))
                
                alignment = cosd(6*(angles{sess}(i) - str2double(gridmetrics.output_cArray{subjIndex,meanOriIndex})));
                
                % alignment should be between -1 to 1, with ALIGNED events over 0 and MISALIGNED events below 0
                if alignment >= 0
                    TransAligned.onset{sess}(i) = onsets{sess}(i);
                    TransAligned.duration{sess}(i) = durations{sess}(i);
                else
                    TransMisaligned.onset{sess}(i) = onsets{sess}(i);
                    TransMisaligned.duration{sess}(i) = durations{sess}(i);
                end
                
            elseif strcmp(rawEventType{sess}{i}, 'rotation')
                Rotation.onset{sess}(i) = onsets{sess}(i);
                Rotation.duration{sess}(i) = durations{sess}(i);
                
            end
            
        end
        
        % remove 0's from variables
        TransAligned.onset{sess}(TransAligned.onset{sess}==0)=[];
        TransAligned.duration{sess}(TransAligned.duration{sess}==0)=[];
        TransMisaligned.onset{sess}(TransMisaligned.onset{sess}==0)=[];
        TransMisaligned.duration{sess}(TransMisaligned.duration{sess}==0)=[];
        Rotation.onset{sess}(Rotation.onset{sess}==0)=[];
        Rotation.duration{sess}(Rotation.duration{sess}==0)=[];
        
        % CONVOLVE DISTANCE USER SPECIFIED REGRESSOR + DEMEAN
        linearDistReg = distRaw.DistNrstWall; % extract distance column from distRaw table loaded in
        binaryDistReg = distRaw.EventType; % extract binary distance event labels inner or boundary
        
        linearDistTemp = conv(linearDistReg, spm_hrf(TR)); % do convolution distances with HRF
        linearDist{sess} = zscore(linearDistTemp(1:238)); % demean, scale by SD, make into nScansx1 vector and add to dist variable session
        
        binaryDistTemp = conv(binaryDistReg, spm_hrf(TR)); % do convolution distances with HRF
        binaryDist{sess} = zscore(binaryDistTemp(1:238)); % demean, scale by SD, make into nScansx1 vector and add to dist variable session
        
    end % of run loop
    
    %% RUN STEP 1 OR 2
    
    switch step
        
        case 'GLM1'
            
            jobfile = create_boundaryGLM1_SPM_job(JFlocation,TR,subjects{crun},outpath,minvols(crun),filestoanalyse,TransAligned,TransMisaligned,Rotation,linearDist,binaryDist,rpfiles);
            %jobfile = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/scripts/SPM_univariate/SPM_jobfiles/test_job.m';
            spm('defaults', 'fMRI');
            spm_jobman('initcfg')
            
            try
                disp(['Running GLM1 for subject ' subjects{crun}]);
                spm_jobman('run', jobfile);
                SPMworkedcorrectly = 1;
            catch
                SPMworkedcorrectly = 0;
            end
            
            if ~SPMworkedcorrectly
                warning(['failed at boundary model specification for ' subjects{crun}]);
            end
            
        case 'roi_extract'
            
            % define S
            % include binary versions of MTL masks
            S = [];
            S.Datafiles= {{[outpath '/con_0003.nii']}}; % contrast for either linear or binary dist regressor
            MTLmaskR = gunzip([MTLmaskdir '/' subjects{crun} '_right_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz']);
            MTLmaskL = gunzip([MTLmaskdir '/' subjects{crun} '_left_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz']);
            %MTLmaskRwhole = gunzip([MTLmaskWholedir '/' subjects{crun} '_right_ASHSMTL_EPI_nocyst_bin.nii.gz']);
            %MTLmaskLwhole = gunzip([MTLmaskWholedir '/' subjects{crun} '_left_ASHSMTL_EPI_nocyst_bin.nii.gz']);
            S.ROIfiles{1} = MTLmaskR{1};
            S.ROIfiles{2} = MTLmaskL{1};
            S.output_raw = 1;
            S.zero_rel_tol = 0.6;  % This is what you can increase if you have lots of missing data in some ROIs
            ROI = roi_extract(S);
            
            % check for and remove erroneous label 9
            indx = find([ROI.ROIval] == 9);
            if length(ROI) > 24
                try
                    ROI(indx) = [];
                catch
                    warning(['Issue removing label 9 from mask for subject' subjects{crun}]);
                end
            end
            
             % save ROI info
            filename = [ROIresultsDir '/' subjects{crun} '_bilatMTLregions_con03.mat'];
            save(filename,'ROI');
                       
            
    end % of switch step
    
end % of subject loop

end % of function


% function distRaw = importCSV(filepath)
% opts = detectImportOptions(filepath); %create import option object
%     l = length(opts.VariableTypes); % change all variable types to characters because distances have 'm' at end apart from time
% %     for i = 1:l
% %         if contains(opts.VariableTypes{i},'double')
% %             opts.VariableTypes{i} = 'char';
% %         end
% %     end
% %     opts.VariableTypes{2} = 'double'; % time points
%     opts.Delimiter = ','; % split cells by these characters
%     opts.DataLines = 1; % start from 1st row
%     distRaw = readtable(logfile,opts);
% end



