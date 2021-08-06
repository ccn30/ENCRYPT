#!/bin/bash

# arguments from PIT_submit.sh, from PIT_xml2csv_runAll

func=${1}
subjects=${2} 
subjIdx=${3}  
xmlDir=${4} 
resultsDir=${5}

mysubjs=($(<${subjects}))
CBcode=${mysubjs[${subjIdx}]}

pwd
echo $CBcode
# matlab call

matlab -nodesktop -nosplash -nodisplay <<EOF
[pa,af,~]=fileparts('${func}');
addpath(pa);
addpath(pwd);
dofunc=sprintf('%s(%s,%s,%s)',af,'''${CBcode}''','''${xmlDir}''','''${resultsDir}''');
disp(['Matlab submitting the following command: ' dofunc])
eval(dofunc)
;exit
EOF
