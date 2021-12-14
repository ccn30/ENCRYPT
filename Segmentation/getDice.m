function getDice(subject,rater1,rater2)
% Calculte dice similarity index for nifti mask segmentations between two
% raters
rater1 = 'Coco';
rater2 = 'Marianna';
subject = '25846';
maskDIR=['/home/ccn30/rds/rds-p00500_encrypt-URQgmO1brZ0/p00500/ENCRYPT_MTLmasks/' subject];

% define masks rater 1
ASHS_L_R1 = [maskDIR '/' subject '_left_lfseg_corr_usegray_noCysts_' rater1 '.nii.gz'];
ASHS_R_R1 = [maskDIR '/' subject '_right_lfseg_corr_usegray_noCysts_' rater1 '.nii.gz'];
pmEC_DTI_L_R1 = [maskDIR '/pmEC_left_HybridDTI_T2_' rater1 '.nii.gz'];
pmEC_DTI_R_R1 = [maskDIR '/pmEC_right_HybridDTI_T2_' rater1 '.nii.gz'];
combinedEC_Maass_R_R1 = [maskDIR '/combinedEC_right_HybridMaass_T2_' rater1 '.nii.gz'];
combinedEC_Maass_L_R1 = [maskDIR '/combinedEC_left_HybridMaass_T2_' rater1 '.nii.gz'];

% define masks rater 2
ASHS_L_R2 = [maskDIR '/' subject '_left_lfseg_corr_usegray_noCysts_' rater2 '.nii.gz'];
ASHS_R_R2 = [maskDIR '/' subject '_right_lfseg_corr_usegray_noCysts_' rater2 '.nii.gz'];
pmEC_DTI_L_R2 = [maskDIR '/pmEC_left_HybridDTI_T2_' rater2 '.nii.gz'];
pmEC_DTI_R_R2 = [maskDIR '/pmEC_right_HybridDTI_T2_' rater2 '.nii.gz'];
combinedEC_Maass_R_R2 = [maskDIR '/combinedEC_right_HybridMaass_T2_' rater2 '.nii.gz'];
combinedEC_Maass_L_R2 = [maskDIR '/combinedEC_left_HybridMaass_T2_' rater2 '.nii.gz'];

%% LEFT SIDE

imageR1 = double(niftiread(pmEC_DTI_L_R1));
imageR2 = double(niftiread(pmEC_DTI_L_R2));
cmd = [fslmaths ${hybridmaskT2dir}/"$subject"_right_lfseg_corr_usegray_ECsubdivisions_EPI.nii.gz -thr 16.5 -uthr 17.5 -bin ${rightpmECT2xEPI} -odt char
% per slice??
ind = find(imageR1);
[x,y,z] = ind2sub(size(imageR1),ind);
% get last slice
z(end);


for slice=  1:z(end)
dslice(slice,1) = dice(imageR1(:,:,slice),imageR2(:,:,slice));
end

end