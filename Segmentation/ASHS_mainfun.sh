#!/bin/bash

# arguments from ASHS_sba.sh
pathstem=${1}
subjID=${2}

# initialise software roots
export antsroot=/applications/ANTS/2.2.0/bin
export ASHS_ROOT=/home/ccn30/privatemodules/ASHS/ashs-fastashs_beta
export atlasdir=/home/ccn30/ENCRYPT/atlases/magdeburgatlas

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
rawpathstem=${pathstem}/raw_data/images/${subjID}
preprocesspathstem=${pathstem}/preprocessed_data/segmentation/${subject}
outputdir=${preprocesspathstem}/ASHS
images=${pathstem}/preprocessed_data/images/${subject}

#------------------------------------------------------------------------#
# Make N4 bias corrected T2s (= ${N4T2})				 #
#------------------------------------------------------------------------#

#!T2path=${rawpathstem}/Series_033_Highresolution_TSE_PAT2_100
# tried reorient, didn't work:
#!T2=${T2path}/reorientSeries_033_Highresolution_TSE_PAT2_100_c32.nii <- swpaped z and y axes, not good
#!T2=${T2path}/Series_033_Highresolution_TSE_PAT2_100_c32.nii
T2path=${rawpathstem}/Series_039_Highresolution_TSE_PAT2_100_PatSpec
T2=${T2path}/Series_039_Highresolution_TSE_PAT2_100_PatSpec.nii

echo "Running N4BiasFieldCorrection on: " ${T2}

cd ${T2path}

#!N4T2=${T2path}/N4Series_033_Highresolution_TSE_PAT2_100_c32.nii
N4T2=${T2path}/N4Series_039_Highresolution_TSE_PAT2_100_PatSpec.nii
$antsroot/N4BiasFieldCorrection -d 3 -i ${T2} -o ${N4T2}
if [ -f "${N4T2}" ]; then
		echo ">> N4BiasFieldCorrection SUCCESS"
	else
		echo ">> N4BiasFieldCorrection FAIL"
fi 

#------------------------------------------------------------------------#
# Run ASHS					 			 #
#------------------------------------------------------------------------#

#!T1path=${rawpathstem}/mp2rage
#!wholeT1=${T1path}/reorientn4mag0000_PSIR_skulled_std.nii
#!brainT1=${T1path}/reorientn4mag0000_PSIR_skulled_std_struc_brain.nii
T1path=${pathstem}/preprocessed_data/images/${subject}

# separate denoise script created, output =
#!denoiseT1brain=${T1path}/denoiseRn4mag0000_PSIR_skulled_std_struc_brain.nii
#!denoiseT1whole=${T1path}/denoiseRn4mag0000_PSIR_skulled_std.nii
T1whole=${T1path}/structural.nii
T1brain=${T1path}/BETstructural_ANTSBrainExtractionBrain.nii.gz

if [ -f "${outputdir}" ]; then
		echo "${outputdir} exists"
	else
		mkdir ${outputdir}
fi

echo "Beginning ASHS for: " $subject
echo "OUTPUT:" $outputdir
echo "INPUT:" $T1brain $N4T2

cd $outputdir

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS (N4 corrected but not reorientated T2s, skullstripped T1s)
$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${T1brain} -f ${N4T2} -w ${outputdir}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

# previous input tests:

# second ASHS run (corrected inputs, skullstripped T1}
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject'_2' -a $atlasdir -g ${denoiseT1brain} -f ${N4T2} -w ${outputdir}
 
# first ASHS run (non corrected inputs, skullstripped T1}
#!$ASHS_ROOT/bin/ashs_main.sh -I ${subject} -a $atlasdir -g ${brainT1} -f ${T2} -w $OUTPUT

