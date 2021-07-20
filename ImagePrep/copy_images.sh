#!/bin/bash
# copies images 

ENCRYPTpath=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
p00500path=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500
mysubjs=${ENCRYPTpath}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

# mp2rage T1 brain to images in p00500
target=${p00500path}/images/${subject}/T1brain.nii
source=${ENCRYPTpath}/images/${subjID}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii

cp $source $target

done

## extra code from previous script


#pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## set paths

#groupTemplateDir=${pathstem}/images/template02
#studyTemplateDir=~/ENCRYPT/atlases/templates/ECtemplatemasks2015
#regscriptdir=${pathstem}/scripts/Registration
#hybridmaskT2dir=/home/ccn30/ENCRYPT/segmentation/ECsubdivisions_Mag

#regDir=${pathstem}/registrations/${subject}
#rawpathstem=${pathstem}/images/${subjID}

#groupTemplate=${groupTemplateDir}/para01_template0.nii.gz
#studyTemplate=${studyTemplateDir}/Study_template_wholeBrain.nii
#T1=${groupTemplateDir}/${subject}_t1.nii
#cd ${rawpathstem}
#T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
#T2path=${rawpathstem}/${T2dir}
#T2=${T2path}/denoise_n42_t2.nii
#EPI=${regDir}/N4meanEPI.nii
#cd ${regscriptdir}


## set subject specific transformations (others set in ANTS call script)

T1xTempAffine=${groupTemplateDir}/para01_${subject}_t1*0GenericAffine.mat
T1xTempInvWarp=${groupTemplateDir}/para01_${subject}_t1*1InverseWarp.nii.gz
T1xTempWarp=${groupTemplateDir}/para01_${subject}_t1*1Warp.nii.gz
T1xT2affine=${regDir}/T1xT2_ANTs_0GenericAffine.mat
T1xEPIaffine=${regDir}/T1xepiSlab0GenericAffine.mat

## Perform copy images

#target=/group/p00500/Masks/images/${subject}
#mkdir -p $target
#cp $T2 $target/denoise_n42_t2.nii
#cp $EPI $target/N4meanEPI.nii
#cp $T1 $target/T1.nii
#targetreg=/group/p00500/Masks/registrations/${subject}
#mkdir -p $targetreg
#cp $T1xT2affine $targetreg/T1xT2_ANTs_0GenericAffine.mat
## need extra line for copying T1-T2 regs for 3 subjects that failed ANTs when done
#cp $T1xTempAffine $targetreg/para01_${subject}_t1*0GenericAffine.mat
#cp $T1xTempInvWarp $targetreg/para01_${subject}_t1*1InverseWarp.nii.gz
#cp $T1xTempWarp $targetreg/para01_${subject}_t1*1Warp.nii.gz
#cp $T1xEPIaffine $targetreg/T1xepiSlab0GenericAffine.mat

