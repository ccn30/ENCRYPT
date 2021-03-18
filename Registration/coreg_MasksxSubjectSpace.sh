#!/bin/bash
# corgeister templates/masks to subject EPIs, calls ANTS script in cd

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## set paths

groupTemplateDir=${pathstem}/images/template02
studyTemplateDir=~/ENCRYPT/atlases/templates/ECtemplatemasks2015
regscriptdir=${pathstem}/scripts/Registration
hybridmaskT2dir=/home/ccn30/ENCRYPT/segmentation/ECsubdivisions_Mag

## separate txt file with subject and date IDs

mysubjs=${pathstem}/testsubjcode.txt
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt


for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"


## set subject specific paths

regDir=${pathstem}/registrations/${subject}
rawpathstem=${pathstem}/images/${subjID}

groupTemplate=${groupTemplateDir}/para01_template0.nii.gz
studyTemplate=${studyTemplateDir}/Study_template_wholeBrain.nii
T1=${groupTemplateDir}/${subject}_t1.nii
cd ${rawpathstem}
T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}
T2=${T2path}/denoise_n42_t2.nii
cd ${regscriptdir}


## set subject specific transformations (others set in ANTS call script)

T1xTempAffine=${groupTemplateDir}/para01_${subject}_t1*0GenericAffine.mat
T1xTempInvWarp=${groupTemplateDir}/para01_${subject}_t1*1InverseWarp.nii.gz
T1xT2affine=${regDir}/T1xT2_ANTs_0GenericAffine.mat
T1xEPIaffine=${regDir}/T1xepiSlab0GenericAffine.mat


## Perform T1 group template x study template registration (study template 0.6iso)

#antsRegistrationSyN.sh -f ${studyTemplate} -m ${groupTemplate} -o ${groupTemplateDir}/para01_template0xStudyTemplate_ -t s


## Perform mask x EPI/T1 transformation

#ANTs_templateMasksxSubjectSpace.sh ${regDir} ${groupTemplateDir} ${studyTemplateDir} ${T1xTempAffine} ${T1xTempInvWarp} ${T1} ${T2} ${T1xT2affine}
#test_coreg.sh ${regDir} ${groupTemplateDir} ${studyTemplateDir} ${T1xTempAffine} ${T1xTempInvWarp}


## Perform T2 hybrid mask x T2 registration

ANTs_HybridMasksT2xEPI.sh ${subject} ${regDir} ${hybridmaskT2dir} ${T1xT2affine} ${T1xEPIaffine}

done



#T1xEPIAffine=${regDir}/T1xepiSlab0GenericAffine.mat
#gTempxsTempAffine=${groupTemplateDir}/para01_template0xStudyTemplate_0GenericAffine.mat
#gTempxsTempInvWarp=${groupTemplateDir}/para01_template0xStudyTemplate_1InverseWarp.nii.gz
#EPI=${regDir}/N4meanEPI.nii
#T1=${groupTemplateDir}/${subject}_t1.nii
