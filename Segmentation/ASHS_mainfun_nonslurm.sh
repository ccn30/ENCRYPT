#!/bin/bash

# arguments from ASHS_submit.sh
scriptdir=${1}
pathstem=${2}
subjID=${3}

# initialise software roots
export ASHS_ROOT=/home/ccn30/privatemodules/ASHS_original/ashs-fastashs_beta
export atlasdir=/home/ccn30/ENCRYPT/atlases/magdeburgatlas

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
rawpathstem=${pathstem}/images/${subjID}
outputpath=${pathstem}/segmentation/ASHS/nonslurm/${subject}

cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${workdir}

#------------------------------------------------------------------------#
# Run ASHS					 			 #
#------------------------------------------------------------------------#

wholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii

T2=${T2path}/t2.nii
N4T2=${T2path}/n4_t2.nii
DenoiseN4T2=${T2path}/denoise_n4_t2.nii

if [ -f "${outputpath}" ]; then
		echo "${outputpath} exists"
	else
		mkdir ${outputpath}
fi


