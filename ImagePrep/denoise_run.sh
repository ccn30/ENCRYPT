#!/bin/bash
# submit ANTS/DenoiseImage to slurm

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
scriptdir=${pathstem}/scripts/ImagePrep
submitT1=${scriptdir}/denoiseT1_submit.sh
submitT2=${scriptdir}/denoiseT2_submit.sh

#!mysubjs=${pathstem}/master_subjsdeflist.txt
mysubjs=${pathstem}/testsubjcode.txt

# this script must be called from script dir where a slurmoutputs folder must be
cd slurmoutputs

for subjID in `cat $mysubjs`
do
	echo "Submitting T1 denoising for:	$subjID"
	sbatch ${submitT1} ${scriptdir} ${pathstem} ${subjID}
	
#!	echo "Submitting T2 N4 and denoising for:	$subjID"
#!	sbatch ${submitT2} ${scriptdir} ${pathstem} ${subjID}

done
