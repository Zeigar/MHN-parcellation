%% analyze the connectivity data
% close all; clear;
[subjID,DX] = importSchizoFile('exp.csv');
d_dir = dir;
conn_vec_all = [];
label_all = [];
id = 1;
num_clusters = 90;
for i = 1:length(d_dir)
    dirname = d_dir(i).name;
    if dirname(1) == 'd'
        s_dir = dir(dirname);
        for j = 1:length(s_dir)
            subname = s_dir(j).name;
            [flag, loc] = ismember(subname, subjID);
            if flag
                id = id+1;
                filename = [dirname, '/', subname, '/graph_aal_90_patched.mat'];
%                 filename = [dirname, '/', subname, '/graph_start.mat'];
                conn_vec = load(filename);
                conn_vec = conn_vec.graph;
                conn_vec(1:num_clusters+1:end) = 0;
                conn_vec_all = [conn_vec_all; conn_vec(:)'];
                label_all = [label_all; DX(loc)];
            end
        end
    end
end

pos = (label_all==1);
neg = (label_all==0);
conn_vec_pos = conn_vec_all(pos,:);
conn_vec_neg = conn_vec_all(neg,:);

% [coef, conn_vec_pca] = pca(conn_vec_all);
% conn_vec_pca_pos = conn_vec_pca(pos,:);
% conn_vec_pca_neg = conn_vec_pca(neg,:);

d = size(conn_vec_all,2);

% unnormalized
w_rank = zeros(d, 1);
t_rank = zeros(d, 1);
for i = 1:d
    w_rank(i) = ranksum(conn_vec_pos(:,i), conn_vec_neg(:,i));
    [h,t_rank(i)] = ttest2(conn_vec_pos(:,i), conn_vec_neg(:,i));
end

[sw_conn, sw_i_conn] = sort(w_rank, 'ascend');
[st_conn, st_i_conn] = sort(t_rank, 'ascend');

[sw_i_conn_xy] = [ceil(sw_i_conn/90), mod(sw_i_conn-1, 90)+1];
[st_i_conn_xy] = [ceil(st_i_conn/90), mod(st_i_conn-1, 90)+1];

sw_conn = sw_conn(1:2:8009);
st_conn = st_conn(1:2:8009);

sw_i_conn = sw_i_conn(1:2:8009);
st_i_conn = st_i_conn(1:2:8009);

sw_i_conn_xy = sw_i_conn_xy(1:2:8009,:);
st_i_conn_xy = st_i_conn_xy(1:2:8009,:);

% map the name string
index = import_atlas_name('Atlases/atlas90.cod');

sw_i_conn_xy_name = index(sw_i_conn_xy);
st_i_conn_xy_name = index(st_i_conn_xy);

% normalized 
conn_vec_all_norm = conn_vec_all./repmat(sum(conn_vec_all,2),1,d);
conn_vec_pos_norm = conn_vec_all_norm(pos,:);
conn_vec_neg_norm = conn_vec_all_norm(neg,:);
w_rank_norm = zeros(d, 1);
t_rank_norm = zeros(d, 1);
for i = 1:d
    w_rank_norm(i) = ranksum(conn_vec_pos_norm(:,i), conn_vec_neg_norm(:,i));
    [h,t_rank_norm(i)] = ttest2(conn_vec_pos_norm(:,i), conn_vec_neg_norm(:,i));
end

[sw_conn_norm, sw_i_conn_norm] = sort(w_rank_norm, 'ascend');
[st_conn_norm, st_i_conn_norm] = sort(t_rank_norm, 'ascend');

[sw_i_conn_xy_norm] = [ceil(sw_i_conn_norm/90), mod(sw_i_conn_norm-1, 90)+1];
[st_i_conn_xy_norm] = [ceil(st_i_conn_norm/90), mod(st_i_conn_norm-1, 90)+1];

sw_conn_norm = sw_conn_norm(1:2:8009);
st_conn_norm = st_conn_norm(1:2:8009);

sw_i_conn_norm = sw_i_conn_norm(1:2:8009);
st_i_conn_norm = st_i_conn_norm(1:2:8009);

sw_i_conn_xy_norm = sw_i_conn_xy_norm(1:2:8009,:);
st_i_conn_xy_norm = st_i_conn_xy_norm(1:2:8009,:);

% map the name string
index = import_atlas_name('Atlases/atlas90.cod');

sw_i_conn_xy_name_norm = index(sw_i_conn_xy_norm);
st_i_conn_xy_name_norm = index(st_i_conn_xy_norm);


