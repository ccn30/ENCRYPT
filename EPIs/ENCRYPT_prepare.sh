#!/bin/bash
#
#PBS -N Matlab
#PBS -m be 
#PBS -k oe
#We may have to include -nojvm or there is a memory error
#-nodesktop -nosplash -nodisplay -nojvm together work
#Some Matlab functions like gzip require java so cannot
#use -nojvm option

# copy and paste sections as you need, replace 'prevstep' and 'step'
 
date

func=$1
pathstem=$2
subjects=$3
subjIdx=$4 
fmriDir=$5

subjs=($(<${subjects}))
this_subj=${subjs[${subjIdx}]}


## CHUNK START ##
prevStep=raw
step=topup
clusterid="HPC"

echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#Matlab call
if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['fMRI dir is ${fmriDir}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${step}'])
dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi
## CHUNK END ##
## CHUNK START ##
prevStep=topup
step=realign
clusterid="HPC"

echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#Matlab call
if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['fMRI dir is ${fmriDir}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${step}'])
dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi
## CHUNK END ##
## CHUNK START ##
prevStep=topup
step=reslice
clusterid="HPC"

echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#Matlab call
if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['fMRI dir is ${fmriDir}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${step}'])
dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi
## CHUNK END ##
## CHUNK START ##
prevStep=reslice
step=smooth
clusterid="HPC"

echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#Matlab call
if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['fMRI dir is ${fmriDir}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${step}'])
dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi
## CHUNK END ##
## CHUNK START ##
prevStep=reslice
step=STC
clusterid="HPC"

echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#Matlab call
if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['fMRI dir is ${fmriDir}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${step}'])
dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi
## CHUNK END ##
## CHUNK START ##
prevStep=STC
step=smooth
clusterid="HPC"

echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"

#Matlab call
if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
then
matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
disp(['Path is ' pa])
disp(['Function is ' af])
disp(['fMRI dir is ${fmriDir}'])
disp(['Environment is ${clusterid}'])
disp(['Previous step is ${prevStep}'])
disp(['This step is ${step}'])
dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
disp(['Submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
fi
## CHUNK END ##


#prevstep=smooth
#step=sliceTimeCorrection
#clusterid="HPC"

#echo "The workspace going into this is ${func} ${this_subj} ${clusterid} ${prevStep} ${Step}"


#MATLAB CALL
#if [ "$clusterid" == "HPC" ] || [ "$clusterid" == "HPHI" ]
#then
#matlab -nodesktop -nosplash -nodisplay <<EOF
#[pa,af,~]=fileparts('${func}');
#addpath(pa);
#disp(['Path is ' pa])
#disp(['Function is ' af])
#disp(['fMRI dir is ${fmriDir}'])
#disp(['Environment is ${clusterid}'])
#disp(['Previous step is ${prevStep}'])
#disp(['This step is ${Step}'])
#dofunc=sprintf('%s(%s,%s,%s,%s,%s)',af,'''${step}''','''${prevStep}''','''${clusterid}''','''${fmriDir}''','${this_subj}');
#disp(['Submitting the following command: ' dofunc])
#eval(dofunc)
#;exit
#EOF
#fi


### old code

#do_definition_func=sprintf('%s','${subjs_def}')
#[pa2,af2,~] = fileparts(do_definition_func);
#addpath(pa2)
#eval(af2)
#addpath(pwd)
