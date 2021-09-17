#!/bin/bash
subjects=${1} 
subjIdx=${2}  
imageDir=${3}

module load ants-2.3.4-gcc-5-lj6vm7c
export antsroot=/usr/local/software/spack/spack-git/opt/spack/linux-rhel7-broadwell/gcc-5/ants-2.3.4-lj6vm7ccmij4yywr4ynrttcko4aoflqt/bin 

# initialise subject-wise paths
mysubjs=($(<${subjects}))
subject=${mysubjs[${subjIdx}]}

subjImageDir=$imageDir/$subject
T1path=$subjImageDir/mp2rage
T2path=$subjImageDir/T2

echo "Inside denoiseReorient.sh script"
echo "Subject is: " ${subject}
echo "Image dir is: " ${subjImageDir}

#------------------------------------------------------------------------#
# Denoise					 		 #
#------------------------------------------------------------------------#
# using N4 corrected T1 from mp2rage reconstruction

# inputs
T1=${T1path}/n4mag0000_PSIR_skulled_std.nii
brainT1=${T1path}/n4mag0000_PSIR_skulled_std_struc_brain.nii
T2=${T2path}/t2.nii

# outputs
N4T2=${T2path}/N4t2.nii
denoiseT1=${T1path}/denoise_n4mag0000_PSIR_skulled_std.nii
denoisebrainT1=${T1path}/denoise_n4mag0000_PSIR_skulled_std_struc_brain.nii
denoiseT2=${T2path}/denoise_t2.nii
denoiseN4T2=${T2path}/denoise_N4t2.nii

echo "Running DenoiseImage on: " ${T1} "+" ${T2}

#$antsroot/DenoiseImage -d 3 -i $brainT1 -o $denoisebrainT1 -v 1
#$antsroot/DenoiseImage -d 3 -i $T1 -o $denoiseT1 -v 1

rm $denoiseT2 # delete existing outputs, run N4 and then denoise 
$antsroot/N4BiasFieldCorrection -d 3 -i ${T2} -o ${N4T2}
$antsroot/DenoiseImage -d 3 -i $N4T2 -o $denoiseN4T2 -v 1


#------------------------------------------------------------------------#
# Reorient MP2RAGES 					 		 #
#------------------------------------------------------------------------#
RdenoiseT1=${T1path}/Rdenoise_n4mag0000_PSIR_skulled_std.nii
RdenoiseT1brain=${T1path}/Rdenoise_n4mag0000_PSIR_skulled_std_struc_brain.nii
RT1=${T1path}/Rn4mag0000_PSIR_skulled_std.nii

# denoise brain
#fslreorient2std ${denoisebrainT1} ${RdenoiseT1brain}

# denoise whole 
#fslreorient2std ${denoiseT1} ${RdenoiseT1}

# original whole
#fslreorient2std ${T1} ${RT1}
