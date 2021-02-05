#!/bin/bash
# script to visualise results in itksnap simultaenously for all subjects in different windows
# needs to be called from graphics window sith source command run

pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT
#mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterRIScodes.txt

for subjID in `cat $mysubjs`
do
subject="$(cut -d'/' -f1 <<<"$subjID")"
echo "******** starting $subject ********"

## set paths to image dirs
FreeSurfT1Dir=/lustre/scratch/wbic-beta/ccn30/ENCRYPT/segmentation/Freesurfer/T1only/${subject}

#-----------------------------------

## Freeview commands (from sintr window) ##

# check pial surfaces without pial.surf files after gcut
#if [ -f "${FreeSurfT1Dir}/mri/brainmask.gcuts.mgz" ]; then

#vglrun freeview -v ${FreeSurfT1Dir}/mri/brainmask.gcuts.mgz:colormap=binary:opacity=0.6 \
#${FreeSurfT1Dir}/mri/brainmask_orig.mgz \
#${FreeSurfT1Dir}/mri/brainmask.mgz \
#${FreeSurfT1Dir}/mri/T1.mgz &
	
#else
	
#vglrun freeview -v ${FreeSurfT1Dir}/mri/brainmask.mgz \
#${FreeSurfT1Dir}/mri/wm.mgz:colormap=heat:opacity=0.4 \
#-f ${FreeSurfT1Dir}/surf/lh.orig.nofix \
#${FreeSurfT1Dir}/surf/rh.orig.nofix &
	
#fi

vglrun freeview -v \
${FreeSurfT1Dir}/mri/wm.mgz:colormap=PET:opacity=0.4 \
${FreeSurfT1Dir}/mri/brainmask.mgz:opacity=0.8 \
${FreeSurfT1Dir}/mri/T1.mgz \

#vglrun freeview -v \
#${FreeSurfT1Dir}/mri/wm.mgz:colormap=PET:opacity=0.4 \
#${FreeSurfT1Dir}/mri/brainmask.mgz:opacity=0.8 \
#${FreeSurfT1Dir}/mri/T1.mgz \
#-f ${FreeSurfT1Dir}/surf/lh.orig.nofix \
#${FreeSurfT1Dir}/surf/rh.orig.nofix \
#${FreeSurfT1Dir}/surf/lh.white:edgecolor=blue \
#${FreeSurfT1Dir}/surf/lh.pial:edgecolor=red \
#${FreeSurfT1Dir}/surf/rh.white:edgecolor=blue \
#${FreeSurfT1Dir}/surf/rh.pial:edgecolor=red &


done




# check output generally of completed subject
#vglrun freeview -v \
${FreeSurfT1Dir}/mri/T1.mgz \
${FreeSurfT1Dir}/mri/wm.mgz \
${FreeSurfT1Dir}/mri/brainmask.mgz \
${FreeSurfT1Dir}/mri/aseg.mgz:colormap=lut:opacity=0.2 \
-f ${FreeSurfT1Dir}/surf/lh.white:edgecolor=blue \
${FreeSurfT1Dir}/surf/lh.pial:edgecolor=red \
${FreeSurfT1Dir}/surf/rh.white:edgecolor=blue \
${FreeSurfT1Dir}/surf/rh.pial:edgecolor=red

# for direct commandline call in subject dir
#vglrun freeview -v \
mri/T1.mgz \
mri/wm.mgz \
mri/brainmask.mgz \
mri/aseg.mgz:colormap=lut:opacity=0.2 \
-f surf/lh.white:edgecolor=blue \
surf/lh.pial:edgecolor=red \
surf/rh.white:edgecolor=blue \
surf/rh.pial:edgecolor=red
