#!/bin/bash
#! submit extraction and gridcat to slurm

# set dirs
pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
rdspathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
scriptDir=${pathstem}/scripts/GridCAT
taskDir=${pathstem}/task_data/gridtask
fmriDir==${rdspathstem}/ENCRYPT_images/$subject/fMRI
maskDir=${rdspathstem}/ENCRYPT_MTLmasks/$subject

# set files
data2table=${scriptDir}/GCAP_logfile2eventTable.m
submit=${scriptDir}/gridcatsubmit.sh
prepare=${scriptDir}/gridcatprepare.sh
mainfunc=${scriptDir}/GridCAT_mainfunc.m

# set subjects
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt
mysubjs=${pathstem}/testsubjcode.txt

#for subjID in `cat $mysubjs`
#do
#	subject="$(cut -d'/' -f1 <<<"$subjID")"
#	echo "**** starting $subject ****"
	
	# unzip masks
	cd ${maskDir}/${subject}	
	gunzip *
	cd ${scriptDir}/slurmoutputs

	# run gridCAT
	sbatch ${submit} ${prepare} ${data2table} ${taskDir} ${subject} ${mainfunc} ${scriptDir} ${fmriDir} ${maskDir}

done	
