#!/bin/bash
# called from coreg_SubmitArray
# script to coregister any images - all paths here
# c3d tool to make itk compatible

subjects=${1}
subjIdx=${2}
outDir=${3}
scriptDir=${4}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

echo "******** starting $subject ********"

## set paths to input images

rawpathstem=$outDir/ENCRYPT_images/$subject
regDir=$outDir/ENCRYPT_registrations/$subject
groupTempDir=$outDir/ENCRYPT_template
maskDir=$outDir/ENCRYPT_MTLmasks/$subject
MagAtlasDir=/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/atlases/magdeburgatlas
MaassTempDir=/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/atlases/templates/ECtemplatemasks2015
DTITempDir=/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/atlases/templates/ECtemplatemasks2021

# T1 and T2
T2path=${rawpathstem}/T2/t2.nii
N4T2=${rawpathstem}/T2/N4t2.nii
wholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
#Denoised
DenoiseWholeT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
DenoiseN4T2=${rawpathstem}/T2/denoise_N4t2.nii

# EPI
meanRun1=${rawpathstem}/fMRI/meantopup_run1.nii
N4meanRun1=${rawpathstem}/fMRI/N4meanEPI.nii

# Templates
#Group
groupTemp=$groupTempDir/ENCRYPT_ants55template.nii.gz
#ASHS
MagdeburgTemplate=$MagAtlasDir/template/template.nii.gz
MagdeburgTempBrain=$MagAtlasDir/template/template_bet.nii.gz
#Maass
MaassTemp=$MaassTempDir/Study_template_wholeBrain.nii
Maass_alEC_left=$MaassTempDir/alEC_PRCpref_left.nii
Maass_alEC_right=$MaassTempDir/alEC_PRCpref_right.nii
Maass_pmEC_left=$MaassTempDir/pmEC_PHCpref_left.nii
Maass_pmEC_right=$MaassTempDir/pmEC_PHCpref_right.nii
Maass_combinedEC_right=$MaassTempDir/rightEC_combined.nii.gz
Maass_combinedEC_left=$MaassTempDir/leftEC_combined.nii.gz
#DTI
DTITemp=$DTITempDir/mni152_t1_nlin_asym_09b_hires_brain.nii.gz
DTI_pmEC=$DTITempDir/MEC_combinedGroupSegmentation_unmasked_mni.nii.gz
DTI_alEC=$DTITempDir/LEC_combinedGroupSegmentation_unmasked_mni.nii.gz


# Registrations
T1xGroupTempAffine=$(ls -d ${groupTempDir}/ants55${subject}_t1*0GenericAffine.mat)
T1xGroupTempInvWarp=$(ls -d ${groupTempDir}/ants55${subject}_t1*1InverseWarp.nii.gz)
T1xGroupTempWarp=$(ls -d ${groupTempDir}/ants55${subject}_t1*1Warp.nii.gz)
T1xT2Affine=${regDir}/T1xT2_ANTs0GenericAffine.mat
T1xEPIAffine=${regDir}/T1xepiSlab0GenericAffine.mat
GroupTempxMaassTempAffine=${groupTempDir}/ENCRYPT_ants55templatexMaassTemplateQ_0GenericAffine.mat
GroupTempxMaassTempInvWarp=${groupTempDir}/ENCRYPT_ants55templatexMaassTemplateQ_1InverseWarp.nii.gz
GroupTempxDTITempAffine=${groupTempDir}/ENCRYPT_ants55templatexDTITemplateQ_0GenericAffine.mat
GroupTempxDTITempInvWarp=${groupTempDir}/ENCRYPT_ants55templatexDTITemplateQ_1InverseWarp.nii.gz

## Make dirs
if [ -f "${maskDir}" ]; then
	echo "${maskDir} exists"
else
	mkdir -p ${maskDir}
fi

cd ${maskDir}


###########################
### T1 to ASHS template ###
###########################
# utrecht template should be moving image as lower resolution than t1, vv for magdeburg

#antsRegistrationSyNQuick.sh -d 3 -f ${UtrechtTemplate} -m ${DenoiseWholeT1} -o T1xUtrechtTemp_ANTsQuickSyN_

# tailored full ANTs reg call for T1 to ASHS template
#antsRegistration -d 3 \
#-o [T1WholexMagdeburgTempWhole_ANTs_,T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz,T1WholexMagdeburgTempWhole_ANTs_InvWarped.nii.gz] \
#-n Linear \
#-w [0.005,0.995] \
#-u 1 \
#-r [${MagdeburgTemplate},${DenoiseWholeT1},1] \
#-t Rigid[0.1] \
#-m MI[${MagdeburgTemplate},${DenoiseWholeT1},1,32,Regular,0.25] \
#-c [1000x500x250x100,1e-6,10] \
#-f 8x4x2x1 \
#-s 3x2x1x0vox \
#-t Affine[0.1] \
#-m MI[${MagdeburgTemplate},${DenoiseWholeT1},1,32,Regular,0.25] \
#-c [1000x500x250x100,1e-6,10] \
#-f 8x4x2x1 \
#-s 3x2x1x0vox \
#-v

## c3d tool to invert, make itk ASHS compatible and rename (for brain only images)
#/home/ccn30/privatemodules/c3d/bin/c3d_affine_tool -itk T1WholexMagdeburgTempWhole_ANTs_0GenericAffine.mat -o t1_to_template_affineMAG.mat
#/home/ccn30/privatemodules/c3d/bin/c3d_affine_tool t1_to_template_affineMAG.mat -inv -o t1_to_template_affine_invMAG.mat


#################
### T1 to T2 ####
#################

#antsRegistrationSyNQuick.sh -d 3 -f ${N4T2} -m ${wholeT1} -o T1xT2_ANTs -t a

#antsApplyTransforms -d 3 \
#			-i ${N4T2} \
#			-r ${wholeT1} \
#			-o T2xT1Warped_affine.nii.gz \
#			-n Linear \
#			-t [T1xT2_ANTs0GenericAffine.mat,1] \
#			-v


#################
### T1 to EPI ###
#################

# outputs
maskImage=${rawpathstem}/fMRI/fixedEPIMask.nii
fixedImageN4=${rawpathstem}/fMRI/N4meanEPI.nii
outputPrefix=${regDir}/T1xepiSlab
# inputs
fixedImage=$meanRun1
movingImage=$brainT1

# call ANTs script

#${scriptDir}/ANTs_T1xEPI.sh ${fixedImage} ${fixedImageN4} ${movingImage} ${maskImage} ${regDir} ${outputPrefix} | tee ${scriptDir}/slurmoutputs/ANTs_T1xEPI_${subject}_log.txt


############################
### Maass EC masks to T2 ###
############################

# combined EC L+R registration Maass mask to T2

# outputs
MaassLeftEC_combined_warped=$maskDir/combinedEC_left_Maass_T2.nii.gz
MaassRightEC_combined_warped=$maskDir/combinedEC_right_Maass_T2.nii.gz
MaassTempxT2=$regDir/MaassTempxT2_Warped.nii.gz
		#left
		antsApplyTransforms -d 3 \
				-i ${Maass_combinedEC_left} \
				-r ${N4T2} \
				-o ${MaassLeftEC_combined_warped} \
				-n GenericLabel \
				-t ${T1xT2Affine} \
				-t [${T1xGroupTempAffine},1] \
				-t ${T1xGroupTempInvWarp} \
				-t [$GroupTempxMaassTempAffine,1] \
				-t $GroupTempxMaassTempInvWarp \
				-v 1 
		#right
		antsApplyTransforms -d 3 \
				-i ${Maass_combinedEC_right} \
				-r ${N4T2} \
				-o ${MaassRightEC_combined_warped} \
				-n GenericLabel \
				-t ${T1xT2Affine} \
				-t [${T1xGroupTempAffine},1] \
				-t ${T1xGroupTempInvWarp} \
				-t [$GroupTempxMaassTempAffine,1] \
				-t $GroupTempxMaassTempInvWarp \
				-v 1 

# test warp Maass study template brain to T2
		antsApplyTransforms -d 3 \
				-i ${MaassTemp} \
				-r ${N4T2} \
				-o ${MaassTempxT2} \
				-n Linear \
				-t ${T1xT2Affine} \
				-t [${T1xGroupTempAffine},1] \
				-t ${T1xGroupTempInvWarp} \
				-t [$GroupTempxMaassTempAffine,1] \
				-t $GroupTempxMaassTempInvWarp \
				-v 1 

##########################
### DTI EC masks to T2 ###
##########################

# combined pm/alEC DTI mask to T2

# outputs
DTIpmEC_combinedSide_warped=$maskDir/combined_pmEC_DTI_T2.nii.gz
DTIalEC_combinedSide_warped=$maskDir/combined_alEC_DTI_T2.nii.gz
DTITempxT2=$regDir/DTITempxT2_Warped.nii.gz
		
		#pmEC
		antsApplyTransforms -d 3 \
				-i ${DTI_pmEC} \
				-r ${N4T2} \
				-o ${DTIpmEC_combinedSide_warped} \
				-n GenericLabel \
				-t ${T1xT2Affine} \
				-t [${T1xGroupTempAffine},1] \
				-t ${T1xGroupTempInvWarp} \
				-t [$GroupTempxDTITempAffine,1] \
				-t $GroupTempxDTITempInvWarp \
				-v 1 
		#alEC
		antsApplyTransforms -d 3 \
				-i ${DTI_alEC} \
				-r ${N4T2} \
				-o ${DTIalEC_combinedSide_warped} \
				-n GenericLabel \
				-t ${T1xT2Affine} \
				-t [${T1xGroupTempAffine},1] \
				-t ${T1xGroupTempInvWarp} \
				-t [$GroupTempxDTITempAffine,1] \
				-t $GroupTempxDTITempInvWarp \
				-v 1 

# test warp DTI study template brain to T2
		antsApplyTransforms -d 3 \
				-i ${DTITemp} \
				-r ${N4T2} \
				-o ${DTITempxT2} \
				-n Linear \
				-t ${T1xT2Affine} \
				-t [${T1xGroupTempAffine},1] \
				-t ${T1xGroupTempInvWarp} \
				-t [$GroupTempxDTITempAffine,1] \
				-t $GroupTempxDTITempInvWarp \
				-v 1 
##############################
### Hybrid T2 masks to EPI ###
##############################
