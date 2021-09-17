#!/bin/bash
# standalone script to coregister subject T1 to Utrecht template (for ASHS input)
# c3d tool to make itk compatible

module unload fsl
module load fsl/6.0.3
module unload ANTS
module load ANTS/2.3.4

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## separate txt file with subject and date IDs

#mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## set paths

rawpathstem=${pathstem}/images/${subjID}
regDir=${pathstem}/registrations/${subject}

cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${regDir}

wholeT1=${rawpathstem}/mp2rage/Rn4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/Rdenoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/Rdenoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii


UtrechtTemplate=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template.nii.gz
UtrechtTempBrain=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template_bet.nii.gz
MagdeburgTemplate=/home/ccn30/ENCRYPT/atlases/magdeburgatlas/template/template.nii.gz
MagdeburgTempBrain=/home/ccn30/ENCRYPT/atlases/magdeburgatlas/template/template_bet.nii.gz


## ANTs commands
# utrecht template should be moving image as lower resolution than t1, vv for magdeburg

#antsRegistrationSyNQuick.sh -d 3 -f ${UtrechtTemplate} -m ${DenoiseWholeT1} -o T1xUtrechtTemp_ANTsQuickSyN_

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
#rm core

done
