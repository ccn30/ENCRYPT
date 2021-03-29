#!/bin/bash

# arguments from PIT_submit.sh, from PIT_xml2csv_runAll

func=${1}
xmlDir=${2}
resultsDir=${3}
CBcode=${4}
pwd

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
