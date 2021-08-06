#!/bin/bash
# wrapper script to call PIT_xml2csv.m via SLURM submission and PIT_xml2csv_runMatlab
# makes single .csv result file per subject

cd slurmoutputs
pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT

## separate txt file with subject and date IDs
mysubjs=${pathstem}/testsubjcode.txt
#mysubjs=${pathstem}/ENCRYPT_MasterCBcodes.txt

## set paths
xmlDir=${pathstem}/task_data/PIT/raw_data
resultsDir=${pathstem}/results/PIT
scriptDir=${pathstem}/scripts/PIT
submit=${scriptDir}/PIT_submit.sh
run=${scriptDir}/PIT_xml2csv_runMatlab.sh
func=${scriptDir}/PIT_xml2csv.m

for CBcode in `cat $mysubjs`
do

echo "******** starting $CBcode ********"

sbatch ${submit} ${run} ${func} ${scriptDir} ${xmlDir} ${resultsDir} ${CBcode}

done
