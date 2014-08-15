%% registrating the original atlas to a set of binary masks
clear; close all;
addpath('NIFTI_20130306');

% atlas = load_untouch_nii('HarvardOxford-cort-maxprob-thr25-2mm.nii.gz');
% atlas = load_untouch_nii('~/Downloads/Atlases/aal_90_2mm_correct.nii.gz');
% atlas = load_untouch_nii('/fs/nara-scratch/qwang37/fsl/data/atlases/Striatum/striatum-structural-2mm.nii.gz');
atlas = load_untouch_nii('/fs/nara-scratch/qwang37/fsl/data/atlases/Striatum/striatum-con-label-thr25-3sub-2mm.nii.gz');
atlas_hdr = atlas.hdr;
atlas_hdr.dime.cal_max = 1;
atlas_hdr.dime.glmax = 1;
atlas_img= atlas.img;

dirname = 'atlas_striatum_con';
if ~exist(dirname, 'dir')
    mkdir(dirname);
end

for i = min(atlas_img(:)) : max(atlas_img(:))
    atlas_img_bin = uint8(atlas_img==i);
    filename = [dirname, '/', 'striatum_con_2mm_', num2str(i), '.nii.gz'];
    atlas_nii = struct('hdr', atlas_hdr, 'img', atlas_img_bin);
    save_nii(atlas_nii, filename);
end

