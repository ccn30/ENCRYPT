#!/bin/bash
# script to visualise results in itksnap simultaenously for all subjects in different windows
# needs to be called from graphics window sith source command run

pathstem=/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT
mysubjs=${pathstem}/testsubjcode.txt
#mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt
scriptDir=${pathstem}/scripts/Registration
outDir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500
MagAtlasDir=/home/ccn30/rds/hpc-work/WBIC_home/ENCRYPT/atlases/magdeburgatlas

for subject in `cat $mysubjs`
do
#subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## set paths to image dirs
rawpathstem=$outDir/ENCRYPT_images/$subject
regDir=$outDir/ENCRYPT_registrations/$subject

T2path=${rawpathstem}/T2/t2.nii
N4T2=${rawpathstem}/T2/N4t2.nii
wholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
n4EPI=${rawpathstem}/fMRI/N4meanEPI.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
DenoiseN4T2=${rawpathstem}/T2/denoise_N4t2.nii

#UtrechtTemplate=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template.nii.gz
#UtrechtTempBrain=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template/template_bet.nii.gz
MagdeburgTemplate=$MagAtlasDir/template/template.nii.gz
MagdeburgTempBrain=$MagAtlasDir/template/template_bet.nii.gz

#ASHSMagDir=${pathstem}/segmentation/ASHS_Magdeburg2/${subject}

# T2 x T1
affine=${regDir}/T2xT1Warped_affine.nii.gz

# EPI x T1
warpedT1=${regDir}/T1xepiSlabWarped.nii.gz
warpedEPI=$regDir/T1xepiSlabInverseWarped.nii.gz

# T1 to group template
template=${templateDir}/para01_template0.nii.gz
warpedSubjT1=${templateDir}/para01_template0${subject}_t*.nii.gz

# Maass masks to EPI space
warpedTemplate=${regDir}/studyBrainxEPI_Warped.nii.gz
alEC_left=${regDir}/alEC_leftxEPI.nii.gz
pmEC_right=${regDir}/pmEC_rightxEPI.nii.gz

# T1 to Utrecht atlas ASHS
warpedT1BrainUtrecht=${regDir}/UtrechtTempxT1_ANTs_InvWarped.nii.gz
utrechtTempBrain=${utrechtAtlasDir}/template/template_bet.nii.gz
warpedT1WholeUtrecht=${regDir}?UtrechtTempWholexT1Whole_ANTs_InvWarped.nii.gz
utrechtTempWhole=${utrechtAtlasDir}/template/template.nii.gz

# T1 to Magdeburg atlas ASHS
warpedT1Mag=${regDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz
MagTemp=${MagAtlasDir}/template/template.nii.gz

# check ASHS segmentation
utrechtTextLabs=${utrechtAtlasDir}/snap/snaplabels.txt
magdeburgTextLabs=${magAtlasDir}/snap/snaplabels.txt
magdeburgTextLabsECsub=${magAtlasDir}/snap/snaplabels_ECsubdivisions.txt
usegrayLeftUtrecht=${ASHSUtrechtDir}/DenoiseWT1DenoiseT2/final/${subject}_left_lfseg_corr_usegray.nii.gz
usegrayRightUtrecht=${ASHSUtrechtDir}/DenoiseWT1DenoiseT2/final/${subject}_right_lfseg_corr_usegray.nii.gz
usegrayLeftMag=${ASHSMagDir}/DenoiseWT1DenoiseT2/final/${subject}_left_lfseg_corr_usegray.nii.gz
usegrayRightMag=${ASHSMagDir}/DenoiseWT1DenoiseT2/final/${subject}_right_lfseg_corr_usegray.nii.gz

# Maass masks to T2 space
rightECMaassMaskxT2=${regDir}/rightEC_MaassMasksxT2.nii.gz
leftECMaassMaskxT2=${regDir}/leftEC_MaassMasksxT2.nii.gz
MaassTemplateBrainxT2=${regDir}/MaassTemplateBrainxT2.nii.gz

## command

#itksnap -g ${wholeT1} -o ${affine} &
#vglrun itksnap -g ${n4EPI} -o ${warpedT1} &
#rm $regDir/T1xepiSlab*
itksnap -g $n4EPI -o $wholeT1 &
#vglrun itksnap -g ${template} -o ${warpedSubjT1} &
#vglrun itksnap -g ${n4EPI} -o ${warpedTemplate} -o ${warpedT1} -s ${pmEC_right} &
#vglrun itksnap -g ${utrechtTempBrain} -o ${warpedT1BrainUtrecht} &
#vglrun itksnap -g ${DenoiseN4T2} -s ${usegrayLeft} -l ${utrechtTextLabs} &
#itksnap -g ${MagTemp} -o ${warpedT1Mag} &
#vglrun itksnap -g ${DenoiseN4T2} -s ${usegrayLeft} -l ${utrechtTextLabs} &
#vglrun itksnap -g $DenoiseN4T2 -o $MaassTemplateBrainxT2
#vglrun itksnap -g $N4T2 -o $rightECMaassMaskxT2 -s $usegrayRightMag -l $magdeburgTextLabsECsub

## copy images into dir for scp to local 
#scpdir=/home/ccn30/Downloads/T2masks/$subject/

#if [ -f "${scpdir}" ]; then
#		echo "${scpdir} exists"
#	else
#		mkdir -p ${scpdir}
#fi

#cp $N4T2 $scpdir
#cp $rightECMaassMaskxT2 $scpdir
#cp $leftECMaassMaskxT2 $scpdir
#cp $usegrayRightUtrecht /home/ccn30/Downloads/T2masks/$subject/${subject}_right_lfseg_corr_usegray_utrecht.nii.gz
#cp $usegrayLeftUtrecht /home/ccn30/Downloads/T2masks/$subject/${subject}_left_lfseg_corr_usegray_utrecht.nii.gz
#cp $usegrayRightMag /home/ccn30/Downloads/T2masks/$subject/${subject}_right_lfseg_corr_usegray_magdeburg.nii.gz
#cp $usegrayLeftMag /home/ccn30/Downloads/T2masks/$subject/${subject}_left_lfseg_corr_usegray_magdeburg.nii.gz
#cp $utrechtTextLabs $scpdir"snaplabels_Utrecht.txt"
#cp $magdeburgTextLabsECsub $scpdir"snaplabels_Magdeburg_ECsubdivisions.txt"

done
