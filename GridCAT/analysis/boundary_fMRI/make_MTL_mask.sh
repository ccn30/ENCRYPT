#!/bin/sh
# make binary MTL whole masks from ASHS mag registered to EPI space
# July 2021

scriptdir=$(pwd)
pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
WBIChome=/home/ccn30/rds/hpc-work/WBIC_home
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt
#mysubjs=${pathstem}/testsubjcode.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"


MTLmaskdir=$WBIChome/ENCRYPT/segmentation/ECsubdivisions_Mag
newMTLmaskdir=$WBIChome/ENCRYPT/segmentation/EPI_ASHSMTL_masks

# input images
rMTLmag=${MTLmaskdir}/"$subject"_right_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz
lMTLmag=${MTLmaskdir}/"$subject"_left_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz

# output images
rMTLmag_cyst=$newMTLmaskdir/"$subject"_right_ASHSMTL_EPI_cystonly.nii.gz
rMTLmag_nocyst=$newMTLmaskdir/"$subject"_right_ASHSMTL_EPI_nocyst_bin.nii.gz
lMTLmag_cyst=$newMTLmaskdir/"$subject"_left_ASHSMTL_EPI_cystonly.nii.gz
lMTLmag_nocyst=$newMTLmaskdir/"$subject"_left_ASHSMTL_EPI_nocyst_bin.nii.gz

# run fslmaths with cyst=label 13

fslmaths $rMTLmag -thr 12.5 -uthr 13.5 $rMTLmag_cyst
fslmaths $rMTLmag -sub $rMTLmag_cyst -bin $rMTLmag_nocyst 

fslmaths $lMTLmag -thr 12.5 -uthr 13.5 $lMTLmag_cyst
fslmaths $lMTLmag -sub $lMTLmag_cyst -bin $lMTLmag_nocyst 

cd $newMTLmaskdir
rm *_cystonly.nii.gz
cd $scriptdir

done
