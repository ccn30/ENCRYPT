#!/bin/bash
###########
#PSIR script
# OM 2018
##########

subjects=${1} 
subjIdx=${2}
scriptdir=${3}
MATLABPATH=${4}
spm_folder=${5}
SUBJDIR=${6} 
fsldir=${7}

mysubjs=($(<${subjects}))
subj=${mysubjs[${subjIdx}]}

#remove slash at end of mp2rage?
echo 'Starting '$subj
inputPath=${SUBJDIR}/"$subj"/mp2rage
cd ${inputPath};
echo $inputPath;

export FSLOUTPUTTYPE=NIFTI

fslsplit ${inputPath}/mp2rage_magnitude.nii.gz ${inputPath}/mag -t
fslsplit ${inputPath}/mp2rage_phase.nii.gz ${inputPath}/phas -t

echo 'STARTING mp2rage PREPROCESSING'
ls -alr $inputPath

#1. Run the PSIR scripts that combine the two magnitude images acquired on the scanner.
"$scriptdir"/PSIR_MP2RAGE -c -d ${inputPath} -m mag0000 -n mag0001 -p phas0000 -q phas0001

echo 'STEP 1 COMPLETE'
ls -alr $inputPath


g0="mag0000_PSIR_skulled.nii.gz";
g="mag0000_PSIR_skulled_std.nii.gz";
s=`basename ${g%.nii.gz}`; # s = mag0000_PSIR_skulled_std
#p=`dirname ${g}`; 

#n4=${p}/n4"$s".nii.gz;
n4=${inputPath}/n4"$s".nii.gz;  

#1.1. Make the PSIR image in standardized MNI coordinates
${fsldir}/bin/fslreorient2std ${g0} ${g}

gzip mag0000_PSIR_skulled_std.nii
gzip mag0000_PSIR_skulled.nii

echo 'STEP 1.1 COMPLETE'
ls -alr $inputPath

# 2. Extra Bias Field correction for mp2rage image after Olivier's script is run.
N4BiasFieldCorrection -d 3 -i ${g} -o ${n4}  -r 1 -c [50x50x30x20,1e-6] -b [200]; 

echo 'STEP 2 COMPLETE'
ls -alr $inputPath

# 3. run SPM segmentation on Bias field corrected image and then run the cr_spm_bet.m script adapted by Simon
cd ${scriptdir} 

#gzip -d ${inputPath}/${n4};
#rm ${inputPath}/${n4};
#n4=${p}/n4"$s".nii; 
gzip -d ${n4}
rm ${n4};
n4="n4"$s".nii";

echo 'STEP 3 COMPLETE'
ls -alr $inputPath

# 4. Run segmentation of PSIR Image
#"$MATLABPATH"/bin/matlab.nowrap -nodesktop -nosplash -nodisplay -r "try, seg_PSIR('${inputPath}','${n4}'); end ; quit"
"$MATLABPATH"/bin/matlab -nodesktop -nosplash -nodisplay -r "try, seg_PSIR('${inputPath}','/n4"$s".nii'); end ; quit"

echo 'STEP 4 COMPLETE'
ls -alr $inputPath

# 5. Run the bet in the PSIR image with the help of the segemnted tissues
"$MATLABPATH"/bin/matlab -nodesktop -nosplash -nodisplay -r "try, cr_spm_bet('${inputPath}/${n4}'); end ; quit"

echo 'STEP 5 COMPLETE'
ls -alr $inputPath

i_brain=n4mag0000_PSIR_skulled_std_struc_brain.nii;
s=`basename ${i_brain%.nii}`;
i_brain_mask="$s"_mask.nii.gz;

# 6. Create a brain mask from the skullstripped image
fslmaths $inputPath/$i_brain -div $inputPath/$i_brain $inputPath/$i_brain_mask

echo 'STEP 6 COMPLETE'
ls -alr $inputPath


