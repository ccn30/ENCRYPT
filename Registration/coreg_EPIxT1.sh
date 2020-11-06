#!/bin/bash
# script to coregister EPIs (mean topup corrected image run 1) to T1
# tried 1) T1 to EPI with EPI mask using forum command 2) then rigid only no mask 3) then with applytransforms instead of warped output 4) padded EPIs 5) EPI moving to T1

module unload ANTS
module load ANTS/2.3.4
#export ANTSPATH=/applications/ANTS/ANTs-2.3.4/install/bin/
#export PATH=${ANTSPATH}:$PATH
which antsRegistration

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## separate txt file with subject and date IDs

mysubjs=${pathstem}/testsubjcode.txt
#!mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## 1. fixed epi, moving T1

movingImage=${pathstem}/images/${subjID}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
#movingImage=${pathstem}/images/${subjID}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
fixedImage=${pathstem}/fMRI/${subject}/meantopup_Run_1.nii

## or 2. fixed T1, moving EPI

#movingImage=${pathstem}/fMRI/${subject}/meantopup_Run_1.nii
#fixedImage=${pathstem}/images/${subjID}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii

regDir=${pathstem}/registrations/${subject}
echo "Making registration dir"
if [ -f "${regDir}" ]; then
	echo "${regDir} exists"
else
	mkdir ${regDir}
fi

cd ${regDir}
echo "working on subject ${subject} in ${pwd}"

## bias field correct EPI

N4correctedEPI=${pathstem}/fMRI/${subject}/N4_meantopup_Run_1.nii

#N4BiasFieldCorrection -d 3 -i ${fixedImage} -o ${N4correctedEPI} -b [100] -c [200x200x200x200,0] -v 1 -s 4

fixedImage=${N4correctedEPI}

## pad EPI with 25 voxels

#fixedImagePadded=${pathstem}/fMRI/${subject}/meantopup_Run_1_padded25.nii
#movingImagePadded=${pathstem}/fMRI/${subject}/meantopup_Run_1_padded25.nii
#maskImagePadded=${regDir}/fixedEpiMaskPadded25.nii

#ImageMath 3 ${fixedImagePadded} PadImage ${fixedImage} 25


## make mask of slab image

maskImage=${regDir}/N4fixedEpiMask100.nii

ThresholdImage 3 ${fixedImage} ${maskImage} 100 Inf
#ThresholdImage 3 ${fixedImagePadded} ${maskImagePadded} 1100 Inf


## Register T1 to EPI slab with mask

#outputPrefix=${regDir}/T1xEpiSlab
#outputPrefix=${regDir}/T1brainxEpiSlab
#outputPrefix=${regDir}/T1brainxEpiSlabPadded25
#outputPrefix=${regDir}/EpiSlabxT1brain
#outputPrefix=${regDir}/T1brainxEpiSlab_newANTs
#outputPrefix=${regDir}/T1brainxEpiSlab_DenoiseN4Update_
#outputPrefix=${regDir}/T1brainxEpiSlab_N4v2_
outputPrefix=${regDir}/T1brainxEpiSlab_N4mask100_

## insert ants command here
# switched mask around for EPI to T1 and removed 'padded' inputs
# updated command from Nick Tustison email

antsRegistration --verbose 1 \
                 --dimensionality 3 \
                 --float 0 \
                 --interpolation Linear \
                 --use-histogram-matching 0 \
                 --winsorize-image-intensities [0.005,0.995] \
                 --output [${outputPrefix},${outputPrefix}Warped.nii.gz,${outputPrefix}InverseWarped.nii.gz] \
                 --initial-moving-transform [${fixedImage},${movingImage},1] \
                 --transform translation[0.2] \
                   --metric MI[${fixedImage},${movingImage},1,32,Random,0.5] \
                   --convergence [400x200x100,1e-6,10] \
                   --shrink-factors 8x4x2 \
                   --smoothing-sigmas 0x0x0vox \
                   --masks [${maskImage},NULL] \
                 --transform Rigid[0.2] \
                   --metric MI[${fixedImage},${movingImage},1,32,Random,0.5] \
                   --convergence [500x500x250x50,1e-6,10] \
                   --shrink-factors 6x4x2x1 \
                   --smoothing-sigmas 2x1x0x0vox \
                   --masks [${maskImage},NULL]

#antsApplyTransforms -d 3 -i ${movingImage} -o ${outputPrefix}Transformed.nii -r ${fixedImage} -t T1brainxEpiSlab0GenericAffine.mat

## test rigid only

#antsRegistration -d 3 -r [ ${fixedImage} , ${movingImage} , 1] -t Rigid[0.1] \
#-m MI[ ${fixedImage}, ${movingImage}, 1, 32] -c 0 -f 4 -s 2 \
#-o [${outputPrefix}_init, ${outputPrefix}_RigidDeformed.nii.gz] 

done
echo "Done"



