#!/bin/bash

# arguments from denoise_submit.sh
pathstem=${1}
subjID=${2}
workdir=${3}

# initialise software roots
module load ANTS/2.2.0
export antsroot=/applications/ANTS/2.2.0/bin

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
imagedir=${pathstem}/images/${subjID}

cd ${imagedir}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${imagedir}/${T2dir}

echo "Subject is: " ${subject}
echo "T2 is: " ${T2path}

cd ${workdir} 

#------------------------------------------------------------------------#
# N4 Bias field correct T2					 	 #
#------------------------------------------------------------------------#
T2=${T2path}/t2.nii
N4T2=${T2path}/n4_t2.nii
newN4T2=${T2path}/n42_t2.nii

N4BiasFieldCorrection -d 3 -i ${T2} -o ${newN4T2}

#!if [ -f "${N4T2}" ]; then
#!		echo "N4 T2 already exists"
#!	else
#!		N4BiasFieldCorrection -d 3 -i ${T2} -o ${N4T2}  -r 1 -c [50x50x30x20,1e-6] -b [200];
#!fi

if [ -f "${N4T2}" ]; then
		echo "N4 correction complete"
	else
		echo "N4 correction failed"
fi

#------------------------------------------------------------------------#
# Denoise T2					 		 #
#------------------------------------------------------------------------#
# using N4 corrected T2

denoiseT2=${T2path}/denoise_n4_t2.nii
newdenoiseT2=${T2path}/denoise_n42_t2.nii

echo "Running DenoiseImage on: " ${T2path}

$antsroot/DenoiseImage -d 3 -i $newN4T2 -o $newdenoiseT2 -v 1

#!if [ -f "${denoiseT2}" ]; then
#!		echo $subject "already denoised"
#!	else
#!		$antsroot/DenoiseImage -d 3 -i $N4T2 -o $denoiseT2 -v 1
#!fi

if [ -f "${denoiseT2}" ]; then
		echo "DenoiseImage complete"
	else
		echo "DenoiseImage failed"
fi
