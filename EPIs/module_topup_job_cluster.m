function module_topup_job_cluster(base_image_path, reversed_image_path, outpath, minvols, filestocorrect,json_path)

global fsldir 

setenv('FSL_DIR',fsldir);  % this to tell where FSL folder is
setenv('FSLOUTPUTTYPE', 'NIFTI'); % this to tell what the output type 
setenv('FSF_OUTPUT_FORMAT', 'nii'); % this to tell what the output type 

tsize=minvols;

%First merge the two directions for topup deformation field creation
cmd = [fsldir 'bin/fslmerge -t ' outpath 'both_directions_fortopup ' base_image_path ' ' reversed_image_path ];
system(cmd)

%Now write txt file containing acquisition parameters (assumes y-direction
%flip for phase encoding)
base_head = spm_vol(base_image_path);
reversed_head = spm_vol(reversed_image_path);
if ~exist('base_head.private.diminfo.slice_time.duration','var')
    warning('Echo spacing not found with spm_vol - using .json file and manual calculations')
    jsonfile = dir([json_path '/*.json']);
    if size(jsonfile) ~= [1 1]
        error(['Too many json files in dir - check ' json_path]);
    end
    base_head_json = jsondecode(fileread([json_path '/' jsonfile.name]));
    %base_head.private.diminfo.slice_time.duration = 1/base_head_json.BandwidthPerPixelPhaseEncode;
    %reversed_head.private.diminfo.slice_time.duration = 1/base_head_json.BandwidthPerPixelPhaseEncode;
    echospacing =  1/base_head_json.BandwidthPerPixelPhaseEncode; % nifti structure not working
end
% if base_head.private.diminfo.slice_time.duration > 10
%     warning('Apparently more than 10 seconds to acquire a slice, assuming milliseconds rather than seconds')
%     base_head.private.diminfo.slice_time.duration = base_head.private.diminfo.slice_time.duration/1000;
%     reversed_head.private.diminfo.slice_time.duration = reversed_head.private.diminfo.slice_time.duration/1000;
% end
%epi_params = [0 -1 0 base_head.private.diminfo.slice_time.duration; 0 1 0 reversed_head.private.diminfo.slice_time.duration];
epi_params = [0 -1 0 echospacing; 0 1 0 echospacing];
dlmwrite([outpath 'epi_acq_param.txt'],epi_params,'delimiter',' ')

%Then calculate topup (can take a longish time)
cmd = [fsldir 'bin/topup --imain=' outpath 'both_directions_fortopup --datain=' outpath 'epi_acq_param.txt --config=b02b0.cnf --out=' outpath 'epi_topup_results --iout=' outpath 'unwarped_blips'];
% %If error due to odd number of lines
% cmd = [fsldir '/bin/topup --imain=' outpath 'both_directions_fortopup --datain=' outpath 'epi_acq_param.txt --config=/group/language/data/thomascope/7T_SERPENT_pilot_analysis/b02b0_nosubsamp.cnf --out=' outpath 'epi_topup_results'];
disp('Calculating topup, this can take some time')
status = system(cmd);
disp(['Calculation status: ' num2str(status)]);

%Now apply topup
if ~exist([outpath 'epi_topup_results_fieldcoef.nii'],'file') || ~exist([outpath 'epi_topup_results_movpar.txt'],'file')
    error('epi_topup_results not produced');
else
    disp('Topup results present in output dir, now applying topup');
end
for i = 1:length(filestocorrect)
    splitpath = strsplit(filestocorrect{i}, '/');
    
    cmd = [fsldir 'bin/fslsplit ' filestocorrect{i} ' ' filestocorrect{i}(1:end-4) '_split -t'];
    system(cmd);
    
    for TR = 1:tsize
        vol = TR-1;
        
        cmd = [fsldir 'bin/applytopup --imain=' filestocorrect{i}(1:end-4) '_split' sprintf('%04d',vol) ' --inindex=1 --topup=' outpath 'epi_topup_results --datain=' outpath 'epi_acq_param.txt --method=jac --out=' filestocorrect{i}(1:end-length(splitpath{end})) 'topup_' splitpath{end}(1:end-4) '_split' sprintf('%04d',vol) ' --verbose'];
        system(cmd);
    end
    
    cmd = [fsldir 'bin/fslmerge -t ' outpath 'topup_' splitpath{end} ' ' filestocorrect{i}(1:end-length(splitpath{end})) 'topup_' splitpath{end}(1:end-4) '_split*'];
    system(cmd);
end
disp('Topup applied')