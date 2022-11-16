#!/bin/bash
# called from textureSubmitArray - extract texture values based on T2 MTL masks
# c3d tool to make itk compatible

subjects=${1}
subjIdx=${2}

mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}
textureDir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/prevent_4marianna/ENCRYPT_texture
textureResults=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/prevent_4marianna/ENCRYPT_texture/results/"$subject"
#mkdir -p $textureResults
#cd $textureResults

echo "******** starting $subject ********"

## set paths to inputs
maskDir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_MTLmasks/"${subject}"
newmaskDir=/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/prevent_4marianna/ENCRYPT_MTLmasks

## texture images old
# ignore 8-bit images - still name .nii.nii
#sumofsqLN=$textureDir/sumofsq_var_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#sumofsqRN=$textureDir/sumofsq_var_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#sumEntroLN=$textureDir/sum_entr_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#sumEntroRN=$textureDir/sum_entr_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#sumAvLN=$textureDir/sum_aver_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#sumAvRN=$textureDir/sum_aver_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#homogLN=$textureDir/homogeneity_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#homogRN=$textureDir/homogeneity_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#entropyLN=$textureDir/entropy_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#entropyRN=$textureDir/entropy_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#energyLN=$textureDir/energy_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#energyRN=$textureDir/energy_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#corrLN=$textureDir/correlation_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#corrRN=$textureDir/correlation_3_16_"${subject}"_t2_native_chunk_right.nii.nii
#contLN=$textureDir/contrast_3_16_"${subject}"_t2_native_chunk_left.nii.nii
#contRN=$textureDir/contrast_3_16_"${subject}"_t2_native_chunk_right.nii.nii

## input texture images renamed
sumofsqL=$textureDir/sumofsq_var_3_16_"${subject}"_t2_native_chunk_left.nii
sumofsqR=$textureDir/sumofsq_var_3_16_"${subject}"_t2_native_chunk_right.nii
sumEntroL=$textureDir/sum_entr_3_16_"${subject}"_t2_native_chunk_left.nii
sumEntroR=$textureDir/sum_entr_3_16_"${subject}"_t2_native_chunk_right.nii
sumAvL=$textureDir/sum_aver_3_16_"${subject}"_t2_native_chunk_left.nii
sumAvR=$textureDir/sum_aver_3_16_"${subject}"_t2_native_chunk_right.nii
homogL=$textureDir/homogeneity_3_16_"${subject}"_t2_native_chunk_left.nii
homogR=$textureDir/homogeneity_3_16_"${subject}"_t2_native_chunk_right.nii
entropyL=$textureDir/entropy_3_16_"${subject}"_t2_native_chunk_left.nii
entropyR=$textureDir/entropy_3_16_"${subject}"_t2_native_chunk_right.nii
energyL=$textureDir/energy_3_16_"${subject}"_t2_native_chunk_left.nii
energyR=$textureDir/energy_3_16_"${subject}"_t2_native_chunk_right.nii
corrL=$textureDir/correlation_3_16_"${subject}"_t2_native_chunk_left.nii
corrR=$textureDir/correlation_3_16_"${subject}"_t2_native_chunk_right.nii
contL=$textureDir/contrast_3_16_"${subject}"_t2_native_chunk_left.nii
contR=$textureDir/contrast_3_16_"${subject}"_t2_native_chunk_right.nii

# rename texture images
#mv $sumofsqLN $sumofsqL
#mv $sumofsqRN $sumofsqR
#mv $sumEntroLN $sumEntroL
#mv $sumEntroRN $sumEntroR
#mv $sumAvLN $sumAvL
#mv $sumAvRN $sumAvR
#mv $homogLN $homogL
#mv $homogRN $homogR
#mv $entropyLN $entropyL
#mv $entropyRN $entropyR
#mv $energyLN $energyL
#mv $energyRN $energyR
#mv $corrLN $corrL
#mv $corrRN $corrR
#mv $contLN $contL
#mv $contRN $contR

## input masks in resampled space - generated elsewhere
chunkASHSr=${maskDir}/"${subject}"_right_lfseg_corr_usegray_noCysts_clean_ChunkResampled.nii
chunkASHSl=${maskDir}/"${subject}"_left_lfseg_corr_usegray_noCysts_clean_ChunkResampled.nii
# quick copy to new dir
mv $chunkASHSr $newmaskDir
mv $chunkASHSl $newmaskDir

## output texture header for subject
#printf "Code,Mask,Side,Metric,Mean,SD\n" >> $textureResults/header.csv

# output file
#results=$textureResults/final/"${subject}"_textureresults16.csv
#mkdir -p final

##########
### EC ###
##########

## get EC chunk masks out of ASHS
chunkECr=${maskDir}/ASHS_T2_EC_right_ChunkResampled.nii.gz
chunkECl=${maskDir}/ASHS_T2_EC_left_ChunkResampled.nii.gz
#fslmaths ${chunkASHSr} -thr 8.5 -uthr 9.5 -bin ${chunkECr} -odt char # use ASHS snaplabels.txt
#fslmaths ${chunkASHSl} -thr 8.5 -uthr 9.5 -bin ${chunkECl} -odt char
#c3d ${chunkECr} -thresh 8.5 9.5 1 0 ${chunkECr} # make EC mask value 1
#c3d ${chunkECl} -thresh 8.5 9.5 1 0 ${chunkECl}

## prepare outputs
#printf "$subject,EC,left,Sum\n$subject,EC,right,Sum" >> $textureResults/varsSumEC.csv
tempSumEC=$textureResults/"${subject}"_tempSumEC.csv
ECsumAvL=$textureResults/sum_aver_3_16_"${subject}"_EC_left.nii.gz
ECsumAvR=$textureResults/sum_aver_3_16_"${subject}"_EC_right.nii.gz
ECsumAv=$textureResults/sum_aver_3_16_"${subject}"_EC.csv

#printf "$subject,EC,left,Homogeneity\n$subject,EC,right,Homogeneity" >> $textureResults/varsHomogEC.csv
tempHomogEC=$textureResults/"${subject}"_tempHomogEC.csv
EChomogL=$textureResults/homogeneity_3_16_"${subject}"_EC_left.nii.gz
EChomogR=$textureResults/homogeneity_3_16_"${subject}"_EC_right.niig.gz
EChomogAv=$textureResults/homogeneity_3_16_"${subject}"_EC.csv

#printf "$subject,EC,left,Contrast\n$subject,EC,right,Contrast" >> $textureResults/varsContEC.csv
tempContEC=$textureResults/"${subject}"_tempContEC.csv
ECcontL=$textureResults/contrast_3_16_"${subject}"_EC_left.nii.gz
ECcontR=$textureResults/contrast_3_16_"${subject}"_EC_right.nii.gz
ECcontAv=$textureResults/contrast_3_16_"${subject}"_EC.csv

# extract EC vals L and R
#fslmaths $sumAvL -mas ${chunkECl} $ECsumAvL
#fslmaths $sumAvR -mas ${chunkECr} $ECsumAvR

#fslmaths $homogL -mas ${chunkECl} $EChomogL
#fslmaths $homogR -mas ${chunkECr} $EChomogR

#fslmaths $contL -mas ${chunkECl} $ECcontL
#fslmaths $contR -mas ${chunkECr} $ECcontR

# average across EC with header for 'sum' only (don't repeat)
#fslstats $ECsumAvL -M -S | tr " " "," >> $ECsumAv
#fslstats $ECsumAvR -M -S | tr " " "," >> $ECsumAv
#paste -d , $textureResults/varsSumEC.csv $ECsumAv >> $tempSumEC
#cat $textureResults/header.csv $tempSumEC >> $results

#fslstats $EChomogL -M -S | tr " " "," >> $EChomogAv
#fslstats $EChomogR -M -S | tr " " "," >> $EChomogAv
#paste -d , $textureResults/varsHomogEC.csv $EChomogAv >> $tempHomogEC
#cat $results $tempHomogEC >> $results

#fslstats $ECcontL -M -S | tr " " "," >> $ECcontAv
#fslstats $ECcontR -M -S | tr " " "," >> $ECcontAv
#paste -d , $textureResults/varsContEC.csv $ECcontAv >> $tempContEC
#cat $results $tempContEC >> $results

##########
### CA1 ##
##########

## get CA1 chunk masks out of ASHS
chunkCA1r=${maskDir}/ASHS_T2_CA1_right_ChunkResampled.nii.gz
chunkCA1l=${maskDir}/ASHS_T2_CA1_left_ChunkResampled.nii.gz
#fslmaths ${chunkASHSr} -thr 0.5 -uthr 1.5 -bin ${chunkCA1r} -odt char # use ASHS snaplabels.txt
#fslmaths ${chunkASHSl} -thr 0.5 -uthr 1.5 -bin ${chunkCA1l} -odt char

## prepare outputs
#printf "$subject,CA1,left,Sum\n$subject,CA1,right,Sum" >> $textureResults/varsSumCA1.csv
tempSumCA1=$textureResults/"${subject}"_tempSumCA1.csv
CA1sumAvL=$textureResults/sum_aver_3_16_"${subject}"_CA1_left.nii.gz
CA1sumAvR=$textureResults/sum_aver_3_16_"${subject}"_CA1_right.nii.gz
CA1sumAv=$textureResults/sum_aver_3_16_"${subject}"_CA1.csv

#printf "$subject,CA1,left,Homogeneity\n$subject,CA1,right,Homogeneity" >> $textureResults/varsHomogCA1.csv
tempHomogCA1=$textureResults/"${subject}"_tempHomogCA1.csv
CA1homogL=$textureResults/homogeneity_3_16_"${subject}"_CA1_left.nii.gz
CA1homogR=$textureResults/homogeneity_3_16_"${subject}"_CA1_right.niig.gz
CA1homogAv=$textureResults/homogeneity_3_16_"${subject}"_CA1.csv

#printf "$subject,CA1,left,Contrast\n$subject,CA1,right,Contrast" >> $textureResults/varsContCA1.csv
tempContCA1=$textureResults/"${subject}"_tempContCA1.csv
CA1contL=$textureResults/contrast_3_16_"${subject}"_CA1_left.nii.gz
CA1contR=$textureResults/contrast_3_16_"${subject}"_CA1_right.nii.gz
CA1contAv=$textureResults/contrast_3_16_"${subject}"_CA1.csv

# extract CA1 vals L and R
#fslmaths $sumAvL -mas ${chunkCA1l} $CA1sumAvL
#fslmaths $sumAvR -mas ${chunkCA1r} $CA1sumAvR

#fslmaths $homogL -mas ${chunkCA1l} $CA1homogL
#fslmaths $homogR -mas ${chunkCA1r} $CA1homogR

#fslmaths $contL -mas ${chunkCA1l} $CA1contL
#fslmaths $contR -mas ${chunkCA1r} $CA1contR

# output CA1 values no header (printed already)
#fslstats $CA1sumAvL -M -S | tr " " "," >> $CA1sumAv
#fslstats $CA1sumAvR -M -S | tr " " "," >> $CA1sumAv
#paste -d , $textureResults/varsSumCA1.csv $CA1sumAv >> $tempSumCA1
#cat $results $tempSumCA1 >> $results

#fslstats $CA1homogL -M -S | tr " " "," >> $CA1homogAv
#fslstats $CA1homogR -M -S | tr " " "," >> $CA1homogAv
#paste -d , $textureResults/varsHomogCA1.csv $CA1homogAv >> $tempHomogCA1
#cat $results $tempHomogCA1 >> $results

#fslstats $CA1contL -M -S | tr " " "," >> $CA1contAv
#fslstats $CA1contR -M -S | tr " " "," >> $CA1contAv
#paste -d , $textureResults/varsContCA1.csv $CA1contAv >> $tempContCA1
#cat $results $tempContCA1 >> $results


#mv final/"${subject}"_textureresults16.csv /home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/prevent_4marianna/ENCRYPT_texture/results/"${subject}"_textureresults16.csv
# manually delete dirs in results

