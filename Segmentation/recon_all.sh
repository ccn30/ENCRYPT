#!/bin/bash

# arguments from Freesurfer_submit.sh
pathstem=${1}
subjID=${2}
workdir=${3}

echo "You are in recon_all func"
echo $FREESURFER_HOME
echo $SUBJECTS_DIR

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
rawpathstem=${pathstem}/images/${subjID}

cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${workdir}

wholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/denoisen4mag0000_PSIR_skulled_std.nii

T2=${T2path}/t2.nii
N4T2=${T2path}/n4_t2.nii
DenoiseN4T2=${T2path}/denoise_n4_t2.nii

#------------------------------------------------------------------------#
# Run recon-all					 			 #
#------------------------------------------------------------------------#

# 1. Just whole T1
SUBJECTS_DIR=${pathstem}/segmentation/Freesurfer/T1only
export $SUBJECTS_DIR
echo "Set subject dir to  $SUBJECTS_DIR"
if [ -f "${SUBJECTS_DIR}" ]; then
		echo "${SUBJECTS_DIR} exists"
	else
		mkdir ${SUBJECTS_DIR}
fi
recon-all -s $subject -i $wholeT1 -qcache -all

# 2. whole T1 and T2
#!SUBJECTS_DIR=${pathstem}/segmentation/Freesurfer/T1T2both
#!export $SUBJECTS_DIR
echo "Set subject dir to  $SUBJECTS_DIR"
if [ -f "${SUBJECTS_DIR}" ]; then
		echo "${SUBJECTS_DIR} exists"
	else
		mkdir ${SUBJECTS_DIR}
fi
#!recon-all -s $subject -i $wholeT1 -T2 $N4T2 -T2pial -qcache -all

echo "DONE"

