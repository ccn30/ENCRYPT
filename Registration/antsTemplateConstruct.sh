#!/bin/bash

echo "you are in submission script, making template in $templatedir"
echo $ANTSPATH
templatedir=${1}

cd $templatedir

antsMultivariateTemplateConstruction2.sh -d 3 -o 01 *.nii

