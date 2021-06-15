% List of open inputs
% fMRI model specification: Directory - cfg_files
% fMRI model specification: Units for design - cfg_menu
% fMRI model specification: Interscan interval - cfg_entry
% fMRI model specification: Scans - cfg_files
% fMRI model specification: Scans - cfg_files
nrun = X; % enter the number of runs here
jobfile = {'/rds/user/ccn30/hpc-work/WBIC_lustre/ENCRYPT/scripts/GridCAT/analysis/boundary_fMRI/test_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(5, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Directory - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Units for design - cfg_menu
    inputs{3, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Interscan interval - cfg_entry
    inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Scans - cfg_files
    inputs{5, crun} = MATLAB_CODE_TO_FILL_INPUT; % fMRI model specification: Scans - cfg_files
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
