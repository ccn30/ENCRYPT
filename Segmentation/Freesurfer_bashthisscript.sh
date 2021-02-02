#!/bin/bash
# submit Freesurfer to slurm
# this wrapper script must be called from Freesurfer script dir where a slurmoutputs folder must be
# this wrapper script calls function and SLURM submission scripts

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
scriptdir=${pathstem}/scripts/Segmentation
submit=${scriptdir}/Freesurfer_submit.sh

# separate txt file with subject and date IDs
mysubjs=${pathstem}/testsubjcode.txt
#!mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

cd slurmoutputs

for subjID in `cat $mysubjs`
do
	echo "Submitting Freesurfer segmentation of:	$subjID"
	sbatch ${submit} ${scriptdir} ${pathstem} ${subjID}
done

