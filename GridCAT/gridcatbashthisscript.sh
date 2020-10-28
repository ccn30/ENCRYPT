#!/bin/bash
#! submit gridcat to slurm

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot
scriptdir=${pathstem}/scripts/gridcat

submit=${scriptdir}/gridcatsubmit.sh
prepare=${scriptdir}/gridcatprepare.sh
func=${scriptdir}/GridCAT_mainfunc.m

mysubjs=${pathstem}/master_subjsdeflist.txt
#!subjID=29382/20190911_U-ID46164

cd slurmoutputs

for subjID in `cat $mysubjs`
do
	subject="$(cut -d'/' -f1 <<<"$subjID")"
	echo "Calculating gridCAT metrics for:	$subject"
	sbatch ${submit} ${prepare} ${subject} ${func} ${scriptdir}
done	
