#!/bin/sh
# called by coreg_templateMasksxSubjectSpace

echo "You are inside ANTs call"
which antsRegistration

regDir=${1}
groupTemplateDir=${2}
studyTemplateDir=${3}
T1xTempAffine=${4}
T1xTempInvWarp=${5}
T1=${6}

echo " 	T1 to template warp ${T1xTempAffine}"

alEC_left=${studyTemplateDir}/alEC_PRCpref_left.nii
alEC_right=${studyTemplateDir}/alEC_PRCpref_right.nii
pmEC_left=${studyTemplateDir}/pmEC_PHCpref_left.nii
pmEC_right=${studyTemplateDir}/pmEC_PHCpref_right.nii

combinedEC_right=${studyTemplateDir}/rightEC_combined.nii.gz
combinedEC_left=${studyTemplateDir}/leftEC_combined.nii.gz

#t1xepi=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/registrations/6.11.20/26795/T1brainxEpiSlab0GenericAffine.mat

workdir=$(pwd)
cd ${regDir}
rm core
rm pmEC_leftxT1.nii
cd ${workdir}

## Perform mask x EPI transformation

# alEC left
#		antsApplyTransforms -d 3 \
#				-i ${alEC_left} \
#				-r ${regDir}/N4meanEPI.nii \
#				-o ${regDir}/alEC_leftxEPI.nii.gz \
#				-n GenericLabel \
#				-t ${t1xepi} \
#				-t [${T1xTempAffine},1] \
#				-t ${T1xTempInvWarp} \
#				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
#				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
#				-v 1 

# alEC right
#		antsApplyTransforms -d 3 \
#				-i ${alEC_right} \
#				-r ${regDir}/N4meanEPI.nii \
#				-o ${regDir}/alEC_rightxEPI.nii.gz \
#				-n GenericLabel \
#				-t ${t1xepi} \
#				-t [${T1xTempAffine},1] \
#				-t ${T1xTempInvWarp} \
#				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
#				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
#				-v 1 

# pmEC right
#		antsApplyTransforms -d 3 \
#				-i ${pmEC_right} \
#				-r ${regDir}/N4meanEPI.nii \
#				-o ${regDir}/pmEC_rightxEPI.nii.gz \
#				-n GenericLabel \
#				-t ${t1xepi} \
#				-t [${T1xTempAffine},1] \
#				-t ${T1xTempInvWarp} \
#				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
#				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
#				-v 1 

# pmEC left
#		antsApplyTransforms -d 3 \
#				-i ${pmEC_left} \
#				-r ${regDir}/N4meanEPI.nii \
#				-o ${regDir}/pmEC_leftxEPI.nii.gz \
#				-n GenericLabel \
#				-t ${t1xepi} \
#				-t [${T1xTempAffine},1] \
#				-t ${T1xTempInvWarp} \
#				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
#				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
#				-v 1 


# combinedEC_left registration mask to T1
		
		antsApplyTransforms -d 3 \
				-i ${combinedEC_left} \
				-r ${T1} \
				-o ${regDir}/leftEC_MaassMasksxT1.nii.gz \
				-n GenericLabel \
				-t [${T1xTempAffine},1] \
				-t ${T1xTempInvWarp} \
				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
				-v 1 
		
		antsApplyTransforms -d 3 \
				-i ${combinedEC_right} \
				-r ${T1} \
				-o ${regDir}/rightEC_MaassMasksxT1.nii.gz \
				-n GenericLabel \
				-t [${T1xTempAffine},1] \
				-t ${T1xTempInvWarp} \
				-t [${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat,1] \
				-t ${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz \
				-v 1 
