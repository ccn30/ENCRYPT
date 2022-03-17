#!bin/bash

## creating the volumetric table for EC masks through c3d ##

pathstem=/home//rds/hpc-work/wbic
SEGMENTATIONDIR=$pathstem/
braindir=$pathstem/
outdir=$pathstem/

subjects=$pathstem/Scripts/subjectsID.txt

module load /home//privatemodules/c3d_tool

for subj in `cat $subjects`
do

## this command gives a txt file of list of volumes for each label of all subjects but without names of labels or of subjects (just one list) ##

c3d $SEGMENTATIONDIR/"$subj"_"hemi"_lfseg_corr_usegray_nocysts_clean.nii.gz -split -foreach -voxel-integral -endfor >> $outdir/name_of_file.txt

### this command gives a txt list of volumes and counts for each label of all subjects, label identity (0-18) is included ###

c3d $SEGMENTATIONDIR/"$subj"_"hemi"_lfseg_corr_usegray_nocysts_clean.nii.gz -dup -lstat >> $outdir/name_of_file.txt

done
