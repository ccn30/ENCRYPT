#!/bin/bash
# submit Freesurfer to slurm
# this wrapper script must be called from Freesurfer script dir where a slurmoutputs folder must be
# this wrapper script calls function and SLURM submission scripts

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
scriptdir=${pathstem}/scripts/Registration
submit=${scriptdir}/antsTemplateConstruct_submit.sh
templatedir=${pathstem}/images/template01

# separate txt file with subject and date IDs
#!mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

# make template dir

echo "Making template dir"
if [ -f "${templatedir}" ]; then
	echo "${templatedir} exists"
else
	mkdir ${templatedir}
fi 

#cd ${templatedir}

#for subjID in `cat $mysubjs`
#do
wholet1=${pathstem}/images/$subjID/mp2rage/n4mag0000_PSIR_skulled_std.nii
subject="$(cut -d'/' -f1 <<<"$subjID")"
cpT1=$subject"_t1.nii"

#cp $wholet1 $cpT1

#done

# submit template construction

cd $scriptdir/slurmoutputs

echo "Submitting ants template construction"
sbatch ${submit} ${scriptdir} ${templatedir}

