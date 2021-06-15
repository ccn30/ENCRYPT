#!/bin/bash
#
#PBS -N Matlab
#PBS -m be 
#PBS -k oe
 
date

func=$1
subjs_def=$2
this_subj=$3 
clusterid=$4
prevStep=$5
Step=$6

echo "working on file ${this_subj}"
echo "The workspace going into this is ${func} ${subjs_def} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#INCLUDE MATLAB CALL

#We may have to include -nojvm or there is a memory error
#-nodesktop -nosplash -nodisplay -nojvm together work
#Some Matlab functions like gzip require java so cannot
#use -nojvm option

if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['Subject definition function is ${subjs_def}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${Step}'])
do_definition_func=sprintf('%s','${subjs_def}')
[pa2,af2,~] = fileparts(do_definition_func);
addpath(pa2)
eval(af2)
addpath(pwd)
rawpathstem = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/images'
preprocessedpathstem = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/fMRI'
dofunc=sprintf('%s(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)',af,'''${Step}''','''${prevStep}''','''${clusterid}''','preprocessedpathstem','rawpathstem','subjects','${this_subj}','fullid','basedir','blocksin','blocksin_folders','blocksout','minvols','group');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi

