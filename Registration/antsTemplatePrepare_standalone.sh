#!/bin/bash

pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt
scriptdir=${pathstem}/scripts/Registration
templatedir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_template

echo "Making template dir"
if [ -f "${templatedir}" ]; then
	echo "${templatedir} exists"
else
	mkdir ${templatedir}
fi 

cd ${templatedir}

for subjID in `cat $mysubjs`
do
wholet1=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_images/$subjID/mp2rage/n4mag0000_PSIR_skulled_std.nii
cpT1=$subjID"_t1.nii"

cp $wholet1 $cpT1

done


