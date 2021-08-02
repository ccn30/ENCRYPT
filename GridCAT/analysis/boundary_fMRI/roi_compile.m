%% Compile all subjects extracted ROIs from GLM1 and put into .csv file
% roiDir = '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/boundary_fMRI/GLM1_MTL_ROIs';
% nLabels = 12;
% resultsDir = '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/boundary_fMRI/';
function roi_compile(roiDir,nLabels,resultsDir)
addpath('/home/ccn30/rds/hpc-work/WBIC_home/Documents/MATLAB/');
% get list of subjects in results dir
subjDirList = dir(roiDir);

% delete all list entries that precede with . or $ (except ..)
subjDirList([subjDirList(:).isdir]) = [];

% load in each ROI and subject name into lists
scriptdir = pwd;
cd(subjDirList(1).folder); % cd into results dir

for subjIdx = 1:length(subjDirList)
    
    subjROI = char(subjDirList(subjIdx).name);
    roiList.(['s' subjROI(1:5)]) = load(subjDirList(subjIdx).name); % dynamic field names per subject starting with letter
    subjNameList{subjIdx} = subjROI(1:5);
    
    % extract means per subject per label
    % right
    for labIdx = 1:nLabels
        if contains(roiList.(['s' subjROI(1:5)]).ROI(labIdx).ROIfile, 'right')
            metricNameRight{labIdx} = ['right_' sprintf('%d',labIdx)];
            metricRight{subjIdx,labIdx} = roiList.(['s' subjROI(1:5)]).ROI(labIdx).mean;
        end
    end
    
    % left
    for labIdx = 1:nLabels
        labIdxMetric = labIdx + 12;
        if contains(roiList.(['s' subjROI(1:5)]).ROI(labIdxMetric).ROIfile, 'left')
            metricNameLeft{labIdx} = ['left_' sprintf('%d',labIdx)];
            metricLeft{subjIdx,labIdx} = roiList.(['s' subjROI(1:5)]).ROI(labIdxMetric).mean;
        end
    end
    
end % of for loop

cd(scriptdir);

%% prepare table and save
% combine subjNameList{} with metricNameList{} and output_cArray{}

% remove empty cell fields
emptyLeft = cellfun('isempty',metricLeft);
metricLeft(:,all(emptyLeft,1)) = [];
emptyRight = cellfun('isempty',metricRight);
metricRight(:,all(emptyRight,1)) = [];
       
% compile into table
output_cArray = [['Subject' subjNameList]' [metricNameRight; metricRight] [metricNameLeft; metricLeft]];

filename = 'GLM1_allSubjs_MTLregions_means';
cell2csv([resultsDir filesep filename '.csv'], output_cArray);
save(    [resultsDir filesep filename '.mat'], 'output_cArray');
disp(['data saved to: ' resultsDir filesep filename '.csv']);
end % of function