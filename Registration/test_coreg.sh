#! /bin/sh
# called by coreg_templateMasksxEPI

echo "You are inside ANTs call"
which antsRegistration

regDir=${1}
groupTemplateDir=${2}
studyTemplateDir=${3}
T1xTempAffine=${4}
T1xTempInvWarp=${5}

echo " 	T1 to template warp ${T1xTempAffine}"

studyTemplate=${studyTemplateDir}/Study_template_wholeBrain.nii
alEC_left=${studyTemplateDir}/alEC_PRCpref_left.nii
alEC_right=${studyTemplateDir}/alEC_PRCpref_right.nii
pmEC_left=${studyTemplateDir}/pmEC_PHCpref_left.nii
pmEC_right=${studyTemplateDir}/pmEC_PHCpref_right.nii

## Perform mask x EPI transformation

# test study brain to epi transformation
		antsApplyTransforms -d 3 \
				-i ${studyTemplateDir}/Study_template_wholeBrain.nii \
				-r ${regDir}/N4meanEPI.nii \
				-o ${regDir}/studyBrainxEPI_Warped.nii.gz \
				-n Linear \
				-t ${regDir}/T1xepiSlab0GenericAffine.mat \
				-t [${T1xTempAffine},1] \
				-t ${T1xTempInvWarp} \
				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
				-v 1 
