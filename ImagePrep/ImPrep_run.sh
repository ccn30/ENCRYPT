#!/bin/bash
###########################################################################################
#! Prepare raw DICOMs from HPHI - convert to NIFTIs, rename for MP2RAGE and EPI processing
#! CN Sep 2020
###########################################################################################

echo "Inside ImPrep_run..."
MATLABPATH=/usr/local/Cluster-Apps/matlab/r2019a

#! initialise parent paths
func=${1}
subjects=${2} 
subjIdx=${3}  
rawimgdir=${4} 
outimgdir=${5}
scriptdir=${6}

mysubjs=($(<${subjects}))
RIScode=${mysubjs[${subjIdx}]}

cd ${scriptdir}

#! matlab call
echo "RUNNING IMAGE PREP FOR:	$subjID"
"$MATLABPATH"/bin/matlab -nodesktop -nosplash -nodisplay -r "try, image_prepare_func('${rawimgdir}','${outimgdir}',${RIScode}); end ; quit"
