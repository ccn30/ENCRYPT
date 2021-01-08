#!/bin/bash

# arguments from ASHS_submit.sh
pathstem=${1}
subjID=${2}
workdir=${3}

# initialise software roots
export antsroot=/applications/ANTS/2.3.4/bin
export ASHS_ROOT=/home/ccn30/privatemodules/ASHS/ashs-fastashs_beta
#export atlasdir=/home/ccn30/ENCRYPT/atlases/magdeburgatlas
export atlasdir=/home/ccn30/ENCRYPT/atlases/utrechtatlas

# initialise subject-wise paths
subject="$(cut -d'/' -f1 <<<"$subjID")"
rawpathstem=${pathstem}/images/${subjID}
outputpath=${pathstem}/segmentation/ASHS/${subject}

cd ${rawpathstem}

T2dir=$(ls -d Series_???_Highresolution_TSE_PAT2_100)
T2path=${rawpathstem}/${T2dir}

cd ${workdir}

#------------------------------------------------------------------------#
# Run ASHS					 			 #
#------------------------------------------------------------------------#
# changing to reorientated T1s and updated N4 T2s after poor performance first batch ASHS

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
		mkdir ${outputpath}
fi

#######################################################
# 1. Running for original images (whole brain T1, raw T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $T2

originaloutput=${outputpath}/original
cd $originaloutput

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${wholeT1} -f ${T2} -w ${originaloutput}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 2. Running for N4 T2 (whole T1, N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

N4T2output=${outputpath}/N4T2
cd $N4T2output

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${wholeT1} -f ${N4T2} -w ${N4T2output}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 3. Running for brain T1 (brain T1, N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

brainT1output=${outputpath}/N4T2skullstrippedT1
cd $brainT1output

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${brainT1} -f ${N4T2} -w ${brainT1output}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 4. Running for denoised T1 and T2 (denoise whole T1, denoise N4 T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $N4T2

denoiseoutput=${outputpath}/DenoiseWhole
cd $denoiseoutput

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseWholeT1} -f ${DenoiseN4T2} -w ${denoiseoutput}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 5. Running for original images (brain T1, raw T2)
echo "Beginning ASHS for: " $subject
echo "INPUT:" $wholeT1 $T2

originalssoutput=${outputpath}/originalskullstripped
cd $originalssoutput

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${brainT1} -f ${T2} -w ${originalssoutput}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 6. Running for denoised T1 and T2 (denoise brain T1, denoise N4 T2)
echo "Beginning ASHS for: " $subject

denoisebrainoutput=${outputpath}/DenoiseBrain
cd $denoisebrainoutput

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseBrainT1} -f ${DenoiseN4T2} -w ${denoisebrainoutput}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 7. Running for denoised T1 and normal T2 (denoise brain T1, N4 T2) - NEW UTRECHT ATLAS
echo "Beginning ASHS for: " $subject

denoiseT1N4T2output=${outputpath}/DenoiseT1N4T2Utrecht
cd $denoiseT1N4T2output

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
#!$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseBrainT1} -f ${N4T2} -w ${denoiseT1N4T2output}

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"

#######################################################
# 8. Running for denoised whole T1 and normal T2 (denoise whole T1, N4 T2)
echo "Beginning ASHS for: " $subject

denoiseWholeT1N4T2output=${outputpath}/DenoiseWholeT1N4T2Utrecht
cd $denoiseT1N4T2output

# Set a timer
SECONDS=0
start=(`date +%T`)
echo "ASHS started at $start"

# run ASHS
$ASHS_ROOT/bin/ashs_main.sh -I $subject -a $atlasdir -g ${DenoiseWholeT1} -f ${N4T2} -w ${denoiseWholeT1N4T2output} -N

end=(`date +%T`)
printf "\n\n ASHS completed for $subject at $end, it took $(($SECONDS/86400)) days $(($SECONDS/3600)) hours $(($SECONDS%3600/60)) minutes and $(($SECONDS%60)) seconds to complete \n\n"
