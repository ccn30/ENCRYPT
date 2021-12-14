% List of open inputs
nrun = 11; % enter the number of runs here
jobfile = {'/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts/module_reslice_ENCRYPT_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
    
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
