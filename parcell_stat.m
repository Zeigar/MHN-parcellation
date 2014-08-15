%% collect statistics of the parcellation results
% clear;close all;
num_clusters = 90;
[subjID,DX] = importSchizoFile('exp.csv');
d_dir = dir;
parcell_vec_all = [];
parcell_vec_norm_all = [];
label_all = [];
vol_all = [];
id = 1;
for i = 1:length(d_dir)
    dirname = d_dir(i).name;
    if dirname(1) == 'd'
        s_dir = dir(dirname);
        for j = 1:length(s_dir)
            subname = s_dir(j).name;
            [flag, loc] = ismember(subname, subjID);
            if flag
                id = id+1;
                filename = [dirname, '/', subname, '/parcel_result_start_aal_90_single.nii.gz'];
%                 filename = [dirname, '/', subname, '/parcel_result_aal_90_single.nii.gz']; % note: this was done with black0.5 and low3.
%                 filename = [dirname, '/', subname, '/parcel_result_black0.5_cort_single.nii.gz'];
%                 filename = [dirname, '/', subname, '/parcel_result_black0.5_cort_double.nii.gz'];
%                 filename = [dirname, '/', subname, '/parcel_result_aal_90_black0.5_low4_patched.nii.gz'];
                volname = [dirname, '/', subname, '/track_aal_90_0/coords_for_fdt_matrix3']; % read the whole brain volume
                [parcell_vec_norm, parcell_vec, vol] = parcell_vector(filename, num_clusters, volname);
                parcell_vec_all = [parcell_vec_all; parcell_vec];
                parcell_vec_norm_all = [parcell_vec_norm_all; parcell_vec_norm];
                vol_all = [vol_all; vol];
                label_all = [label_all; DX(loc)];
%                 save([dirname, '/', subname, '/parcel_vec.txt'], 'parcell_vec', '-ascii', '-tabs');
            end
        end
    end
end

pos = (label_all==1);
neg = (label_all==0);
parcell_vec_pos = parcell_vec_all(pos,:);
parcell_vec_neg = parcell_vec_all(neg,:);
parcell_vec_norm_pos = parcell_vec_norm_all(pos,:);
parcell_vec_norm_neg = parcell_vec_norm_all(neg,:);
vol_all_pos = vol_all(pos,:);
vol_all_neg = vol_all(neg,:);
num_clusters = size(parcell_vec_all, 2);
w_rank = zeros(num_clusters, 1);
t_rank = zeros(num_clusters, 1);
w_rank_norm = zeros(num_clusters,1);
t_rank_norm = zeros(num_clusters,1);
for i = 1:num_clusters
    w_rank(i) = ranksum(parcell_vec_pos(:,i), parcell_vec_neg(:,i));
    [h,t_rank(i)] = ttest2(parcell_vec_pos(:,i), parcell_vec_neg(:,i));
    w_rank_norm(i) = ranksum(parcell_vec_norm_pos(:,i), parcell_vec_norm_neg(:,i));
    [h,t_rank_norm(i)] = ttest2(parcell_vec_norm_pos(:,i), parcell_vec_norm_neg(:,i));
end

[sw, sw_i] = sort(w_rank, 'ascend');
[st, st_i] = sort(t_rank, 'ascend');
[sw_norm, sw_i_norm] = sort(w_rank_norm, 'ascend');
[st_norm, st_i_norm] = sort(t_rank_norm, 'ascend');

% map the name string
index = import_atlas_name('Atlases/atlas90.cod');

sw_i_norm_name = index(sw_i_norm);
st_i_norm_name = index(st_i_norm);


w_rank_vol = ranksum(vol_all_pos, vol_all_neg);
[h,t_rank_vol] = ttest2(vol_all_pos, vol_all_neg);




    