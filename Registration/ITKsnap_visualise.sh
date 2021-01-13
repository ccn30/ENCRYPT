#!/bin/bash
# script to visualise results in itksnap simultaenously for all subjects in different windows
# needs to be called from graphics window sith source command run

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
#mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## set paths to images

#regDir=${pathstem}/registrations/6.11.20/${subject}/T2xT1
regDir=${pathstem}/registrations/${subject}
templateDir=${pathstem}/images/template02
utrechtAtlasDir=/home/ccn30/ENCRYPT/atlases/utrechtatlas/template

rawpathstem=${pathstem}/images/${subjID}
cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${regDir}

wholeT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/denoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii
wm=${rawpathstem}/mp2rage/c2n4mag0000_PSIR_skulled_std.nii

T2=${T2path}/t2.nii
N4T2=${T2path}/n4_t2.nii
DenoiseN4T2=${T2path}/denoise_n4_t2.nii

# T2 x T1
affine=${regDir}/T2xT1Warped_affine.nii.gz

# EPI x T1
warpedT1=${regDir}/T1xepiSlabWarped.nii.gz
n4EPI=${regDir}/N4meanEPI.nii

# T1 to group template
template=${templateDir}/para01_template0.nii.gz
warpedSubjT1=${templateDir}/para01_template0${subject}_t*.nii.gz
echo ${warpedSubjT1}

# masks to EPI space
warpedTemplate=${regDir}/studyBrainxEPI_Warped.nii.gz
alEC_left=${regDir}/alEC_leftxEPI.nii.gz
pmEC_right=${regDir}/pmEC_rightxEPI.nii.gz

# T1 to Utrecht atlas ASHS
warpedT1Utrecht=${regDir}/UtrechtTempxT1_ANTs_InvWarped.nii.gz
utrechtTemp=${utrechtAtlasDir}/template.nii.gz

## command

#vglrun itksnap -g ${wholeT1} -o ${affine} &
#vglrun itksnap -g ${n4EPI} -o ${warpedT1} &
#vglrun itksnap -g ${template} -o ${warpedSubjT1} &
#vglrun itksnap -g ${n4EPI} -o ${warpedTemplate} -o ${warpedT1} -s ${pmEC_right} &
vglrun itksnap -g ${utrechtTemp} -o ${warpedT1Utrecht} &

done
