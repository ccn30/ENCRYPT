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
# using N4 corrected whole brain T1 from mp2rage reconstruction

T1=${T1path}/n4mag0000_PSIR_skulled_std.nii
T1brainmask=${T1path}/n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
denoiseT1=${T1path}/denoise_masked_n4mag0000_PSIR_skulled_std.nii

echo "Running DenoiseImage on: " ${T1path}

if [ -f "${denoiseT1}" ]; then
		echo $subject "already denoised whole"
	else
		$antsroot/DenoiseImage -d 3 -i $T1 -o $denoiseT1 -v 1 -x $T1brainmask
fi

