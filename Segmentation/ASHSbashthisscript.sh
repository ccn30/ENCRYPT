#!/bin/bash
# submit ASHS to slurm
# this script must be called from ASHS script dir where a slurmoutputs folder must be
# this script calls ASHS_mainfunc and ASHS_submit

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
scriptdir=${pathstem}/scripts/Segmentation
submit=${scriptdir}/ASHS_submit.sh

# separate txt file with subject and date IDs
#!mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

cd slurmoutputs

for subjID in `cat $mysubjs`
do
	echo "Submitting ASHS segmentation of:	$subjID"
	sbatch ${submit} ${scriptdir} ${pathstem} ${subjID}
done

