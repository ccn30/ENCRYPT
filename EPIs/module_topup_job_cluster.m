function module_topup_job_cluster(base_image_path, reversed_image_path, outpath, minvols, filestocorrect,json_path)

global fsldir 

setenv('FSL_DIR',fsldir);  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI'); % this to tell what the output type 
setenv('FSF_OUTPUT_FORMAT', 'nii'); % this to tell what the output type 

tsize=minvols;

% First merge the two directions for topup deformation field creation
cmd = [fsldir '/bin/fslmerge -t ' fullfile(outpath,'both_directions_fortopup') ' ' base_image_path ' ' reversed_image_path];
system(cmd)

% Now write txt file containing acquisition parameters 
%(assumes y-direction flip for phase encoding + calculated from protocol: EPI factor * echo spacing, unable to use header info anymore

epi_params = [0 -1 0 0.086; 0 1 0 0.086]; % 1x10-3 x 0.67 x 128
dlmwrite([outpath '/epi_acq_param.txt'],epi_params,'delimiter',' ')

% Then calculate topup (can take a longish time)
cmd = [fsldir '/bin/topup --imain=' outpath '/both_directions_fortopup --datain=' outpath '/epi_acq_param.txt --config=b02b0.cnf --out=' outpath '/epi_topup_results --iout=' outpath '/unwarped_blips'];
disp('Calculating topup, this can take some time')
status = system(cmd);
disp(['Calculation status: ' num2str(status)]);

%% Now apply topup
if ~exist([outpath '/epi_topup_results_fieldcoef.nii'],'file') || ~exist([outpath '/epi_topup_results_movpar.txt'],'file')
    error('epi_topup_results not produced');
else
    disp('Topup results present in output dir, now applying topup');
end

% per run
for i = 1:length(filestocorrect)
    
    % split EPI filepath
    splitpath = strsplit(filestocorrect{i}, '/');
    
    % split EPIs into ind. volumes per TR
    cmd = [fsldir '/bin/fslsplit ' filestocorrect{i} ' ' filestocorrect{i}(1:end-4) '_split -t'];
    system(cmd);
    
    % apply topup corrections per TR vol
    for TR = 1:tsize
        vol = TR-1;        
        cmd = [fsldir '/bin/applytopup --imain=' filestocorrect{i}(1:end-4) '_split' sprintf('%04d',vol) ' --inindex=1 --topup=' outpath '/epi_topup_results --datain=' outpath '/epi_acq_param.txt --method=jac --out=' filestocorrect{i}(1:end-length(splitpath{end})) 'topup_' splitpath{end}(1:end-4) '_split' sprintf('%04d',vol) ' --verbose'];
        system(cmd);        
    end
    
    % merge topup vols into single file
    cmd = [fsldir '/bin/fslmerge -t ' outpath '/topup_' splitpath{end} ' ' filestocorrect{i}(1:end-length(splitpath{end})) 'topup_' splitpath{end}(1:end-4) '_split*'];
    system(cmd);
    
    % delete split vols
    cmd = ['rm ' outpath '/*_split0*.nii'];
    system(cmd);
    
end
disp('Topup applied')

% old --datain file code

% base_head = spm_vol(base_image_path);
% reversed_head = spm_vol(reversed_image_path);
% if ~exist('base_head.private.diminfo.slice_time.duration','var')
%     warning('Echo spacing not found with spm_vol - using .json file and manual calculations')
%     base_head_json = jsondecode(fileread(json_path));
%     echospacing =  1/base_head_json.BandwidthPerPixelPhaseEncode; % nifti structure not working
% end
% if base_head.private.diminfo.slice_time.duration > 10
%     warning('Apparently more than 10 seconds to acquire a slice, assuming milliseconds rather than seconds')
%     base_head.private.diminfo.slice_time.duration = base_head.private.diminfo.slice_time.duration/1000;
%     reversed_head.private.diminfo.slice_time.duration = reversed_head.private.diminfo.slice_time.duration/1000;
% end
%epi_params = [0 -1 0 base_head.private.diminfo.slice_time.duration; 0 1 0 reversed_head.private.diminfo.slice_time.duration];
%epi_params = [0 -1 0 echospacing; 0 1 0 echospacing];