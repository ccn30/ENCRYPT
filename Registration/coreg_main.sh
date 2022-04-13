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
#Rescaled
rescaledWholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_rescaled.nii

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
DTI_pmEC_masked=$DTITempDir/MEC_combinedGroupSegmentation_masked_mni.nii.gz
DTI_alEC_masked=$DTITempDir/LEC_combinedGroupSegmentation_masked_mni.nii.gz

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

# T2 ROI Masks
#right
ASHS_T2_R=${maskDir}/"$subject"_right_lfseg_corr_usegray_noCysts_clean.nii.gz
HybridMaass_T2_R=${maskDir}/combinedEC_right_HybridMaass_T2.nii.gz
HybridDTI_T2_R=${maskDir}/pmEC_right_HybridDTI_T2.nii.gz
#left
ASHS_T2_L=${maskDir}/"$subject"_left_lfseg_corr_usegray_noCysts_clean.nii.gz
HybridMaass_T2_L=${maskDir}/combinedEC_left_HybridMaass_T2.nii.gz
HybridDTI_T2_L=${maskDir}/pmEC_left_HybridDTI_T2.nii.gz



## Make dirs
if [ -f "${maskDir}" ]; then
	echo "${maskDir} exists"
else
	mkdir -p ${maskDir}
fi

cd ${maskDir}

## Rescale T1s - Xiali Chen command from Marianna help query
#c3d ${wholeT1} -stretch 0.0% 99.99999999999% 0 65535 -clip 0 65535 -o ${rescaledWholeT1}




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

#cd ${regDir}

#antsRegistrationSyNQuick.sh -d 3 -f ${DenoiseWholeT1} -m ${DenoiseN4T2} o T1xT2_ANTs -t a

#antsApplyTransforms -d 3 \
#			-i ${N4T2} \
#			-r ${wholeT1} \
#			-o T2xT1Warped_affine.nii.gz \
#			-n Linear \
#			-t [T1xT2initial.txt,1] \
#			-v


#################
### T1 to EPI ###
#################

# outputs
#maskImage=${rawpathstem}/fMRI/fixedEPIMask.nii
#fixedImageN4=${rawpathstem}/fMRI/N4meanEPI.nii
#outputPrefix=${regDir}/T1xepiSlab
# inputs
#fixedImage=$meanRun1
#movingImage=$brainT1

# call ANTs script

#${scriptDir}/ANTs_T1xEPI.sh ${fixedImage} ${fixedImageN4} ${movingImage} ${maskImage} ${regDir} ${outputPrefix} | tee ${scriptDir}/slurmoutputs/ANTs_T1xEPI_${subject}_log.txt


############################
### Maass EC masks to T2 ###
############################

# combined EC L+R registration Maass mask to T2
# use manual .txt file for 25869
#T1xT2Affine=${regDir}/T1xT2_ITK.txt

# outputs
#MaassLeftEC_combined_warped=$maskDir/combinedEC_left_Maass_T2.nii.gz
#MaassRightEC_combined_warped=$maskDir/combinedEC_right_Maass_T2.nii.gz
#MaassTempxT2=$regDir/MaassTempxT2_Warped.nii.gz
		#left
#		antsApplyTransforms -d 3 \
#				-i ${Maass_combinedEC_left} \
#				-r ${N4T2} \
#				-o ${MaassLeftEC_combined_warped} \
#				-n GenericLabel \
#				-t ${T1xT2Affine} \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxMaassTempAffine,1] \
#				-t $GroupTempxMaassTempInvWarp \
#				-v 1 
#		#right
#		antsApplyTransforms -d 3 \
#				-i ${Maass_combinedEC_right} \
#				-r ${N4T2} \
#				-o ${MaassRightEC_combined_warped} \
#				-n GenericLabel \
#				-t ${T1xT2Affine} \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxMaassTempAffine,1] \
#				-t $GroupTempxMaassTempInvWarp \
#				-v 1 

# test warp Maass study template brain to T2
#		antsApplyTransforms -d 3 \
#				-i ${MaassTemp} \
#				-r ${N4T2} \
#				-o ${MaassTempxT2} \
#				-n Linear \
#				-t ${T1xT2Affine} \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxMaassTempAffine,1] \
#				-t $GroupTempxMaassTempInvWarp \
#				-v 1 

##########################
### DTI EC masks to T2 ###
##########################

# combined pm/alEC DTI mask to T2

# outputs
#DTIpmEC_combinedSide_warped=$maskDir/combined_pmEC_DTI_T2.nii.gz
#DTIalEC_combinedSide_warped=$maskDir/combined_alEC_DTI_T2.nii.gz
#DTITempxT2=$regDir/DTITempxT2_Warped.nii.gz
		
		#pmEC
#		antsApplyTransforms -d 3 \
#				-i ${DTI_pmEC} \
#				-r ${N4T2} \
#				-o ${DTIpmEC_combinedSide_warped} \
#				-n GenericLabel \
#				-t ${T1xT2Affine} \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 
		#alEC
#		antsApplyTransforms -d 3 \
#				-i ${DTI_alEC} \
#				-r ${N4T2} \
#				-o ${DTIalEC_combinedSide_warped} \
#				-n GenericLabel \
#				-t ${T1xT2Affine} \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 

# test warp DTI study template brain to T2
#		antsApplyTransforms -d 3 \
#				-i ${DTITemp} \
#				-r ${N4T2} \
#				-o ${DTITempxT2} \
#				-n Linear \
#				-t ${T1xT2Affine} \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 



##########################
### DTI EC masks to T1 ###
##########################

# combined pm/alEC DTI mask to T1 rescaled

# outputs
#DTIpmEC_combinedSide_warpedT1=$maskDir/combined_pmEC_DTI_T1.nii.gz
#DTIalEC_combinedSide_warpedT1=$maskDir/combined_alEC_DTI_T1.nii.gz
#DTIpmEC_masked_combinedSide_warpedT1=$maskDir/combined_pmEC_DTImasked_T1.nii.gz
#DTIalEC_masked_combinedSide_warpedT1=$maskDir/combined_alEC_DTImasked_T1.nii.gz
		
		#pmEC unmasked
#		antsApplyTransforms -d 3 \
#				-i ${DTI_pmEC} \
#				-r ${rescaledWholeT1} \
#				-o ${DTIpmEC_combinedSide_warpedT1} \
#				-n GenericLabel \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 
		#alEC unmasked
#		antsApplyTransforms -d 3 \
#				-i ${DTI_alEC} \
#				-r ${rescaledWholeT1} \
#				-o ${DTIalEC_combinedSide_warpedT1} \
#				-n GenericLabel \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 
		#pmEC masked
#		antsApplyTransforms -d 3 \
#				-i ${DTI_pmEC_masked} \
#				-r ${wholeT1} \
#				-o $DTIpmEC_masked_combinedSide_warpedT1 \
#				-n GenericLabel \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 
		#alEC masked
#		antsApplyTransforms -d 3 \
#				-i ${DTI_alEC_masked} \
#				-r ${wholeT1} \
#				-o ${DTIalEC_masked_combinedSide_warpedT1} \
#				-n GenericLabel \
#				-t [${T1xGroupTempAffine},1] \
#				-t ${T1xGroupTempInvWarp} \
#				-t [$GroupTempxDTITempAffine,1] \
#				-t $GroupTempxDTITempInvWarp \
#				-v 1 


##############################
### Hybrid T2 masks to EPI ###
##############################


## if using manual .txt files
#T1xT2Affine=${regDir}/T1xT2_ITK.txt
#T1xEPIAffine=${regDir}/T1xepiSlab0GenericAffine.txt

# outputs
#right
ASHS_epi_R=${maskDir}/"$subject"_right_lfseg_corr_usegray_noCysts_clean_EPI.nii.gz
ASHS_HCtail_R=${maskDir}/ASHS_right_HCtail_EPI.nii.gz
ASHS_EC_R=${maskDir}/ASHS_right_EC_EPI.nii.gz
HybridMaass_epi_R=${maskDir}/combinedEC_right_HybridMaass_EPI.nii.gz
HybridMaassPM_epi_R=${maskDir}/pmEC_right_HybridMaass_EPI.nii.gz
HybridMaassAL_epi_R=${maskDir}/alEC_right_HybridMaass_EPI.nii.gz
HybridDTI_epi_R=${maskDir}/pmEC_right_HybridDTI_EPI.nii.gz
#left
ASHS_epi_L=${maskDir}/"$subject"_left_lfseg_corr_usegray_noCysts_clean_EPI.nii.gz
ASHS_HCtail_L=${maskDir}/ASHS_left_HCtail_EPI.nii.gz
ASHS_EC_L=${maskDir}/ASHS_left_EC_EPI.nii.gz
HybridMaass_epi_L=${maskDir}/combinedEC_left_HybridMaass_EPI.nii.gz
HybridMaassPM_epi_L=${maskDir}/pmEC_left_HybridMaass_EPI.nii.gz
HybridMaassAL_epi_L=${maskDir}/alEC_left_HybridMaass_EPI.nii.gz
HybridDTI_epi_L=${maskDir}/pmEC_left_HybridDTI_EPI.nii.gz

## warp ASHS T2 to EPI
# right
#		antsApplyTransforms -d 3 \
#				-i ${ASHS_T2_R} \
#				-r ${N4meanRun1} \
#				-o ${ASHS_epi_R}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-t [${T1xT2Affine},1] \
#				-v 1 
# left
#		antsApplyTransforms -d 3 \
#				-i ${ASHS_T2_L} \
#				-r ${N4meanRun1} \
#				-o ${ASHS_epi_L}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-t [${T1xT2Affine},1] \
#				-v 1 
## warp Hybrid Maass to EPI
# right
#		antsApplyTransforms -d 3 \
#				-i ${HybridMaass_T2_R} \
#				-r ${N4meanRun1} \
#				-o ${HybridMaass_epi_R}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-t [${T1xT2Affine},1] \
#				-v 1 
# left
#		antsApplyTransforms -d 3 \
#				-i ${HybridMaass_T2_L} \
#				-r ${N4meanRun1} \
#				-o ${HybridMaass_epi_L}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-t [${T1xT2Affine},1] \
#				-v 1 
## warp Hybrid DTI to EPI
# right
#		antsApplyTransforms -d 3 \
#				-i ${HybridDTI_T2_R} \
#				-r ${N4meanRun1} \
#				-o ${HybridDTI_epi_R}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-t [${T1xT2Affine},1] \
#				-v 1 
# left
#		antsApplyTransforms -d 3 \
#				-i ${HybridDTI_T2_L} \
#				-r ${N4meanRun1} \
#				-o ${HybridDTI_epi_L}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-t [${T1xT2Affine},1] \
#				-v 1 


###########################
### DTI T1 masks to EPI ###
###########################

# outputs
DTIpmEC_masked_combinedSide_warpedT1xEPI=$maskDir/combined_pmEC_DTImasked_T1xEPI.nii.gz
DTIalEC_masked_combinedSide_warpedT1xEPI=$maskDir/combined_alEC_DTImasked_T1xEPI.nii.gz
DTIpmEC_masked_R_warpedT1xEPI=$maskDir/pmEC_right_DTImasked_T1xEPI.nii.gz
DTIpmEC_masked_L_warpedT1xEPI=$maskDir/pmEC_left_DTImasked_T1xEPI.nii.gz
DTIalEC_masked_R_warpedT1xEPI=$maskDir/alEC_right_DTImasked_T1xEPI.nii.gz
DTIalEC_masked_L_warpedT1xEPI=$maskDir/alEC_left_DTImasked_T1xEPI.nii.gz

# txt file regs
#T1xEPIAffine=${regDir}/T1xepiSlab0GenericAffine.txt

# pmEC
#		antsApplyTransforms -d 3 \
#				-i ${DTIpmEC_masked_combinedSide_warpedT1} \
#				-r ${N4meanRun1} \
#				-o ${DTIpmEC_masked_combinedSide_warpedT1xEPI}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-v 1 
# alEC
#		antsApplyTransforms -d 3 \
#				-i ${DTIalEC_masked_combinedSide_warpedT1} \
#				-r ${N4meanRun1} \
#				-o ${DTIalEC_masked_combinedSide_warpedT1xEPI}  \
#				-n GenericLabel \
#				-t ${T1xEPIAffine} \
#				-v 1 


########################
### Label extraction ###
########################

# extract pm and alEC from Hybrid Maass and tail from ASHS
#fslmaths ${HybridMaass_epi_R} -thr 16.5 -uthr 17.5 -bin ${HybridMaassPM_epi_R} -odt char
#fslmaths ${HybridMaass_epi_R} -thr 17.5 -uthr 18.5 -bin ${HybridMaassAL_epi_R} -odt char
#fslmaths ${ASHS_epi_R} -thr 4.5 -uthr 5.5 -bin ${ASHS_HCtail_R} -odt char

#fslmaths ${HybridMaass_epi_L} -thr 16.5 -uthr 17.5 -bin ${HybridMaassPM_epi_L} -odt char
#fslmaths ${HybridMaass_epi_L} -thr 17.5 -uthr 18.5 -bin ${HybridMaassAL_epi_L} -odt char
#fslmaths ${ASHS_epi_L} -thr 4.5 -uthr 5.5 -bin ${ASHS_HCtail_L} -odt char

# extract L and R pm and alEC from DTI T1
#fslmaths ${DTIalEC_masked_combinedSide_warpedT1xEPI} -thr 0.5 -uthr 1.5 -bin ${DTIalEC_masked_R_warpedT1xEPI} -odt char # right = 1
#fslmaths ${DTIalEC_masked_combinedSide_warpedT1xEPI} -thr 1.5 -uthr 2.5 -bin ${DTIalEC_masked_L_warpedT1xEPI} -odt char # left = 2
#c3d ${DTIalEC_masked_L_warpedT1xEPI} -thresh 1.5 2.5 1 0 ${DTIalEC_masked_L_warpedT1xEPI} # make left mask value 1

#fslmaths ${DTIpmEC_masked_combinedSide_warpedT1xEPI} -thr 0.5 -uthr 1.5 -bin ${DTIpmEC_masked_R_warpedT1xEPI} -odt char # right = 1
#fslmaths ${DTIpmEC_masked_combinedSide_warpedT1xEPI} -thr 1.5 -uthr 2.5 -bin ${DTIpmEC_masked_L_warpedT1xEPI} -odt char # left  = 2
#c3d ${DTIpmEC_masked_L_warpedT1xEPI} -thresh 1.5 2.5 1 0 ${DTIpmEC_masked_L_warpedT1xEPI} # make left mask value 1

# extract EC from ASHS and combine into single mask
ASHS_EC=${maskDir}/ASHS_EC_EPI.nii.gz
fslmaths ${ASHS_epi_R} -thr 8.5 -uthr 9.5 -bin ${ASHS_EC_R} -odt char
fslmaths ${ASHS_epi_L} -thr 8.5 -uthr 9.5 -bin ${ASHS_EC_L} -odt char
c3d ${ASHS_EC_R} ${ASHS_EC_L} -add -o ${ASHS_EC}
