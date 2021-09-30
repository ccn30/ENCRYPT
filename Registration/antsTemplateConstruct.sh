#!/bin/bash

echo "you are in submission script, making template in $templatedir"
echo $ANTSPATH
templatedir=${1}

cd $templatedir

antsMultivariateTemplateConstruction2.sh -d 3 -r 1 -n 0 -c 5 -c 5 -b 1 -u 12:00:00 -o ants51 *.nii

