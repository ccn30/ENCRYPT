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
# 1. Running for original images (whole brain T1, raw T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $T2

#originaloutput=${outputpath}/original
#cd $originaloutput

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${wholeT1} -f ${T2} -w ${originaloutput}

#######################################################
# 2. Running for N4 T2 (whole T1, N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

#N4T2output=${outputpath}/N4T2
#cd $N4T2output

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${wholeT1} -f ${N4T2} -w ${N4T2output}

#######################################################
# 3. Running for brain T1 (brain T1, N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

#brainT1output=${outputpath}/T1BrainN4T2
#mkdir -p $brainT1output
#cd $brainT1output
#mkdir affine_t1_to_template
#cd affine_t1_to_template
#cp ${coregDir}/t1_to_template_affineMAG.mat t1_to_template_affine.mat
#cp ${coregDir}/t1_to_template_affine_invMAG.mat t1_to_template_affine_inv.mat
#cp ${coregDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz t1_to_template_affine.nii.gz
#cd ..

# run ASHS
#$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $Magdeburgatlasdir -g ${brainT1} -f ${N4T2} -w ${brainT1output} -N

#######################################################
# 4. Running for denoised T1 and T2 (denoise whole T1, denoise N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" ${DenoiseWholeT1} ${DenoiseN4T2}
echo "Registration copied from:" ${coregDir}

#denoiseoutput=${outputpath}/DenoiseWT1DenoiseT2
#mkdir -p $denoiseoutput
cd $outputpath
mkdir affine_t1_to_template
cd affine_t1_to_template
cp ${coregDir}/t1_to_template_affineMAG.mat t1_to_template_affine.mat
cp ${coregDir}/t1_to_template_affine_invMAG.mat t1_to_template_affine_inv.mat
cp ${coregDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz t1_to_template_affine.nii.gz
cd $workdir

# run ASHS
$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $MagAtlasDir -g ${DenoiseWholeT1} -f ${DenoiseN4T2} -w ${outputpath} -N -T


