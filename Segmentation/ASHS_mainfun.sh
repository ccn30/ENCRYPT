#!/bin/bash

# arguments from ASHS_SubmitArray.sh
subjects=${1} 
subjIdx=${2} 
imageDir=${3} 
ASHSDir=${4} 
ASHSmodule=${5} 
MagAtlasDir=${6}
workdir=${7}
regDir=${8}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

# initialise software roots
export antsroot=/usr/local/software/spack/spack-git/opt/spack/linux-rhel7-broadwell/gcc-5/ants-2.3.4-lj6vm7ccmij4yywr4ynrttcko4aoflqt/bin
export ASHS_ROOT=/home/ccn30/privatemodules/ASHS/ashs-fastashs_beta

# initialise subject-wise paths (CHECK ATLAS)
imageDirSubj=${imageDir}/${subject}
outputpath=${ASHSDir}/${subject}
coregDir=${regDir}/${subject}

T2path=${imageDirSubj}/T2/t2.nii
N4T2=${imageDirSubj}/T2/N4t2.nii
wholeT1=${imageDirSubj}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${imageDirSubj}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
#epi
DenoiseWholeT1=${imageDirSubj}/mp2rage/denoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${imageDirSubj}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
DenoiseN4T2=${imageDirSubj}/T2/denoise_N4t2.nii

#UtrechtTemplate=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template.nii.gz
#UtrechtTempBrain=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template_bet.nii.gz
MagdeburgTemplate=$MagAtlasDir/template/template.nii.gz
MagdeburgTempBrain=$MagAtlasDir/template/template_bet.nii.gz

# manually remove existing ones 
if [ -f "${outputpath}" ]; then
		echo "${outputpath} exists"
	else
		mkdir -p ${outputpath}
fi


#------------------------------------------------------------------------#
# Run ASHS					 			 #
#------------------------------------------------------------------------#
# changing to reorientated T1s and updated N4 T2s after poor performance first batch ASHS


#######################################################
# 1. Running for denoised T1 and T2 (denoise whole T1, denoise N4 T2), manual reg for T1 to template
#echo "Beginning ASHS for: " $subject
#echo "INPUT:" ${DenoiseWholeT1} ${DenoiseN4T2}
#echo "Registration copied from:" ${coregDir}

#denoiseoutput=${outputpath}/DenoiseWT1DenoiseT2
#mkdir -p $denoiseoutput
#cd $outputpath
#mkdir affine_t1_to_template
#cd affine_t1_to_template
#cp ${coregDir}/t1_to_template_affineMAG.mat t1_to_template_affine.mat
#cp ${coregDir}/t1_to_template_affine_invMAG.mat t1_to_template_affine_inv.mat
#cp ${coregDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz t1_to_template_affine.nii.gz
#cd $workdir

# run ASHS
#$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $MagAtlasDir -g ${DenoiseWholeT1} -f ${DenoiseN4T2} -w ${outputpath} -N -T

#######################################################
# 2. Running for denoised T1 and T2 (denoise whole T1, denoise N4 T2), manual reg for T1 to template and T1 to T2
echo "Beginning ASHS for: " $subject
echo "INPUT:" ${DenoiseWholeT1} ${DenoiseN4T2}
echo "Registration copied from:" ${coregDir}

cd $outputpath
mkdir affine_t1_to_template
cd affine_t1_to_template
cp ${coregDir}/t1_to_template_affineMAG.mat t1_to_template_affine.mat
cp ${coregDir}/t1_to_template_affine_invMAG.mat t1_to_template_affine_inv.mat
cp ${coregDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz t1_to_template_affine.nii.gz
cd ..
#mkdir flirt_t2_to_t1
#cd flirt_t2_to_t1
/home/ccn30/privatemodules/c3d/bin/c3d_affine_tool -itk $coregDir/T1xT2_ANTs0GenericAffine.mat -o $coregDir/flirt_t2_to_t1.mat
#/home/ccn30/privatemodules/c3d/bin/c3d_affine_tool flirt_t2_to_t1.mat -inv -o flirt_t2_to_t1_inv.mat
T1T2reg=$coregDir/flirt_t2_to_t1.mat
cd $workdir

# run ASHS
$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $MagAtlasDir -g ${DenoiseWholeT1} -f ${DenoiseN4T2} -w ${outputpath} -m $T1T2reg -M -N -T


