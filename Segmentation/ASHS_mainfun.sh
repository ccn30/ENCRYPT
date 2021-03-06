#!/bin/bash

# arguments from ASHS_submit.sh
pathstem=${1}
subjID=${2}
workdir=${3}

# initialise software roots
export antsroot=/applications/ANTS/2.3.4/bin
export ASHS_ROOT=/home/ccn30/privatemodules/ASHS/ashs-fastashs_beta
export Magdeburgatlasdir=/home/ccn30/ENCRYPT/atlases/magdeburgatlas
export atlasdir=/home/ccn30/ENCRYPT/atlases/utrechtatlas

# initialise subject-wise paths (CHECK ATLAS)
subject="$(cut -d'/' -f1 <<<"$subjID")"
rawpathstem=${pathstem}/images/${subjID}
#outputpath=${pathstem}/segmentation/ASHS_Utrecht/${subject}
outputpath=${pathstem}/segmentation/ASHS_Magdeburg2/${subject}
coregDir=${pathstem}/registrations/${subject}

cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${workdir}

wholeT1=${rawpathstem}/mp2rage/Rn4mag0000_PSIR_skulled_std.nii
brainT1=${rawpathstem}/mp2rage/n4mag0000_PSIR_skulled_std_struc_brain.nii
DenoiseWholeT1=${rawpathstem}/mp2rage/Rdenoise_n4mag0000_PSIR_skulled_std.nii
DenoiseBrainT1=${rawpathstem}/mp2rage/Rdenoise_n4mag0000_PSIR_skulled_std_struc_brain_mask.nii

T2=${T2path}/t2.nii
N4T2=${T2path}/n42_t2.nii
DenoiseN4T2=${T2path}/denoise_n42_t2.nii

if [ -f "${outputpath}" ]; then
		echo "${outputpath} exists"
	else
		mkdir -p ${outputpath}
fi


#------------------------------------------------------------------------#
# Run ASHS					 			 								 #
#------------------------------------------------------------------------#
# changing to reorientated T1s and updated N4 T2s after poor performance first batch ASHS

#######################################################
# 1. Running for original images (whole brain T1, raw T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $T2

originaloutput=${outputpath}/original
cd $originaloutput

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${wholeT1} -f ${T2} -w ${originaloutput}

#######################################################
# 2. Running for N4 T2 (whole T1, N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

N4T2output=${outputpath}/N4T2
cd $N4T2output

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${wholeT1} -f ${N4T2} -w ${N4T2output}

#######################################################
# 3. Running for brain T1 (brain T1, N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

brainT1output=${outputpath}/T1BrainN4T2
mkdir -p $brainT1output
cd $brainT1output
mkdir affine_t1_to_template
cd affine_t1_to_template
cp ${coregDir}/t1_to_template_affineMAG.mat t1_to_template_affine.mat
cp ${coregDir}/t1_to_template_affine_invMAG.mat t1_to_template_affine_inv.mat
cp ${coregDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz t1_to_template_affine.nii.gz
cd ..

# run ASHS
$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $Magdeburgatlasdir -g ${brainT1} -f ${N4T2} -w ${brainT1output} -N

#######################################################
# 4. Running for denoised T1 and T2 (denoise whole T1, denoise N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

denoiseoutput=${outputpath}/DenoiseWT1DenoiseT2
mkdir -p $denoiseoutput
cd $denoiseoutput
mkdir affine_t1_to_template
cd affine_t1_to_template
cp ${coregDir}/t1_to_template_affineMAG.mat t1_to_template_affine.mat
cp ${coregDir}/t1_to_template_affine_invMAG.mat t1_to_template_affine_inv.mat
cp ${coregDir}/T1WholexMagdeburgTempWhole_ANTs_Warped.nii.gz t1_to_template_affine.nii.gz
cd ..

# run ASHS
$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $Magdeburgatlasdir -g ${DenoiseWholeT1} -f ${DenoiseN4T2} -w ${denoiseoutput} -N

#######################################################
# 5. Running for original images (brain T1, raw T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $T2

originalssoutput=${outputpath}/originalskullstripped
cd $originalssoutput

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${brainT1} -f ${T2} -w ${originalssoutput}

#######################################################
# 6. Running for denoised T1 and T2 (denoise brain T1, denoise N4 T2)
echo "Beginning ASHS for: " $subject

denoisebrainoutput=${outputpath}/DenoiseBrainT1DenoiseT2
#mkdir -p ${denoisebrainoutput}
#cd $denoisebrainoutput
#mkdir affine_t1_to_template
#cd affine_t1_to_template
#cp ${coregDir}/t1_to_template_affine.mat t1_to_template_affine.mat
#cp ${coregDir}/t1_to_template_affine_inv.mat t1_to_template_affine_inv.mat
#cp ${coregDir}/UtrechtTempxT1_ANTs_InvWarped.nii.gz t1_to_template_affine.nii.gz
#cd ..

# run ASHS
#$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseBrainT1} -f ${DenoiseN4T2} -w ${denoisebrainoutput} -N

#######################################################
# 7. Running for denoised brain T1 and normal T2 (denoise brain T1, N4 T2)
echo "Beginning ASHS for: " $subject

denoiseT1N4T2output=${outputpath}/DenoiseT1N4T2Utrecht
cd $denoiseT1N4T2output

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseBrainT1} -f ${N4T2} -w ${denoiseT1N4T2output}

#######################################################
# 8. Running for denoised whole T1 and normal T2 (denoise whole T1, N4 T2)
echo "Beginning ASHS for: " $subject

denoiseWholeT1N4T2output=${outputpath}/DenoiseWholeT1N4T2
cd $denoiseT1N4T2output

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseWholeT1} -f ${N4T2} -w ${denoiseWholeT1N4T2output} -N


