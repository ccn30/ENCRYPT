%% GridCAT function for batch script
%called from gridcatprepare.sh

% input images, event table and regressors to generate grid cell metrics
% CCNewton adapted from GridCAT demo script 22/08/19,01/22

function GridCAT_mainfunc(subject,fmriDir,taskDir,regDir,outfilename,ROI_flag,warp_flag,xFold,mask_thresh,regressor_flag)

outpathstem = ['/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/gridCAT/' subject '/' outfilename];

% remove existing SPM.mat
if exist(outpathstem,'dir') ~= 0
    rmdir(outpathstem,'s')
    warning(['removed existing dir for ' outpathstem]);
end
    
blocks = {'BlockA','BlockB','BlockC'};
TR = 2.53;
xfold = str2double(xFold); %taken from input - xFold = str, xfold = numeric
nScans = 238;
maskthresh=str2double(mask_thresh); %taken from input - mask_thresh = str, maskthresh = numeric

% FLAGS
% calculate mean grid orientation within each run separately (0) or across all runs (1)
orientationcalc_flag = 0;
% use physiology regressors (phys) or use movement parameters (move)
nuisance_flag = 'move';


%% FUNCTIONAL SCANS, EVENT-TABLES, ADDITIONAL REGRESSORS

disp(['You are inside GridCAT_mainfunc, subject ' subject]);

for run = 1:length(blocks)
    
    % specify functional scans
    
    % split scans
%    fsldir='/applications/fsl/fsl-5.0.10/bin/';
%    FOURDfile = [fmriDir '/' subject '/rtopup_Run_' num2str(run) '.nii'];
%    cmd = [fsldir 'fslsplit ' FOURDfile ' ' FOURDfile(1:end-4) '_split -t'];
%    system(cmd);
    
    theseepis = ['artopup_run' num2str(run) '.nii'];
    path = [fmriDir '/' subject '/'];
    
    cfg.rawData.run(run).functionalScans = spm_select('ExtFPList',path,['^' theseepis],1:nScans);

    % specify event-table (_nr_ for no rotation events version)
    cfg.rawData.run(run).eventTable_file = [taskDir '/' subject '/' blocks{run} '/eventTable_nr_movemenEventData.txt'] ;
    
    % specify regressors file - need to combine rp.txt with phys regressors
    if strcmp(nuisance_flag,'phys') == 1
        cfg.rawData.run(run).additionalRegressors_file = [];
    elseif strcmp(nuisance_flag,'move') == 1
        cfg.rawData.run(run).additionalRegressors_file = [fmriDir '/' subject '/rp_topup_run' num2str(run) '.txt'];
    end
    
end
%% MODEL SETTINGS

% TR (inter-scan-interval) in seconds
cfg.GLM.TR = TR;

% x-fold symmetry value that the model is testing for
cfg.GLM.xFoldSymmetry = xfold;

% Masking threshold
cfg.GLM.maskingThreshold = maskthresh;

% Microtime onset & resolution
cfg.GLM.microtimeOnset = 8;
cfg.GLM.microtimeResolution = 16;

% HPF per run
cfg.GLM.HPF_perRun = [128, 128, 128];

% Model derivatives
%   [0 0] ... do not model derivatives
%   [1 0] ... time derivatives
%   [1 1] ... model time and dispersion derivatives
cfg.GLM.derivatives = [0 0];

% Optional: Do you want to display the design matrix after it has been created?
% The design matrix will not be displayed, if this settings is not defined
% use 0 or 1
cfg.GLM.dispDesignMatrix = 0;


%% GLM1

% Specify GLM number
%   1 ... estimate grid orientations voxelwise
%   2 ... test grid orientations
cfg.GLMnr = 1;

% Specify data directory for this GLM
% The directory will be created if it does not exist
cfg.GLM.dataDir = [outpathstem '/GLM1'];

% Which grid events should be used for this GLM?
%	2 ... use the first half of grid events per run
%	3 ... use the second half of grid events per run
%	4 ... use odd grid events within each run
%	5 ... use even grid events within each run
%	6 ... use all grid events of odd runs
%	7 ... use all grid events of even runs
%	8 ... use all grid events of all runs
%	9 ... use specification from event-table
cfg.GLM.eventUsageSpecifier = 2;

% Include unused grid events in the model?
%	0 ... grid events that are not used for this GLM will not be included in the model
%	1 ... grid events that are not used for this GLM will be included in the model
cfg.GLM.keepUnusedGridEvents = 1;

% Specify GLM1 using the current configuration (cfg)
specifyGLM(cfg);

% Estimate GLM1 using the current configuration (cfg)
estimateGLM(cfg);


%% GLM2

% Specify GLM number
%   1 ... estimate grid orientations voxelwise
%   2 ... test grid orientations
cfg.GLMnr = 2;

% Specify data directory for this GLM
% The directory will be created if it does not exist
cfg.GLM.dataDir = [outpathstem '/GLM2'];

% Which grid events should be used for this GLM?
%	2 ... use the first half of grid events per run
%	3 ... use the second half of grid events per run
%	4 ... use odd grid events within each run
%	5 ... use even grid events within each run
%	6 ... use all grid events of odd runs
%	7 ... use all grid events of even runs
%	8 ... use all grid events of all runs
%	9 ... use specification from event-table
cfg.GLM.eventUsageSpecifier = 3;

% Include unused grid events in the model?
%	0 ... grid events that are not used for this GLM will not be included in the model
%	1 ... grid events that are not used for this GLM will be included in the model
cfg.GLM.keepUnusedGridEvents = 1;

% GLM2 tests the estimated grid orientations that were estimated in GLM1.
% Specify here, where the GLM1 output is stored (i.e., the GLM1 data directory)
cfg.GLM.GLM1_resultsDir = [outpathstem '/GLM1'];

% Specify binary ROI mask
% Nonzero voxels within this mask are used to calculate the mean grid orientation.
% Use either main or control mask, either left or right

if strcmp(warp_flag, 'main')
    if strcmp(ROI_flag, 'both')
%       cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[]};
    elseif strcmp(ROI_flag, 'pmRightMaass')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/pmEC_right_HybridMaass_EPI.nii']};
    elseif strcmp(ROI_flag, 'pmLeftMaass')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/pmEC_left_HybridMaass_EPI.nii']};
    elseif strcmp(ROI_flag, 'pmRightDTI')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/pmEC_right_HybridDTI_EPI.nii']};
    elseif strcmp(ROI_flag, 'pmLeftDTI')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/pmEC_left_HybridDTI_EPI.nii']};    
    end
elseif strcmp(warp_flag,'control')
    if strcmp(ROI_flag,'HCtailR')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/ASHS_right_HCtail_EPI.nii']};
    elseif strcmp(ROI_flag,'HCtailL')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/ASHS_left_HCtail_EPI.nii']};
    elseif strcmp(ROI_flag,'alRightMaass')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/alEC_right_HybridMaass_EPI.nii']};
    elseif strcmp(ROI_flag,'alLeftMaass')
        cfg.GLM.GLM2_roiMask_calcMeanGridOri = {[regDir '/' subject '/alEC_left_HybridMaass_EPI.nii']};
    end
end

% Use different weighting for individual voxels within the ROI, when estimating the mean grid orientation?
%   0 ... all voxels within the ROI will get the same weighting
%   1 ... voxels will be weighted differently, according to their estimated firing amplitude in GLM1
cfg.GLM.GLM2_useWeightingForVoxels = 1;

% Calculate the mean grid orientation within an ROI across all runs or separately for each run?
%   0 ... the mean grid orientation is calculated for each run separately
%   1 ... the mean grid orientation is averaged across all runs
cfg.GLM.GLM2_averageMeanGridOriAcrossRuns = orientationcalc_flag;

% Which type of regressor should be included for grid events?
%   'pmod' ... one regressor with a parametric modulation
%   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
%                            and one regressor for misaligned events
%   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
%                                     or a negative peak (for misaligned events) in the BOLD signal is expected
cfg.GLM.GLM2_gridRegressorMethod = regressor_flag;

% Specify GLM2 using the current configuration (cfg)
specifyGLM(cfg);

% Estimate GLM2 using the current configuration (cfg)
estimateGLM(cfg);


%% EXPORT GRID METRICS

% Specify ROI masks, for which the grid metrics are calculated and exported
if strcmp(warp_flag, 'main')
    if strcmp(ROI_flag, 'both')
%       ROI_masks = {[]};
    elseif strcmp(ROI_flag, 'pmRightMaass')
        ROI_masks = {[regDir '/' subject '/pmEC_right_HybridMaass_EPI.nii']};
    elseif strcmp(ROI_flag, 'pmLeftMaass')
        ROI_masks = {[regDir '/' subject '/pmEC_left_HybridMaass_EPI.nii']};
    elseif strcmp(ROI_flag, 'pmRightDTI')
        ROI_masks = {[regDir '/' subject '/pmEC_right_HybridDTI_EPI.nii']};
    elseif strcmp(ROI_flag, 'pmLeftDTI')
        ROI_masks = {[regDir '/' subject '/pmEC_left_HybridDTI_EPI.nii']};    
    end
elseif strcmp(warp_flag,'control')
    if strcmp(ROI_flag,'HCtailR')
        ROI_masks = {[regDir '/' subject '/ASHS_right_HCtail_EPI.nii']};
    elseif strcmp(ROI_flag,'HCtailL')
        ROI_masks = {[regDir '/' subject '/ASHS_left_HCtail_EPI.nii']};
    elseif strcmp(ROI_flag,'alRightMaass')
        ROI_masks = {[regDir '/' subject '/alEC_right_HybridMaass_EPI.nii']};
    elseif strcmp(ROI_flag,'alLeftMaass')
        ROI_masks = {[regDir '/' subject '/alEC_left_HybridMaass_EPI.nii']};
    end
end

% Specify where the GLM1 and GLM2 output is stored
GLM1dir = [outpathstem '/GLM1'];
GLM2dir = [outpathstem '/GLM2'];

% Specify where the grid metric output should be saved
output_file = {[outpathstem '/GridCATmetrics_' subject '_xfold_' num2str(xfold) '_' ROI_flag '_' warp_flag '.txt']};

% Calculate and export grid metrics
gridMetric_export(ROI_masks, GLM1dir, GLM2dir, output_file);

end % of function












