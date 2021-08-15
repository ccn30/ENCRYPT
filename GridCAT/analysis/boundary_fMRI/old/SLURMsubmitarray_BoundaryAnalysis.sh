#!/bin/bash
# SLURM job array submission 

#pathstem=$1
#script=$2
#func=$3
#subjs_def=$4
#subjectNo=$5

#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J boundaryAnalysiss
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
#SBATCH --time=00:01:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#! RAM is allocated in ~5980mb blocks, you are charged per block used,
#! and unused fractions of blocks will not be usable by others.
#SBATCH --mem=5980mb
#! How many jobs to submit (starting at 0)?
#! NOTE: This must be a range, not a single number (i.e. 0-2 = 3 jobs, but '3' would just be one job index '3')
#SBATCH --array=0-2

#! This is the partition name.
#SBATCH -p skylake

#! mail alert at start, end and abortion of execution
#! emails will default to going to your email address
#! you can specify a different email address manually if needed.
##SBATCH --mail-type=ALL

#! Don't put any #SBATCH directives below this line

#! Modify the environment seen by the application. For this example we need the default modules.
. /etc/profile.d/modules.sh                # This line enables the module command
module purge                               # Removes all modules still loaded
module load rhel7/default-peta4            # REQUIRED - loads the basic environment

#! The variable $SLURM_ARRAY_TASK_ID contains the array index for each job.
#! In this example, each job will be passed its index, so each output file will contain a different value
echo "This is job" $SLURM_ARRAY_TASK_ID
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"

#workdir=

#! Command line that we want to run for each job $SLURM_ARRAY_TASK_ID (i.e.0,1,2,3...)
subjIdx=$SLURM_ARRAY_TASK_ID

pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/scripts/GridCAT/analysis/boundary_fMRI
script=$pathstem/runMatlab_BoundaryAnalysis.sh
func=$pathstem/runBoundaryAnalysis.m
subjs_def=$pathstem/ENCRYPT_subjects_parameters.m

#mysubjs=($(</home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/ENCRYPT_MasterCBcodes.txt))
#subject=${mysubjs[${index}]}

CMD="$script $func $subjs_def $subjIdx"
eval $CMD
# then rewrite child script to take subjIdx e.g.0 and use that to index ENCRYPT_subject_parameters, may haveto +1 in matlab because starts with 0


