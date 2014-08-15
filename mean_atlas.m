%% calculate the mean atlas in a group
%% collect statistics of the parcellation results
% clear;close all;
% num_clusters = 90;
% [subjID,DX] = importSchizoFile('exp.csv');
% d_dir = dir;
% field_bound = [91,109,91];
%
% coord_voxel_1d = [];
%
% % first pass: determine the valid voxels
% for i = 1:length(d_dir)
%     dirname = d_dir(i).name;
%     if dirname(1) == 'd'
%         s_dir = dir(dirname);
%         for j = 1:length(s_dir)
%             subname = s_dir(j).name;
%             [flag, loc] = ismember(subname, subjID);
%             if flag
% %                 filename = [dirname, '/', subname, '/parcel_result_start_aal_90_single_.nii.gz'];
% %                 filename = [dirname, '/', subname, '/parcel_result_aal_90_single.nii.gz']; % note: this was done with black0.5 and low3.
% %                 filename = [dirname, '/', subname, '/parcel_result_black0.5_cort_single.nii.gz'];
% %                 filename = [dirname, '/', subname, '/parcel_result_black0.5_cort_double.nii.gz'];
%                 filedir = [dirname, '/', subname];
%                 fprintf('First scan, processing %s\n', filedir);
%                 for k = 1:num_clusters
%                     filename = [filedir, '/atlas_MNI/atlas_local_', num2str(k), '.nii.gz'];
%                     nii = load_untouch_nii(filename);
%                     nii_img = nii.img(:);
%                     coord_voxel_1d = union(coord_voxel_1d, find(nii_img > 0));
%                 end
%             end
%         end
%     end
% end
%
% atlas = single(zeros(length(coord_voxel_1d), num_clusters));
% atlases = [];
% label_all = [];
%
% for i = 1:length(d_dir)
%     dirname = d_dir(i).name;
%     if dirname(1) == 'd'
%         s_dir = dir(dirname);
%         for j = 1:length(s_dir)
%             subname = s_dir(j).name;
%             [flag, loc] = ismember(subname, subjID);
%             if flag
% %                 filename = [dirname, '/', subname, '/parcel_result_start_aal_90_single_.nii.gz'];
% %                 filename = [dirname, '/', subname, '/parcel_result_aal_90_single.nii.gz']; % note: this was done with black0.5 and low3.
% %                 filename = [dirname, '/', subname, '/parcel_result_black0.5_cort_single.nii.gz'];
% %                 filename = [dirname, '/', subname, '/parcel_result_black0.5_cort_double.nii.gz'];
%                 filedir = [dirname, '/', subname];
%                 fprintf('Second scan, processing %s\n', filedir);
%                 for k = 1:num_clusters
%                     filename = [filedir, '/atlas_MNI/atlas_local_', num2str(k), '.nii.gz'];
%                     nii = load_untouch_nii(filename);
%                     nii_img = single(nii.img(:));
%                     atlas(:,k) = nii_img(coord_voxel_1d);
%                 end
%                 atlases = cat(3,atlases, atlas);
%                 label_all = [label_all; DX(loc)];
%             end
%         end
%     end
% end
%
% for i = 1:7
%     eval(['atlases_part', num2str(i), ' = atlases(:,:,(i-1)*18+1:i*18);']);
%     save(['mean_atlas_data_part', num2str(i), '.mat'], ['atlases_part', num2str(i)]);
% end
%
% save mean_atlas_data_misc coord_voxel_1d label_all;

clear; close all;
atlases = [];
for i = 1:7
    load(['mean_atlas_data_part', num2str(i), '.mat']);
    eval(['atlases = cat(3, atlases, atlases_part', num2str(i), ');']);
end
load mean_atlas_data_misc;
thres = 0.5;
figure; hold on;
%% the mean atlases
pos = find(label_all==1);
neg = find(label_all==0);
n_pos = length(pos);
n_neg = length(neg);
n_all = length(label_all);
n_samples = 10;
scalar_diff = zeros(n_samples,1);
scalar_diff_rand = zeros(n_samples,1);
scalar_diff_control = zeros(n_samples,1);
for i = 1:n_samples
    fprintf('calculating the mean atlases for pos-neg pair %d...\n', i);
    perm = randperm(n_pos);
    pos_sub = pos(perm(1:n_neg/2));
    perm = randperm(n_neg);
    neg_sub = neg(perm(1:n_neg/2));
    
    [diff, scalar_diff(i)] = gen_atlas_set(atlases, pos_sub, neg_sub, field_bound, coord_voxel_1d, thres, 'atlas_pos.nii.gz', 'conf_atlas_pos.nii.gz', ...
        'atlas_neg.nii.gz', 'conf_atlas_neg.nii.gz', 'atlas_all.nii.gz', 'conf_atlas_all.nii.gz', ...
        'atlas_diff.nii.gz');
    
    diff = sort(diff, 'descend');
    h1 = plot(diff(1:50000), 'r');
end


%% the random permutation control
for i = 1: n_samples
    fprintf('calculating the mean atlases for random pair %d...\n', i);
    perm = randperm(n_all);
    pos_sub = perm(1:n_neg/2);
    neg_sub = perm(n_neg/2+1:n_neg);
    
    [diff_rand, scalar_diff_rand(i)] = gen_atlas_set(atlases, pos_sub, neg_sub, field_bound, coord_voxel_1d, thres, 'atlas_rand1.nii.gz', 'conf_atlas_rand1.nii.gz', ...
        'atlas_rand2.nii.gz', 'conf_atlas_rand2.nii.gz', 'atlas_all_rand.nii.gz', 'conf_atlas_all_rand.nii.gz', ...
        'atlas_diff_rand.nii.gz');
    
    
    diff_rand = sort(diff_rand, 'descend');
    h2 = plot(diff_rand(1:50000), 'b');
end

for i = 1: n_samples
    fprintf('calculating the mean atlases for control pair %d...\n', i);
    perm = randperm(n_neg);
    pos_sub = neg(perm(1:n_neg/2));
    neg_sub = neg(perm(n_neg/2+1:n_neg));
    
    [diff_rand_control, scalar_diff_rand_control(i)] = gen_atlas_set(atlases, pos_sub, neg_sub, field_bound, coord_voxel_1d, thres, 'atlas_rand1.nii.gz', 'conf_atlas_rand1.nii.gz', ...
        'atlas_rand2.nii.gz', 'conf_atlas_rand2.nii.gz', 'atlas_all_rand.nii.gz', 'conf_atlas_all_rand.nii.gz', ...
        'atlas_diff_rand.nii.gz');
    
    
    diff_rand_control = sort(diff_rand_control, 'descend');
    h3 = plot(diff_rand_control(1:50000), 'g');
end

legend([h1,h2,h3], 'schizo-normal', 'random-all', 'random-normal');

[h, prand] = ttest2(scalar_diff, scalar_diff_rand);
[h, pcontrol] = ttest2(scalar_diff, scalar_diff_rand_control);