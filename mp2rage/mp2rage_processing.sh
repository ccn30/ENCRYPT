#!/bin/bash
###########
#PSIR script
# OM 2018
##########

MATLABPATH="/applications/matlab/matlab2016a/"

spm_folder=/applications/spm/spm12_7219
SUBJDIR="/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/raw_data/images/";
scriptdir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/scripts/mp2rage
fsldir=/applications/fsl/fsl-5.0.10

module load ANTS/2.2.0
#"27734/20190902_U-ID46027" "28061/20190911_U-ID46160" 28428/20190903_U-ID46074
declare -a mysubjs=("29317/20190902_U-ID46030
29321/20190902_U-ID46038
29332/20190903_U-ID46058
29336/20190903_U-ID46066
29358/20190905_U-ID46106
29382/20190911_U-ID46164
29383/20190912_U-ID46168");

for subj in $mysubjs
do 
#remove slash at end of mp2rage?
inputPath=${SUBJDIR}/"$subj"/mp2rage
cd ${inputPath};
echo $inputPath;

fslsplit ${inputPath}/mp2rage_magnitude.nii.gz ${inputPath}/mag -t
fslsplit ${inputPath}/mp2rage_phase.nii.gz ${inputPath}/phas -t


#1. Run the PSIR scripts that combine the two magnitude images acquired on the scanner.
"$scriptdir"/PSIR_MP2RAGE -c -d ${inputPath} -m mag0000 -n mag0001 -p phas0000 -q phas0001
echo "PSIR recon is done";

g0="mag0000_PSIR_skulled.nii.gz";
g="mag0000_PSIR_skulled_std.nii.gz";
s=`basename ${g%.nii.gz}`;
p=`dirname ${g}`; 

n4=${p}/n4"$s".nii.gz; 

#1.1. Make the PSIR image in standardized MNI coordinates
${fsldir}/bin/fslreorient2std ${g0} ${g}

gzip mag0000_PSIR_skulled_std.nii
gzip mag0000_PSIR_skulled.nii

# 2. Extra Bias Field correction for mp2rage image after Olivier's script is run.
N4BiasFieldCorrection -d 3 -i ${g} -o ${n4}  -r 1 -c [50x50x30x20,1e-6] -b [200]; 

# 3. run SPM segmentation on Bias field corrected image and then run the cr_spm_bet.m script adapted by Simon
cd ${scriptdir} 

gzip -d ${inputPath}/${n4};
rm ${inputPath}/${n4};
n4=${p}/n4"$s".nii; 

# 4. Run segmentation of PSIR Image
#"$MATLABPATH"/bin/matlab.nowrap -nodesktop -nosplash -nodisplay -r "try, seg_PSIR('${inputPath}','${n4}'); end ; quit"
"$MATLABPATH"/bin/matlab.nowrap -nodesktop -nosplash -nodisplay -r "try, seg_PSIR('${inputPath}','/n4"$s".nii'); end ; quit"

# 5. Run the bet in the PSIR image with the help of the segemnted tissues
"$MATLABPATH"/bin/matlab.nowrap -nodesktop -nosplash -nodisplay -r "try, cr_spm_bet('${inputPath}/${n4}'); end ; quit"

i_brain=n4mag0000_PSIR_skulled_std_struc_brain.nii;
s=`basename ${i_brain%.nii}`;
i_brain_mask="$s"_mask.nii.gz;

# 6. Create a brain mask from the skullstripped image
fslmaths $inputPath/$i_brain -div $inputPath/$i_brain $inputPath/$i_brain_mask


done


