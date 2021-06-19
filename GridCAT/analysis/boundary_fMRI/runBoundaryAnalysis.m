%% Run distance regressor and boundary fMRI analysis
% called from SLURMsubmit_BoundaryAnalysis.sh
% calls getDistanceRegressor, SPM_boundary_mainfunc and createGLM1SPMjob
function runBoundaryAnalysis(pathstem,taskDir,nSubjects,subjects,blocksout,minvols)

nSubjects = str2double(nSubjects);

%% if running interactively:
%pathstem ='/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT';
%taskDir='~/rds/hpc-work/WBIC_lustre/ENCRYPT/task_data/gridtask';
% first run ENNCRYPT_subjects_parameters
%run('ENCRYPT_subjects_parameters.m')

%% loop through subjects
for i = 15:nSubjects
    subj = subjects{i};
 
%     % run distance regressor creation
%     try        
%         getGridDistanceRegressor(subj,taskDir);
%     catch
%         warning(['getGridDistanceRegressor failed for subject ' subj]);
%     end

    % run main function
    try
        SPM_boundary_mainfunc('HPC',pathstem,subjects,i,blocksout,minvols);
    catch
        warning(['main function failed at subject ' subj]);
    end

end % of for loop

end