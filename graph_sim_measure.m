%% produce a graph similarity matrix for all subjects
addpath matlab_network;
[subjID,DX] = importSchizoFile('exp.csv');
d_dir = dir;
conn_all = [];
label_all = [];
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
                filename = [dirname, '/', subname, '/dti_roi_conn.txt'];
                conn_vec = load(filename);
                conn_all = cat(3, conn_all, reshape(conn_vec,90,90));
                label_all = [label_all; DX(loc)];
            end
        end
    end
end

pos = find(label_all==1);
neg = find(label_all==0);
conn_pos = conn_all(:,:,pos);
conn_neg = conn_all(:,:,neg);

d = size(conn_all,3);
sim_mat = zeros(d,d);
for i = 1:d
    fprintf('processed to %d...\n', i);
    for j = 1:d
%         M1 = conn_all(:,:,i); M2 = conn_all(:,:,j);
%         M1(1:91:end) = 0; M2(1:91:end) = 0;
%         sim_nodes = graph_similarity(M1, M2);
%         sim_mat(i,j) = sum(diag(sim_nodes));
        sim_mat(i,j) = profile_similarity(conn_all(:,:,i), conn_all(:,:,j));
        
%         v1 = conn_all(:,:,i); v2 = conn_all(:,:,j);
    end
end

% visualize
sim_mat = sim_mat([pos;neg],[pos;neg]);
imagesc(sim_mat);
colorbar;