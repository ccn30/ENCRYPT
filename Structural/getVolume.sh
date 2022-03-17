#!/bin/bash
# called from getvolume_submitarray
# call c3d to get volume per ROI label

subjects=${1}
subjIdx=${2}
outDirstem=${3}
maskDirstem=${4}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

echo "******** starting $subject ********"

#### DEFINE ENVIRONMENT ####

# subject specific paths
maskDir=$maskDirstem/$subject
outDir=$outDirstem

# Make dirs
if [ -f "${outDir}" ]; then
	echo "${outDir} exists"
else
	mkdir -p ${outDir}
fi

# T2 ROI Masks
#right
ASHS_T2_R=${maskDir}/"$subject"_right_lfseg_corr_usegray_noCysts_clean.nii.gz
HybridMaass_T2_R=${maskDir}/combinedEC_right_HybridMaass_T2.nii.gz
#HybridDTI_T2_R=${maskDir}/pmEC_right_HybridDTI_T2.nii.gz
#left
ASHS_T2_L=${maskDir}/"$subject"_left_lfseg_corr_usegray_noCysts_clean.nii.gz
HybridMaass_T2_L=${maskDir}/combinedEC_left_HybridMaass_T2.nii.gz
#HybridDTI_T2_L=${maskDir}/pmEC_left_HybridDTI_T2.nii.gz

#### c3d COMMANDS ####

# get ASHS vols
c3d $ASHS_T2_L -dup -lstat | awk -v OFS=, '{$1=$1; print (NR==1 ? "subjectID":'${subject}'), $0}' >> $outDir/${subject}_ASHST2_vols_left.csv
c3d $ASHS_T2_R -dup -lstat | awk -v OFS=, '{$1=$1; print (NR==1 ? "subjectID":'${subject}'), $0}' >> $outDir/${subject}_ASHST2_vols_right.csv

# get subdivision vols
c3d $HybridMaass_T2_L -dup -lstat | awk -v OFS=, '{$1=$1; print (NR==1 ? "subjectID":'${subject}'), $0}' >> $outDir/${subject}_HybridMaassT2_vols_left.csv
c3d $HybridMaass_T2_R -dup -lstat | awk -v OFS=, '{$1=$1; print (NR==1 ? "subjectID":'${subject}'), $0}' >> $outDir/${subject}_HybridMaassT2_vols_right.csv


