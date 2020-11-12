#!/bin/bash
# corgeister templates masks to subject EPIs

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## set paths

groupTemplateDir=${pathstem}/images/template02
studyTemplateDir=~/ENCRYPT/atlases/templates/ECtemplatemasks2015

## separate txt file with subject and date IDs

mysubjs=${pathstem}/testsubjcode.txt
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt


for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"


## set subject specific paths

regDir=${pathstem}/registrations/${subject}


## set images

groupTemplate=${groupTemplateDir}/para01_template0.nii.gz
studyTemplate=${studyTemplateDir}/Study_template_wholeBrain.nii
T1=${groupTemplateDir}/${subject}_t1.nii

## set subject specific transformations (others set in ANTS call script)

T1xTempAffine=${groupTemplateDir}/para01_${subject}_t1*0GenericAffine.mat
T1xTempInvWarp=${groupTemplateDir}/para01_${subject}_t1*1InverseWarp.nii.gz


## Perform T1 group template x study template registration (study template 0.6iso)

#antsRegistrationSyN.sh -f ${studyTemplate} -m ${groupTemplate} -o ${groupTemplateDir}/para01_template0xStudyTemplate_ -t s


## Perform mask x EPI transformation

ANTs_templateMasksxEPI.sh ${regDir} ${groupTemplateDir} ${studyTemplateDir} ${T1xTempAffine} ${T1xTempInvWarp} ${T1}
test_coreg.sh ${regDir} ${groupTemplateDir} ${studyTemplateDir} ${T1xTempAffine} ${T1xTempInvWarp}

done



#T1xEPIAffine=${regDir}/T1xepiSlab0GenericAffine.mat
#gTempxsTempAffine=${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat
#gTempxsTempInvWarp=${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz
#EPI=${regDir}/N4meanEPI.nii
#T1=${groupTemplateDir}/${subject}_t1.nii
