#!/bin/bash
# coregister group template to study template

module unload fsl
module load fsl/6.0.3
module unload ANTS
module load ANTS/2.3.4

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## set paths

groupTemplateDir=${pathstem}/images/template02
studyTemplateDir=~/ENCRYPT/atlases/templates/ECtemplatemasks2015

## set images

groupTemplate=${groupTemplateDir}/para01_template0.nii.gz
studyTemplate=${studyTemplateDir}/Study_template_wholeBrain.nii

cd ${pathstem}

## Perform T1 group template x study template registration (study template 0.6iso)

antsRegistrationSyN.sh -f ${studyTemplate} -m ${groupTemplate} -o ${groupTemplateDir}/para01_template0xStudyTemplate_ -t s



