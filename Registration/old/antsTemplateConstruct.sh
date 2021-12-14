#!/bin/bash

echo "you are in submission script, making template in $templatedir"
echo $ANTSPATH
templatedir=${1}

cd $templatedir

antsMultivariateTemplateConstruction2.sh -d 3 -c 5 -r 1 -o ants55 *.nii

