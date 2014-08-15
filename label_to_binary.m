%% label to binary
function label_to_binary(img, outdir, num_clusters)
addpath('NIFTI_20130306');

% atlas = load_untouch_nii('HarvardOxford-cort-maxprob-thr25-2mm.nii.gz');
% atlas = load_untouch_nii('~/Downloads/Atlases/aal_90_2mm_correct.nii.gz');
% atlas = load_untouch_nii('/fs/nara-scratch/qwang37/fsl/data/atlases/Striatum/striatum-structural-2mm.nii.gz');
atlas = load_untouch_nii(img);
atlas_hdr = atlas.hdr;
atlas_hdr.dime.cal_max = 1;
atlas_hdr.dime.glmax = 1;
atlas_img= atlas.img;

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

for i = 1 : num_clusters
    atlas_img_bin = uint8(atlas_img==i);
    filename = [outdir, '/', 'atlas_local_', num2str(i), '.nii.gz'];
    atlas_nii = struct('hdr', atlas_hdr, 'img', atlas_img_bin);
    save_nii(atlas_nii, filename);
end
