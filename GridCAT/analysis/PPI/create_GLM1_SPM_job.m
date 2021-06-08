function jobfile = create_GLM1_SPM_job(TR,subject,outpath,minvols,filestoanalyse,TransAligned,TransMisaligned,Rotation,rpfiles)
%-----------------------------------------------------------------------
% Job saved on 30-Sep-2019 12:01:11 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------

% create file to write to
jobfile = ['/lustre/scratch/wbic-beta/ccn30/ENCRYPT/fMRI/gridcellpilot/scripts/SPM_univariate/SPM_jobfiles/SPM_GLM1_' num2str(subject) '_job.m'];
fileID = fopen(jobfile,'w');

%-----file contents start-----%

%% MODEL SPECIFICATION
fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.dir = {''' outpath '''};\n']);
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.timing.units = ''secs'';\n');
fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.timing.RT = ' num2str(TR) ';\n']);
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;\n');

for run = 1:3
    % define scan locations
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').scans = {\n']);
    
    for i = 1:minvols
        fprintf(fileID,['''' filestoanalyse{run}{i} '''\n']); % NEED ALL SESSIONS HERE
    end
    
    fprintf(fileID,'};\n');
    
    % Condition info
    % rotations
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(1).name = ''Rotation'';\n']);
    times = sprintf('%f; ', Rotation.onset{run}(1,:)); % print as a character vector separated by ;
    times = times(1:end-2); % remove last ; and ''
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(1).onset = [' times '];\n']);
    lengths = sprintf('%f; ', Rotation.duration{run}(1,:));
    lengths = lengths(1:end-2);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(1).duration = [' lengths '];\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(1).tmod = 0;\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(1).pmod = struct(''name'', {}, ''param'', {}, ''poly'', {});\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(1).orth = 1;\n']);
    % translation aligned 
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(2).name = ''TranslationAligned'';\n']);
    times = sprintf('%f; ',TransAligned.onset{run}(1,:)); % print as a character vector separated by ;
    times = times(1:end-2); % remove last ;
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(2).onset = [' times '];\n']);
    lengths = sprintf('%f; ',TransAligned.duration{run}(1,:));
    lengths = lengths(1:end-2);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(2).duration = [' lengths '];\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(2).tmod = 0;\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(2).pmod = struct(''name'', {}, ''param'', {}, ''poly'', {});\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(2).orth = 1;\n']);
    % translation misaligned
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(3).name = ''TranslationMisaligned'';\n']);
    times = sprintf('%f; ',TransMisaligned.onset{run}(1,:)); % print as a character vector separated by ;
    times = times(1:end-2); % remove last ;
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(3).onset = [' times '];\n']);
    lengths = sprintf('%f; ',TransMisaligned.duration{run}(1,:));
    lengths = lengths(1:end-2);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(3).duration = [' lengths '];\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(3).tmod = 0;\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(3).pmod = struct(''name'', {}, ''param'', {}, ''poly'', {});\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').cond(3).orth = 1;\n']);
    
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').multi = {''''};\n']);
    
    % Regressors
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').regress = struct(''name'', {}, ''val'', {});\n']);
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').multi_reg = {''' rpfiles{run} '''};\n']); 
    fprintf(fileID,['matlabbatch{1}.spm.stats.fmri_spec.sess(' num2str(run) ').hpf = 128;\n']);
    
end

%% futher model specification
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.fact = struct(''name'', {}, ''levels'', {});\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.volt = 1;\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.global = ''None'';\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.4;\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.mask = {''''};\n');
fprintf(fileID,'matlabbatch{1}.spm.stats.fmri_spec.cvi = ''AR(1)'';\n');

%% MODEL ESTIMATION
%fprintf(fileID,['matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = ''/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/preprocessed_data/regressors/' num2str(subj) '/Run' num2str(runN) '/fcontrast/SPM.mat'';\nmatlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;\nmatlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;\n']);
fprintf(fileID,'matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep(''fMRI model specification: SPM.mat File'', substruct(''.'',''val'', ''{}'',{1}, ''.'',''val'', ''{}'',{1}, ''.'',''val'', ''{}'',{1}), substruct(''.'',''spmmat''));\nmatlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;\nmatlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;\n');

%% INFERENCE
fprintf(fileID,'matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep(''Model estimation: SPM.mat File'', substruct(''.'',''val'', ''{}'',{1}, ''.'',''val'', ''{}'',{1}, ''.'',''val'', ''{}'',{1}), substruct(''.'',''spmmat''));\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = ''Translation>Rotation'';\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [-1 0.5 0.5 0 0 0 0 0 0 -1 0.5 0.5 0 0 0 0 0 0 -1 0.5 0.5 0 0 0 0 0 0];\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = ''none'';\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = ''Translation_Aligned>Translation_Misaligned'';\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1 -1 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0];\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = ''none'';\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = ''AllEffectsOfInterest'';\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = kron(eye(3),[eye(3) zeros(3,6)]);\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = ''none'';\n');
fprintf(fileID,'matlabbatch{3}.spm.stats.con.delete = 0;\n');

%-----end of file contents-----%

fclose(fileID);

end % of function

