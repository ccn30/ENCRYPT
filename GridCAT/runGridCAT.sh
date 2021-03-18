#!/bin/bash
#! submit extraction and gridcat to slurm

# set dirs
pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
scriptDir=${pathstem}/scripts/GridCAT
taskDir=${pathstem}/task_data/gridtask
fmriDir=${pathstem}/fMRI
regDir=${pathstem}/registrations

# set files
data2table=${scriptDir}/GCAP_logfile2eventTable.m
submit=${scriptDir}/gridcatsubmit.sh
prepare=${scriptDir}/gridcatprepare.sh
mainfunc=${scriptDir}/GridCAT_mainfunc.m

# set subjects
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt
mysubjs=${pathstem}/testsubjcode.txt

for subjID in `cat $mysubjs`
do
	subject="$(cut -d'/' -f1 <<<"$subjID")"
	echo "**** starting $subject ****"
	
	# unzip masks
	cd ${regDir}/${subject}	
	gunzip *
	cd ${scriptDir}/slurmoutputs

	# run gridCAT
	sbatch ${submit} ${prepare} ${data2table} ${taskDir} ${subject} ${mainfunc} ${scriptDir} ${fmriDir} ${regDir}

done	
