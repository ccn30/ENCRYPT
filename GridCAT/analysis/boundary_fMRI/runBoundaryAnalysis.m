%% Run distance regressor and boundary fMRI analysis
% calls getDistanceRegressor, SPM_boundary_mainfunc and createGLM1SPMjob

taskDir='~/rds/hpc-work/WBIC_lustre/ENCRYPT/task_data/gridtask';

% first run ENNCRYPT_subjects_parameters
% run('ENCRYPT_subjects_parameters.m')

% loop through subjects
for i = 1:18
    subj = str2double(subjects{i});
 
    % run distance regressor creation
    try        
        getGridDistanceRegressor(subj,taskDir);
    catch
        warning(['getGridDistanceRegressor failed for subject ' subjects{i}]);
    end
end