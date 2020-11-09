#!/bin/bash
# wrapper script to call PIT_data2table.m
cd slurmoutputs
pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## separate txt file with subject and date IDs

#!mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterCBcodes.txt

## set paths

xmlDir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/task_data/PIT/raw_data
resultsDir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/PIT
scriptDir=${pathstem}/scripts/PIT
submit=${scriptDir}/PIT_submit.sh
run=${scriptDir}/PIT_raw2table_run.sh
func=${scriptDir}/PIT_raw2table.m

for CBcode in `cat $mysubjs`
do

echo "******** starting $CBcode ********"

sbatch ${submit} ${run} ${func} ${scriptDir} ${xmlDir} ${resultsDir} ${CBcode}

done
