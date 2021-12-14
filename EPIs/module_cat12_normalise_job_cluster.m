%-----------------------------------------------------------------------
% Job saved on 20-Feb-2018 09:33:11 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
global spmpath
matlabbatch{1}.spm.tools.cat.estwrite.data = '<UNDEFINED>';
matlabbatch{1}.spm.tools.cat.estwrite.nproc = 0;
matlabbatch{1}.spm.tools.cat.estwrite.opts.tpm = {[spmpath 'tpm/TPM.nii']};
matlabbatch{1}.spm.tools.cat.estwrite.opts.affreg = 'mni';
matlabbatch{1}.spm.tools.cat.estwrite.opts.biasstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.APP = 1070;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.LASstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.gcutstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.cleanupstr = 0.5;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.darteltpm = {[spmpath 'toolbox/cat12/templates_1.50mm/Template_1_IXI555_MNI152.nii']};
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.shootingtpm = {[spmpath 'toolbox/cat12/templates_1.50mm/Template_0_IXI555_MNI152_GS.nii']};
matlabbatch{1}.spm.tools.cat.estwrite.extopts.registration.regstr = 0;
matlabbatch{1}.spm.tools.cat.estwrite.extopts.vox = 1.5;
matlabbatch{1}.spm.tools.cat.estwrite.output.surface = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.ROI = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.native = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.dartel = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.native = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.dartel = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.bias.warped = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.jacobian.warped = 0;
matlabbatch{1}.spm.tools.cat.estwrite.output.warps = [1 1];