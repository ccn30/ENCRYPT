#!/bin/sh
# called by GridCAT_MaskComparison.Rmd and coreg_MasksxSubjectSpace.sh
# coreg MTL in T2 space to EPI space in /home/ENCRYPT/segmentation, then extract pm/alEC and put in /lustre/scratch subject registration dir

echo "You are inside ANTs call"
which antsRegistration

subject=${1}
regDir=${2}
hybridmaskT2dir=${3}
T1xT2affine=${4}
T1xEPIaffine=${5}

# warp hybrid masks from T2 space to EPI space
rightMTLmag=${hybridmaskT2dir}/"$subject"_right_lfseg_corr_usegray_ECsubdivisions.nii.gz
rightMTLmagT2xEPI=${hybridmaskT2dir}/"$subject"_right_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz
rightpmECT2xEPI=${regDir}/pmEC_right_Magdeburg_HybridMaskT2xEPI.nii
rightalECT2xEPI=${regDir}/alEC_right_Magdeburg_HybridMaskT2xEPI.nii

leftMTLmag=${hybridmaskT2dir}/"$subject"_left_lfseg_corr_usegray_ECsubdivisions.nii.gz
leftMTLmagT2xEPI=${hybridmaskT2dir}/"$subject"_left_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz
leftpmECT2xEPI=${regDir}/pmEC_left_Magdeburg_HybridMaskT2xEPI.nii
leftalECT2xEPI=${regDir}/alEC_left_Magdeburg_HybridMaskT2xEPI.nii

# MTL segmentation T2 x EPI
		antsApplyTransforms -d 3 \
				-i ${rightMTLmag} \
				-r ${regDir}/N4meanEPI.nii \
				-o ${rightMTLmagT2xEPI} \
				-n GenericLabel \
				-t ${T1xEPIaffine} \
				-t [${T1xT2affine},1] \
				-v 1 

		antsApplyTransforms -d 3 \
				-i ${leftMTLmag} \
				-r ${regDir}/N4meanEPI.nii \
				-o ${leftMTLmagT2xEPI} \
				-n GenericLabel \
				-t ${T1xEPIaffine} \
				-t [${T1xT2affine},1] \
				-v 1 

# extract pm and alEC and put in lustre/scratch segmentation subject dir
fslmaths ${hybridmaskT2dir}/"$subject"_right_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz -thr 16.5 -uthr 17.5 -bin ${rightpmECT2xEPI} -odt char
fslmaths ${hybridmaskT2dir}/"$subject"_right_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz -thr 17.5 -uthr 18.5 -bin ${rightalECT2xEPI} -odt char

fslmaths ${hybridmaskT2dir}/"$subject"_left_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz -thr 16.5 -uthr 17.5 -bin ${leftpmECT2xEPI} -odt char
fslmaths ${hybridmaskT2dir}/"$subject"_left_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz -thr 17.5 -uthr 18.5 -bin ${leftalECT2xEPI} -odt char
