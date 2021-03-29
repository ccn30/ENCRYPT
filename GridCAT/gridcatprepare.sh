#!/bin/bash
# call by gridsubmit.sh

data2table=${1}
taskDir=${2}
subject=${3}
mainfunc=${4}
fmriDir=${5}
regDir=${6}

echo 'You are inside gridcatprepare'

# call matlab

matlab -nodesktop -nosplash -nodisplay <<EOF

% extract data into event tables by calling GCAP_logfile2eventtable.m
%[pa,af,~]=fileparts('${data2table}');
disp(['Subject is ${subject}']);
%addpath(pa);
%addpath(pwd);
%dofunc=sprintf('%s(%s,%s)',af,'''${subject}''','''${taskDir}''');
%disp(['Submitting the following command: ' dofunc])
%eval(dofunc)
%disp('Done.')
%disp(' ')

% call main GridCAT function
[pa,af,~]=fileparts('${mainfunc}');
addpath(pa);
addpath(pwd);
addpath('/home/ccn30/GridCAT');
addpath('/applications/spm/spm12_6906');
addpath('/home/ccn30/Documents/MATLAB/Add-Ons/Collections/Circular Statistics Toolbox (Directional Statistics)/code');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1ST ITERATION

% what type of mask to use - main or control?
warp_flag = 'main'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'pmRight'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.1'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_pmRight6_hybrid'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2ND ITERATION

% what type of mask to use - main or control?
warp_flag = 'main'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'pmLeft'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.1'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_pmLeft6_hybrid'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3RD ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'alRight'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.1'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_alRight6_hybrid'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4TH ITERATION

% what type of mask to use - main or control?
warp_flag = 'control'

% use with main above pmLeft,pmRight or control above PosHipp,alRight,alLeft- ROI mask?
ROI_flag = 'alLeft'

% 4,5,6,7 or 8 fold symmetry?
xFold = '6'

% SPM mask threshold for GLM
mask_thresh = '0.1'

% Which type of regressor should be included for grid events?
    %   'pmod' ... one regressor with a parametric modulation
    %   'aligned_misaligned' ... one regressor for events that are aligned with the mean grid orientation
    %                            and one regressor for misaligned events
    %   'aligned_misaligned_multiple' ... one regressor for each orientation, for which either a positive peak (for aligned events)
    %                                     or a negative peak (for misaligned events) in the BOLD signal is expected
regressor_flag = 'pmod'

% Name of output file
outfilename = 'gridCAT_alLeft6_hybrid'

dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${subject}''','''${fmriDir}''','''${taskDir}''','''${regDir}''','outfilename','ROI_flag','warp_flag','xFold','mask_thresh','regressor_flag');
disp(['Submitting the following command: ' dofunc]);
eval(dofunc);
disp('Done');
EOF
