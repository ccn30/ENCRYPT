#!/bin/bash
# standalone script to coregister any images
# c3d tool to make itk compatible

subjects=${1}
subjIdx=${2}
outDir=${3}
MagAtlasDir=${4}

#for subject in `cat $mysubjs`
#do
#subject="$(cut -d'/' -f1 <<<"$subjID")"

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

echo "******** starting $subject ********"

## set paths to images
rawpathstem=$outDir/ENCRYPT_images/$subject
regDir=$outDir/ENCRYPT_registrations/$subject

T2path=${rawpathstem}/T2/t2.nii
N4T2=${rawpathstem}/T2/N4t2.nii
wholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
#epi
DenoiseWholeT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
DenoiseN4T2=${rawpathstem}/T2/denoise_N4t2.nii

#UtrechtTemplate=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template.nii.gz
#UtrechtTempBrain=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template_bet.nii.gz
MagdeburgTemplate=$MagAtlasDir/template/template.nii.gz
MagdeburgTempBrain=$MagAtlasDir/template/template_bet.nii.gz


## Make dirs
if [ -f "${regDir}" ]; then
	echo "${regDir} exists"
else
	mkdir -p ${regDir}
fi

cd ${regDir}


#######################
### T1 to template ####
#######################
# utrecht template should be moving image as lower resolution than t1, vv for magdeburg

#antsRegistrationSyNQuick.sh -d 3 -f ${UtrechtTemplate} -m ${DenoiseWholeT1} -o T1xUtrechtTemp_ANTsQuickSyN_

# tailored full ANTs reg call for T1 to ASHS template
antsRegistration -d 3 \
-o [T1WholexMagdeburgTempWhole_ANTs_,T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz,T1WholexMagdeburgTempWhole_ANTs_InvWarped.nii.gz] \
-n Linear \
-w [0.005,0.995] \
-u 1 \
-r [${MagdeburgTemplate},${DenoiseWholeT1},1] \
-t Rigid[0.1] \
-m MI[${MagdeburgTemplate},${DenoiseWholeT1},1,32,Regular,0.25] \
-c [1000x500x250x100,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-t Affine[0.1] \
-m MI[${MagdeburgTemplate},${DenoiseWholeT1},1,32,Regular,0.25] \
-c [1000x500x250x100,1e-6,10] \
-f 8x4x2x1 \
-s 3x2x1x0vox \
-v

## c3d tool to invert, make itk ASHS compatible and rename (for brain only images)
/home/ccn30/privatemodules/c3d/bin/c3d_affine_tool -itk T1WholexMagdeburgTempWhole_ANTs_0GenericAffine.mat -o t1_to_template_affineMAG.mat
/home/ccn30/privatemodules/c3d/bin/c3d_affine_tool t1_to_template_affineMAG.mat -inv -o t1_to_template_affine_invMAG.mat


#################
### T1 to T2 ####
#################

antsRegistrationSyNQuick.sh -d 3 -f ${N4T2} -m ${wholeT1} -o T1xT2_ANTs -t a

antsApplyTransforms -d 3 \
			-i ${N4T2} \
			-r ${wholeT1} \
			-o T2xT1Warped_affine.nii.gz \
			-n Linear \
			-t [T1xT2_ANTs0GenericAffine.mat,1] \
			-v


#rm core

#done
