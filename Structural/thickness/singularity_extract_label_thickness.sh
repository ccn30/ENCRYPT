#!/bin/bash

pathstem=/home/mp2011/rds/hpc-work/wbic
index=${2}
mysubjs=($(<${pathstem}/Scripts/subjectsID.txt))
subj=${mysubjs[${index}]}

                                         ####### Submitting the singularity script extract_label_thickness #######

## scriptdir
dockerscript=/home/utils/extract_label_thickness.sh

## segmentation dir
maskT2=$pathstem/Masks/ECseg_T2_nocysts
maskT1=$pathstem/Masks/ECseg_T1_nocysts

output=/home/mp2011/rds/hpc-work/wbic/Masks/Thickness

echo "#### Beginning ASHS Extract Thickness pipeline for "$subj" ####"
 #-----------------------------------------------------------------------------------------------#

	### RUNNING SCRIPT ###

## T2 MASKS###
inleft=${maskT2}/labels/"$subj"_left_PM.nii.gz
inright=${maskT2}/labels/"$subj"_right_PM.nii.gz
OUTDIR=${output}/"$subj"/T2/labels/

if [ -f "${OUTDIR}" ]; then
		echo "${OUTDIR} exists"
	else
		mkdir ${OUTDIR}
fi

singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif /bin/bash ${dockerscript} -i ${inleft} -w ${OUTDIR}
singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif /bin/bash ${dockerscript} -i ${inright} -w ${OUTDIR}

#------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------#

### T1 MASKS ####
#inleft=${maskT1}/"$subj"_left_ECsubdivisions_nocysts.nii.gz
#inright=${maskT1}/"$subj"_right_ECsubdivisions_nocysts.nii.gz
#OUTDIR=${output}/"$subj"/T1/

	#if [ -f "${OUTDIR}" ]; then
		#echo "${OUTDIR} exists"
	#else
		#mkdir ${OUTDIR}
	#fi

#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif /bin/bash ${dockerscript} -i ${inleft} -w $OUTDIR
#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif /bin/bash ${dockerscript} -i ${inright} -w $OUTDIR

#---------------------------------------------------------------#
#----------------------------------------------------------------------------#

### T2 no subdivisions ###

#maskno=/home/mp2011/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ASHS_Magdeburg2/$subj/DenoiseWT1DenoiseT2/final/

#inleft=$maskT2/"$subj"_left_lfseg_corr_usegray_nocysts_whole.nii.gz
#inright=$maskT2/"$subj"_right_lfseg_corr_usegray_nocysts_whole.nii.gz

#OUTDIR=${output}/"$subj"/T2_erc_whole/

	#if [ -f "${OUTDIR}" ]; then
		#echo "${OUTDIR} exists"
	#else
		#mkdir ${OUTDIR}
	#fi

#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif  /bin/bash ${dockerscript} -i ${inleft} -w $OUTDIR
#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif  /bin/bash ${dockerscript} -i ${inright} -w $OUTDIR

#-------------------------------------------------#
#------------------------------------------------------------------------------#

### T1 no subdivisions from T1-ASHS #######

#maskdir=$pathstem/Segmentation/ASHS/"$subj"_fs/final

#inleft=$maskdir/"$subj"_left_lfseg_heur.nii.gz
#inright=$maskdir/"$subj"_right_lfseg_heur.nii.gz

#OUTDIR=${output}/"$subj"/T1_erc_whole/

	#if [ -f "${OUTDIR}" ]; then
		#echo "${OUTDIR} exists"
	#else
		#mkdir ${OUTDIR}
	#fi

#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif  /bin/bash ${dockerscript} -i ${inleft} -w $OUTDIR
#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif  /bin/bash ${dockerscript} -i ${inright} -w $OUTDIR


