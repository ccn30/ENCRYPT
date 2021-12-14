#!/bin/bash

pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
subjects=${pathstem}/ENCRYPT_MasterRIScodes.txt
#subjects=${pathstem}/testsubjcode.txt
scriptdir=${pathstem}/scripts/Registration

groupTempDir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_template
groupTemp=$groupTempDir/ENCRYPT_ants55template.nii.gz
MaassTempDir=/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/atlases/templates/ECtemplatemasks2015
MaassTemp=$MaassTempDir/Study_template_wholeBrain.nii




### Before template made ###

#echo "Making template dir"
#if [ -f "${templatedir}" ]; then
#	echo "${templatedir} exists"
#else
#	mkdir ${templatedir}
#fi 

#cd ${templatedir}

for subject in `cat $subjects`
do
ASHSsegL=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_ASHS_T2/${subject}/final/${subject}_left_lfseg_corr_usegray.nii.gz
ASHSsegR=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_ASHS_T2/${subject}/final/${subject}_right_lfseg_corr_usegray.nii.gz
targetL=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_MTLmasks/${subject}/${subject}_left_lfseg_corr_usegray.nii.gz
targetR=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_MTLmasks/${subject}/${subject}_right_lfseg_corr_usegray.nii.gz
#wholet1=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_images/$subjID/mp2rage/n4mag0000_PSIR_skulled_std.nii
#cpT1=$subjID"_t1.nii"

cp $ASHSsegL $targetL
cp $ASHSsegR $targetR

done

### After template made ###
# make sure correct version of ANTs module loaded

#antsRegistrationSyN.sh -d 3 -f $MaassTemp -m $groupTemp -o $templateDir/ENCRYPT_ants55templatexMaassTemplate_
