#!/bin/bash
# called from coreg_SubmitArray
# script to coregister any images - all paths here
# c3d tool to make itk compatible

subjects=${1}
subjIdx=${2}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

# make EC subdiv masks
pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT

echo "******** starting $subject ********"

# set paths to inputs
maskDir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_MTLmasks/"${subject}"
echo $maskDir
EPI=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_images/"${subject}"/fMRI/rtopup_run1.nii
ASHS_EC=${maskDir}/ASHS_EC_EPI.nii.gz
HybridDTI_epi_R=${maskDir}/pmEC_right_HybridDTI_EPI.nii.gz
HybridMaass_epi_R=${maskDir}/combinedEC_right_HybridMaass_EPI.nii.gz

# make tSNR images
tSNRdir=${pathstem}/results/tSNR/"${subject}"
mkdir -p $tSNRdir
EPI_mean=$tSNRdir/EPI_mean.nii
EPI_SD=$tSNRdir/EPI_SD.nii
EPI_tSNR=$tSNRdir/EPI_tSNR.nii
fslmaths $EPI -Tmean $EPI_mean 
fslmaths $EPI -Tstd $EPI_SD
fslmaths $EPI_mean -div $EPI_SD $EPI_tSNR

# extract values for different masks
ASHS_EC_tSNR=$tSNRdir/tSNR_ASHS_EC_EPI.nii
HybridDTI_epi_R_tSNR=$tSNRdir/tSNR_pmEC_right_HybridDTI_EPI.nii
HybridMaass_epi_R_tSNR=$tSNRdir/tSNR_combinedEC_right_HybridMaass_EPI.nii
fslmaths $EPI_tSNR -mas $ASHS_EC $ASHS_EC_tSNR
fslmaths $EPI_tSNR -mas $HybridDTI_epi_R $HybridDTI_epi_R_tSNR
fslmaths $EPI_tSNR -mas $HybridMaass_epi_R $HybridMaass_epi_R_tSNR

# extract stats, put into individual csv files and prepend subject/mask name
printf "Code,Mask,Voxels,Volume,Mean,SD,min,max\n" >> $tSNRdir/header.csv
fslstats $ASHS_EC_tSNR -V -M -S -R | tr " " "," >> $tSNRdir/stats_output_EC.csv
fslstats $HybridDTI_epi_R_tSNR -V -M -S -R | tr " " "," >> $tSNRdir/stats_output_DTI.csv
fslstats $HybridMaass_epi_R_tSNR -V -M -S -R | tr " " "," >> $tSNRdir/stats_output_Maass.csv
cat $tSNRdir/stats_output_EC.csv $tSNRdir/stats_output_DTI.csv $tSNRdir/stats_output_Maass.csv >> $tSNRdir/stats_output_all.csv
printf "$subject,ASHS_EC\n$subject,DTI\n$subject,Maass" >> $tSNRdir/vars.csv
paste -d , $tSNRdir/vars.csv $tSNRdir/stats_output_all.csv  >> $tSNRdir/tSNR_output.csv
cat $tSNRdir/header.csv $tSNRdir/tSNR_output.csv >> ${pathstem}/results/tSNR/tSNR_output_$subject.csv
rm $tSNRdir/stats_output_DTI.csv $tSNRdir/stats_output_DTI.csv $tSNRdir/stats_output_Maass.csv
