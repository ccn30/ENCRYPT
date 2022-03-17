#!/bin/bash
# call by gridsubmit.sh
# change paths to spm and gridcat below

data2table=${1}
taskDirstem=${2}
subjects=${3}
mainfunc=${4}
fmriDirstem=${5}
regDirstem=${6} # is mask dir
subjIdx=${7}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

echo "******** starting $subject ********"

echo 'You are inside gridcatprepare'

cwd=$(pwd)
cd ${regDirstem}/${subject}	
gunzip *
cd ${cwd}

# make paths subject specific
fmriDir=${fmriDirstem}/$subject/fMRI
regDir=${regDirstem}/$subject
taskDir=${taskDirstem}/$subject

# call matlab
MATLABPATH=/usr/local/Cluster-Apps/matlab/R2017b

"$MATLABPATH"/bin/matlab -nodesktop -nosplash -nodisplay <<EOF

% extract data into event tables by calling GCAP_logfile2eventtable.m
%[pa,af,~]=fileparts('${data2table}');
%disp(['Subject is ${subject}']);
%addpath(pa);
%addpath(pwd);
%dofunc=sprintf('%s(%s)',af,'''${taskDir}''');
%disp(['Submitting the following command: ' dofunc])
%eval(dofunc)
%disp('Done.')
%disp(' ')

% call main GridCAT function
[pa,af,~]=fileparts('${mainfunc}');
addpath(pa);
addpath(pwd);
addpath('/home/ccn30/rds/hpc-work/WBIC_home/GridCAT');
addpath('/usr/local/software/spm/spm12');
addpath('/home/ccn30/rds/hpc-work/WBIC_home/Documents/MATLAB/Add-Ons/Collections/Circular Statistics Toolbox (Directional Statistics)/code');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1ST ITERATION

% what type of mask to use - main or control?
warp_flag = 'main'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'pmRightMaass'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_pmRight6_hybridMaass'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2ND ITERATION

% what type of mask to use - main or control?
warp_flag = 'main'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'pmLeftMaass'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_pmLeft6_hybridMaass'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3RD ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'alRightMaass'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_alRight6_hybridMaass'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'alLeftMaass'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_alLeft6_hybridMaass'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'HCtailR'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_HCtail_right'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'HCtailL'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_HCtail_left'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 7TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'main'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'pmRightDTI'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_pmRight6_DTImasked'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 8TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'main'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'pmLeftDTI'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_pmLeft6_DTImasked'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 9TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'alRightDTI'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_alRight6_DTImasked'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 10TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'alLeftDTI'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.3'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_alLeft6_DTImasked'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

EOF
