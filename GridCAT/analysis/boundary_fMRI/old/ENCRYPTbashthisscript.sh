myscriptdir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts/EPIs
clusterid=HPHI

submit=${myscriptdir}/ENCRYPTsubmit_HPHI_short.sh
prepare=${myscriptdir}/ENCRYPT_prepare.sh
func=${myscriptdir}/ENCRYPT_preprocess_mainfunc_7T.m
subjs_def=${myscriptdir}/ENCRYPT_subjects_parameters.m


subjects_to_process=($(seq 1 1 18))
#!subjects_to_process=1

prevstep=raw
step=topup

jobIDs=""

cd slurmoutputs
for this_subj in ${subjects_to_process[@]}
do 
this_job_id=$(sbatch --parsable ${submit} ${prepare} ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevstep} ${step})
#! echo ${submit} ${prepare} ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevstep} ${step} #! for debug this will list all the sbatch submissions, to test, copy one line and paste after "sbatch "
jobIDs="$jobIDs $this_job_id"
done

echo "submitted job stage" ${step} "polling for output before moving on"
${myscriptdir}/waitForSlurmJobs.pl 1 120 $jobIDs
for this_job in ${jobIDs[@]}
do
this_job_outcome=$(sacct -j ${this_job} --format='State' -n)
job_state=`echo $this_job_outcome | awk '{print $1}'` 
if [ "$job_state" == "FAILED" ] 
    then
        echo "SLURM submission failed - jobs went into error state"
        exit 1;
fi
done

jobIDs=""
prevstep=topup
step=realign
for this_subj in ${subjects_to_process[@]}
do 
this_job_id=$(sbatch --parsable ${submit} ${prepare} ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevstep} ${step})
 echo ${submit} ${prepare} ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevstep} ${step} #! for debug this will list all the sbatch submissions, to test, copy one line and paste after "sbatch "
jobIDs="$jobIDs $this_job_id"
done

echo "submitted job stage" ${step} "polling for output before moving on"
${myscriptdir}/waitForSlurmJobs.pl 1 120 $jobIDs
for this_job in ${jobIDs[@]}
do
this_job_outcome=$(sacct -j ${this_job} --format='State' -n)
job_state=`echo $this_job_outcome | awk '{print $1}'` 
if [ "$job_state" == "FAILED" ] 
    then
        echo "SLURM submission failed - jobs went into error state"
        exit 1;
fi
done

jobIDs=""
prevstep=topup
step=reslice
for this_subj in ${subjects_to_process[@]}
do 
this_job_id=$(sbatch --parsable ${submit} ${prepare} ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevstep} ${step})
 echo ${submit} ${prepare} ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevstep} ${step} #! for debug this will list all the sbatch submissions, to test, copy one line and paste after "sbatch "
jobIDs="$jobIDs $this_job_id"
done

echo "submitted job stage" ${step} "polling for output before moving on"
${myscriptdir}/waitForSlurmJobs.pl 1 120 $jobIDs
for this_job in ${jobIDs[@]}
do
this_job_outcome=$(sacct -j ${this_job} --format='State' -n)
job_state=`echo $this_job_outcome | awk '{print $1}'` 
if [ "$job_state" == "FAILED" ] 
    then
        echo "SLURM submission failed - jobs went into error state"
        exit 1;
fi
done

cd ..
