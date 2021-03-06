#!/bin/bash

# arguments from denoiseT1_submit.sh
pathstem=${1}
subjID=${2}
workdir=${3}

# initialise software roots
module load ANTS/2.2.0
export antsroot=/applications/ANTS/2.2.0/bin

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
imagedir=${pathstem}/images/${subjID}
T1path=${imagedir}/mp2rage
echo "Subject is: " ${subject}
echo "T1 is: " ${T1path}

#------------------------------------------------------------------------#
# Denoise MP2RAGES 					 		 #
#------------------------------------------------------------------------#
# using N4 corrected T1 from mp2rage reconstruction

# inputs
T1=${T1path}/n4mag0000_PSIR_skulled_std.nii
brainT1=${T1path}/n4mag0000_PSIR_skulled_std_struc_brain.nii
#!T1brainmask=${T1path}/n4mag0000_PSIR_skulled_std_struc_brain_mask.nii

# outputs
denoiseT1=${T1path}/denoise_n4mag0000_PSIR_skulled_std.nii
denoisebrainT1=${T1path}/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
# this is actually non-masked output

echo "Running DenoiseImage on: " ${T1path}

#!if [ -f "${denoiseT1}" ]; then
#!		echo $subject "already denoised whole"
#!	else
#!		$antsroot/DenoiseImage -d 3 -i $brainT1 -o $denoisebrainT1 -v 1 
		#! -x $T1brainmask (not using for now)
#!fi

#------------------------------------------------------------------------#
# Reorient MP2RAGES 					 		 #
#------------------------------------------------------------------------#
RdenoiseT1=${T1path}/Rdenoise_n4mag0000_PSIR_skulled_std.nii
RdenoiseT1brain=${T1path}/Rdenoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
RT1=${T1path}/Rn4mag0000_PSIR_skulled_std.nii

# denoise brain
fslreorient2std ${denoisebrainT1} ${RdenoiseT1brain}

# denoise whole 
fslreorient2std ${denoiseT1} ${RdenoiseT1}

# original whole
fslreorient2std ${T1} ${RT1}
