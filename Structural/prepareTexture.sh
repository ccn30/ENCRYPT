#!/bin/bash
# called from coreg_SubmitArray
# script to coregister any images - all paths here
# c3d tool to make itk compatible

subjects=${1}
subjIdx=${2}
outDir=${3}
ASHSDir=${4}
MaskDir=${5}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

echo "******** starting $subject ********"

# set input paths
ASHS=$ASHSDir/$subject
ChunkL=$ASHS/tse_native_chunk_left.nii.gz
ChunkR=$ASHS/tse_native_chunk_right.nii.gz
Mask=${MaskDir}/$subject
MaskL=$Mask/${subject}_left_lfseg_corr_usegray_noCysts_clean.nii.gz
MaskR=$Mask/${subject}_right_lfseg_corr_usegray_noCysts_clean.nii.gz
# set output paths
OutChunkL=$outDir/${subject}_t2_native_chunk_left.nii.gz
OutChunkR=$outDir/${subject}_t2_native_chunk_right.nii.gz
OutMaskL=$Mask/${subject}_left_lfseg_corr_usegray_noCysts_clean_ChunkResampled.nii.gz
OutMaskR=$Mask/${subject}_right_lfseg_corr_usegray_noCysts_clean_ChunkResampled.nii.gz

# copy over T2 native chunks
cp $ChunkL $OutChunkL
cp $ChunkR $OutChunkR

# resample ASHS output to space of T2 chunk per hemisphere
c3d $ChunkL $MaskL -int 0 -reslice-identity -o $OutMaskL
c3d $ChunkR $MaskR -int 0 -reslice-identity -o $OutMaskR


