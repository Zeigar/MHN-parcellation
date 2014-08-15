%% generate graph from a parcellation result
function graph_gen(dir_name, parcel_name, graph_name)
fprintf('processing %s...\n', dir_name);
coord = load([dir_name,'/track_aal_90_0/coords_for_fdt_matrix3']);
coord = single(coord(:,1:3));

nii = load_untouch_nii([dir_name, '/', parcel_name]);
img = nii.img;
num_clusters = 90;
num_voxels = size(coord,1);
graph = zeros(num_clusters, num_clusters);

%% coord map
field_bound = size(img);
coord_voxel_1d = zeros(num_voxels, 1);
for i = 1:num_voxels
    coord_voxel_1d(i) = 1 + coord(i,1) + field_bound(1) * (coord(i,2) + field_bound(2) * coord(i,3));
end
labels = img(coord_voxel_1d);

%% generate the graph
for d = 0:0
    fprintf('reading data %d...\n', d);
    tic;
    A = load([dir_name, '/track_aal_90_', num2str(d), '/fdt_matrix3.dot']); A = single(A);
    toc;
    fprintf('converting to block labels...\n');
    tic;    
    A(:,1) = labels(A(:,1));
    A(:,2) = labels(A(:,2));
    toc;
    fprintf('updating the graph...\n');
    tic;
    for i = 1:size(A,1)
        idx1 = A(i,1); idx2 = A(i,2);
        if idx1>0 && idx2>0
            graph(idx1, idx2) = graph(idx1, idx2) + A(i,3);
        end
    end
    toc;
    clear A;
end
graph(1:num_clusters+1:end) = 0;
            
save([dir_name, '/', graph_name], 'graph');
