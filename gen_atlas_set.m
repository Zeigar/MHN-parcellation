function [atlas_diff, scalar_diff] = gen_atlas_set(atlases, pos, neg, field_bound, coord_voxel_1d, thres, ...
    pos_atlas_file, pos_conf_file, neg_atlas_file, neg_conf_file, ...
    all_atlas_file, all_conf_file, diff_atlas_file)

num_clusters = size(atlases, 2);

mean_atlas_pos = mean(atlases(:,:,pos),3);
mean_atlas_neg = mean(atlases(:,:,neg),3);
mean_atlas_all = mean(atlases, 3);

total_pos = sum(mean_atlas_pos, 2);
total_neg = sum(mean_atlas_neg, 2);
total_all = sum(mean_atlas_all, 2);

mean_atlas_pos = mean_atlas_pos ./ repmat(total_pos, 1, num_clusters);
mean_atlas_neg = mean_atlas_neg ./ repmat(total_neg, 1, num_clusters);
mean_atlas_all = mean_atlas_all ./ repmat(total_all, 1, num_clusters);

[conf_atlas_pos, atlas_pos] = max(mean_atlas_pos, [], 2);
[conf_atlas_neg, atlas_neg] = max(mean_atlas_neg, [], 2);
[conf_atlas_all, atlas_all] = max(mean_atlas_all, [], 2);

invalid_pos = find(total_pos <= thres);
invalid_neg = find(total_neg <= thres);
invalid_all = find(total_all <= thres);

atlas_pos(invalid_pos) = 0;
atlas_neg(invalid_neg) = 0;
atlas_all(invalid_all) = 0;
conf_atlas_pos(invalid_pos) = 0;
conf_atlas_neg(invalid_neg) = 0;
conf_atlas_all(invalid_all) = 0;

%% pos-neg diff map (DL-divergence)
% atlas_diff = sum((mean_atlas_neg + 1e-12) .* log((mean_atlas_neg + 1e-12)./(mean_atlas_pos + 1e-12)), 2);
atlas_diff = sum((sqrt(mean_atlas_neg) - sqrt(mean_atlas_pos)).^2, 2);
invalid_diff = find(total_pos <= thres | total_neg <= thres);
atlas_diff(invalid_diff) = 0;
scalar_diff = sum(atlas_diff);


%% save the iamges
nii_ref = load_untouch_nii('/fs/nara-scratch/qwang37/brain_data/aal_90_2mm_correct.nii.gz');
% pos
field = zeros(field_bound);
field(coord_voxel_1d) = atlas_pos;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, pos_atlas_file);

field(coord_voxel_1d) = conf_atlas_pos;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, pos_conf_file);

% neg
field(coord_voxel_1d) = atlas_neg;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, neg_atlas_file);

field(coord_voxel_1d) = conf_atlas_neg;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, neg_conf_file);

% all
field(coord_voxel_1d) = atlas_all;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, all_atlas_file);

field(coord_voxel_1d) = conf_atlas_all;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, all_conf_file);

% diff
field(coord_voxel_1d) = atlas_diff;
nii_struct = make_nii(field);
nii_struct = modify_hdr(nii_struct, nii_ref);
save_nii(nii_struct, diff_atlas_file);

    
