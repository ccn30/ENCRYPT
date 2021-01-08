#!/bin/bash
# coregister subject T1 to Utrecht template (for ASHS input)

module unload fsl
module load fsl/6.0.3
module unload ANTS
module load ANTS/2.3.4

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## separate txt file with subject and date IDs

mysubjs=${pathstem}/testsubjcode.txt
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## set paths

rawpathstem=${pathstem}/images/${subjID}
newRegDir=${pathstem}/registrations/${subject}

cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${regDir}

wholeT1=${rawpathstem}/mp2rage/Rn4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/Rdenoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/Rdenoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii


UtrechtTemplate=

## FSL commands

#flirt -v -in ${DenoiseWholeT1} -ref ${N4T2} -dof 3 -out T2xT1_rigid_init.nii -omat T1xT2_rigid_init.mat	
#flirt -in ${DenoiseWholeT1} -ref ${N4T2} -dof 6 -wmseg ${wm} -cost bbr -schedule /applications/fsl/fsl-6.0.3/etc/flirtsch/bbr.sch -init T1xT2_rigid_init.mat -omat T1xT2_BBR.mat -out T1xT2_BBR.nii 

## ANTs commands

#antsRegistrationSyNQuick.sh -d 3 -f ${N4T2} -m ${wholeT1} -o T1xT2_ANTs_

#antsApplyTransforms -d 3 \
#			-i ${N4T2} \
#			-r ${wholeT1} \
#			-o T2xT1Warped_affine.nii.gz \
#			-n Linear \
#			-t [T1xT2_ANTs_0GenericAffine.mat,1] \
#			-v

# quick script to copy images from old dir to new dir

files=${regDir}/T1xT2_ANTs_*

cp ${files} ${newRegDir}


done
