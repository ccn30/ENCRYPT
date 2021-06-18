#!/bin/bash
#
#PBS -N Matlab
#PBS -m be 
#PBS -k oe
 
date

func=$1
subjs_def=$2
nSubjects=$3

echo "inside remote MATLAB call for $nSubjects subjects"

#INCLUDE MATLAB CALL

#We may have to include -nojvm or there is a memory error
#-nodesktop -nosplash -nodisplay -nojvm together work
#Some Matlab functions like gzip require java so cannot
#use -nojvm option

matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
do_definition_func=sprintf('%s','${subjs_def}')
[pa2,af2,~] = fileparts(do_definition_func);
addpath(pa2)
eval(af2)
addpath(pwd)
pathstem ='/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT';
taskDir='~/rds/hpc-work/WBIC_lustre/ENCRYPT/task_data/gridtask';
dofunc=sprintf('%s(%s,%s,%s)',af,'''${pathstem}''','''${taskDir}''','''${nSubjects}''');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi

