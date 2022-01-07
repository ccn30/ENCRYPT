#!/bin/bash

# SLURM job array submission
# NB CALL IN TERMINAL WITH SBATCH COMMAND

#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J girdCAT
#! Account name for group, use SL2 for paying queue:
#SBATCH -A OBRIEN-SL3-CPU
#! Output filename:
#! %A means slurm job ID and %a means array index
#SBATCH --output=job_%A_%a.out
#! Errors filename:
#SBATCH --error=job_%A_%a.err

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task. (for single core jobs always leave this at 1)
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? (for single core jobs always leave this at 1)
#SBATCH --cpus-per-task=1
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=03:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#! RAM is allocated in ~5980mb blocks, you are charged per block used,
#! and unused fractions of blocks will not be usable by others.
#SBATCH --mem=5980mb
#! How many jobs to submit (starting at 0)?
#! NOTE: This must be a range, not a single number (i.e. 0-2 = 3 jobs, but '3' would just be one job index '3')
#SBATCH --array=0-0

#! This is the partition name - skylake or cclake
#SBATCH -p cclake

#! mail alert at start, end and abortion of execution
#! emails will default to going to your email address
#! you can specify a different email address manually if needed.
##SBATCH --mail-type=ALL

#! sbatch directives end here (put any additional directives above this line)

#! Modify the environment seen by the application. For this example we need the default modules.
. /etc/profile.d/modules.sh                # This line enables the module command
module purge                               # Removes all modules still loaded
module load rhel7/default-ccl            # REQUIRED - loads the basic environment /default-peta4 or default-ccl
module unload matlab
module load matlab/matlab20197b

#! The variable $SLURM_ARRAY_TASK_ID contains the array index for each job.
#! In this example, each job will be passed its index, so each output file will contain a different value
echo "This is job" $SLURM_ARRAY_TASK_ID
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"


#! Command line that we want to run for each job $SLURM_ARRAY_TASK_ID (i.e.0,1,2,3...)

subjIdx=$SLURM_ARRAY_TASK_ID

#! Set paths

#! set dirs
pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
rdspathstem=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500
scriptDir=${pathstem}/scripts/GridCAT
taskDir=${pathstem}/task_data/gridtask
fmriDir==${rdspathstem}/ENCRYPT_images/$subject/fMRI
maskDir=${rdspathstem}/ENCRYPT_MTLmasks/$subject

#! set files
data2table=${scriptDir}/GCAP_logfile2eventTable.m
prepare=${scriptDir}/gridcatprepare.sh
mainfunc=${scriptDir}/GridCAT_mainfunc.m

#! set subjects
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt
mysubjs=${pathstem}/testsubjcode.txt

#! Work directory (i.e. where the job will run):
workdir=$scriptdir/slurmoutputs

application="${prepare} ${data2table} ${taskDir} ${mysubjs} ${mainfunc} ${fmriDir} ${maskDir} ${subjIdx}"

CMD="${application}"

###############################################################
### You should not have to change anything below this line ####
###############################################################

cd $workdir
echo -e "Changed directory to `pwd`.\n"

JOBID=$SLURM_JOB_ID

echo -e "JobID: $JOBID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"

if [ "$SLURM_JOB_NODELIST" ]; then
        #! Create a machine file:
        export NODEFILE=`generate_pbs_nodefile`
        cat $NODEFILE | uniq > machine.file.$JOBID
        echo -e "\nNodes allocated:\n================"
        echo `cat machine.file.$JOBID | sed -e 's/\..*$//g'`
fi

echo -e "\nnumtasks=$numtasks, numnodes=$numnodes, mpi_tasks_per_node=$mpi_tasks_per_node (OMP_NUM_THREADS=$OMP_NUM_THREADS)"

echo -e "\nExecuting command:\n==================\n$CMD\n"

eval $CMD
