#!/bin/bash
# run mri_gcut on failed freesurfer subjects

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

# separate txt file with subject and date IDs
mysubjs=${pathstem}/testsubjcode.txt
#!mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
FreesurferDirMRI=${pathstem}/segmentation/Freesurfer/T1only/${subject}/mri

cd $FreesurferDirMRI
echo '####### starting ' $subject '#######'

# make copy of original brain mask
if [ ! -f "$FreesurferDirMRI/brainmask_orig.mgz" ]; then
	cp brainmask.mgz brainmask_orig.mgz
	echo "COPIED orig"
fi 

# run mri_gcut changing T flag between 0-1, 0 = more conservative 1 = more aggressive
if [ ! -f "$FreesurferDirMRI/brainmask.gcuts.mgz" ]; then
	mri_gcut -110 -mult brainmask.auto.mgz -T 0.1 T1.mgz brainmask.mgz brainmask.gcuts.mgz
else
	echo "GCUT ALREADY RUN"
fi

done
