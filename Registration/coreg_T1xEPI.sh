#!/bin/bash
# script to coregister EPIs (mean topup corrected image run 1) to T1

module unload ANTS
module load ANTS/2.3.4

## separate txt file with subject and date IDs

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
#mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## set paths

movingImage=${pathstem}/images/${subjID}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
fixedImage=${pathstem}/fMRI/${subject}/meantopup_Run_1.nii

regDir=${pathstem}/registrations/${subject}
echo "Making registration dir"
if [ -f "${regDir}" ]; then
	echo "${regDir} exists"
else
	mkdir ${regDir}
fi

maskImage=${regDir}/fixedEPIMask.nii
fixedImageN4=${regDir}/N4meanEPI.nii

cd slurmoutputs
echo "working on subject ${subject} in ${pwd}"

## call ANTs

${pathstem}/scripts/Registration/ANTs_T1xEPI.sh ${fixedImage} ${fixedImageN4} ${movingImage} ${maskImage} ${regDir} | tee ${pathstem}/scripts/Registration/slurmoutputs/ANTs_T1xEPI_${subject}_log.txt

done
