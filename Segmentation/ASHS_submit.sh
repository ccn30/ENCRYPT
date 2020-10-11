#!/bin/bash
#!
#! Example SLURM job script for WBIC modified by ccn30 25.09.19 for ENCRYPT
#! Last updated: Mon Nov 07 16:30:00 BST 2016
#! By: Paul Browne (pfb29)

#!#############################################################
#!#### Modify the options in this section as appropriate ######
#!#############################################################

#! sbatch directives begin here ###############################
#! Name of the job:
#SBATCH -J ASHS
#! Which project should jobs run under:
#SBATCH -A hphi
#! How many whole nodes should be allocated?
#SBATCH --nodes=1
#! How many (MPI) task will there be in total? (<= nodes*24)
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#!SBATCH --mem-per-cpu=16384M
#! How much wallclock time will be required?
#SBATCH --time=5:00:00
#! What types of email messages do you wish to receive?
#SBATCH --mail-type=FAIL
#!SBATCH -p skylake-himem
#SBATCH --qos short.q
#SBATCH --mem=7000

# CHANGE ME IF YOU WANT TO BE EMAILED
#SBATCH --mail-user=ccn30
#! Uncomment this to prevent the job from being requeued (e.g. if
#! interrupted by node failure or system downtime):
#SBATCH --no-requeue

#! Do not change:
#SBATCH -p wbic-cs

#! sbatch directives end here (put any additional directives above this line)

#! Notes:
#! The --ntasks value refers to the number of tasks to be launched by SLURM only. This
#! usually equates to the number of MPI tasks launched. Reduce this from nodes*24 if
#! demanded by memory requirements, or if OMP_NUM_THREADS>1.

#! Each task is allocated 1 core by default, and each core is allocated 2500MB.
#! If this is insufficient, also specify --cpus-per-task and/or --mem (the latter specifies
#! MB per node).

#! Number of nodes and tasks per node allocated by SLURM (do not change):
numnodes=$SLURM_JOB_NUM_NODES
numtasks=$SLURM_NTASKS
mpi_tasks_per_node=$(echo "$SLURM_TASKS_PER_NODE" | sed -e  's/^\([0-9][0-9]*\).*$/\1/')

#! ############################################################
#! Modify the settings below to specify the application's environment, location
#! and launch method:

#! Optionally modify the environment seen by the application
#! (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):


. /etc/profile.d/modules.sh                # Leave this line (enables the module command)
module purge                               # Removes all modules still loaded
module load default-wbic                   # REQUIRED - loads the basic environment
module unload fsl
module load fsl/5.0.10
module load itksnap-nowrap/3.6.0
#!module load ASHS_FASTB
module load ANTS/2.2.0


#! Are you using OpenMP (NB this is unrelated to OpenMPI)? If so increase this
#! safe value to no more than 16:
export OMP_NUM_THREADS=1

#! Number of MPI tasks to be started by the application per node and in total (do not change):
np=$[${numnodes}*${mpi_tasks_per_node}]

#! The following variables define a sensible pinning strategy for Intel MPI tasks -
#! this should be suitable for both pure MPI and hybrid MPI/OpenMP jobs:
export I_MPI_PIN_DOMAIN=omp:compact # Domains are $OMP_NUM_THREADS cores in size
export I_MPI_PIN_ORDER=scatter # Adjacent domains have minimal sharing of caches/sockets
#! Notes:
#! 1. These variables influence Intel MPI only.
#! 2. Domains are non-overlapping sets of cores which map 1-1 to MPI tasks.
#! 3. I_MPI_PIN_PROCESSOR_LIST is ignored if I_MPI_PIN_DOMAIN is set.
#! 4. If MPI tasks perform better when sharing caches/sockets, try I_MPI_PIN_ORDER=compact.


# ASHS DIRECTIVES START HERE
# import $subjID, $pathstem and $rawpathstem from ASHS_complete.sh

scriptdir=${1}
pathstem=${2}
subjID=${3}

workdir="$scriptdir/slurmoutputs"

application="${scriptdir}/ASHS_mainfun.sh ${pathstem} ${subjID}"

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
