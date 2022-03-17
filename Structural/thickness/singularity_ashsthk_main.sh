
pathstem=${1}
index=${2}
mysubjs=($(<${pathstem}/Scripts/subjectsID.txt))
subj=${mysubjs[${index}]}

                                         ####### Submitting the singularity script ashsthk_main #######


## scriptdir
dockerscript=/home/ashsthk/ashsthk_main.sh

## ashsthk template
atlasdir=/home/mp2011/ashsthk_template

outdir=$pathstem/Masks/Thickness

	echo "#### Beginning ASHS Thickness pipeline for "$subject" ####"

#------------------------------------------------------------------------------------------#

### T1-FS ASHS LEFT ###

#input=$pathstem/Segmentation/ASHS_orig/"$subj"/final/"${subj}"_left_lfseg_heur.nii.gz
#output=$outdir/"$subj"/T1_ASHS_orig

#if [ -f "${output}" ]; then
		#echo "${output} exists"
	#else
		#mkdir ${output}
#fi


#singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif /bin/bash ${dockerscript} \
	#-n ${subj} \
	#-l left \
	#-i ${input} \
	#-a ${atlasdir} \
	#-w ${output} 
	#-c cpu variable (8 suggested)#


#===============================================================================================#
### T1-FS ASHS RIGHT ####


input=$pathstem/Segmentation/ASHS_orig/"$subj"/final/"${subj}"_right_lfseg_heur.nii.gz
output=$outdir/"$subj"/T1_ASHS_orig

if [ -f "${output}" ]; then
		echo "${output} exists"
	else
		mkdir ${output}
fi

singularity exec /home/mp2011/rds/hpc-work/wbic/Scripts/ASHS/ashsthk_v3.sif /bin/bash ${dockerscript} \
	-n ${subj} \
	-l right \
	-i ${input} \
	-a ${atlasdir} \
	-w ${output}
	#-c cpu variable (8 suggested)#



