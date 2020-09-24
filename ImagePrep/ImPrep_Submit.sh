#!/bin/bash
###########################################################################################
#! Prepare raw DICOMs from HPHI - convert to NIFTIs, rename for MP2RAGE and EPI processing
#! CN Sep 2020
###########################################################################################

#! initialise paths
MATLABPATH=/applications/matlab/matlab2017b/
imgdir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/images/
fsldir=/applications/fsl/fsl-5.0.10
scriptdir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts
submit=${scriptdir}/
func=${scriptdir}/

mysubjs=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/ENCRYPT_MasterRIScodes.txt

cd ${scriptdir}/ImagePrep

for subjID in `cat $mysubjs`
do
	subject="$(cut -d'/' -f1 <<<"$subjID")"
	dateID="$(cut -d'/' -f2 <<<"$subjID")"
	echo "Running image preparation function for:	$subjID"
	"$MATLABPATH"/bin/matlab.nowrap -nodesktop -nosplash -nodisplay -r "try, image_prepare_func('${imgdir}',${subject},'${dateID}'); end ; quit"

done
