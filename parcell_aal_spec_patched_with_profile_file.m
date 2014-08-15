function parcell_aal_spec_patched_with_profile_file(dirname, dim_low, num_clusters, result_name, conn_file, drop_thres)   % the interface updated
%% spectral clustering on the standard space
% function parcell_aal_spec_patched_with_profile_file(dirname, dimlow, num_clusters, result_name, conn_file, drop_thres)  


%% load reference header structure
% nii_standard = load_untouch_nii('/usr/share/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz');
nii_ref = load_untouch_nii('/fs/nara-scratch/qwang37/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz');
% nii_ref = load_untouch_nii([dirname, '/atlas_aal_90/aal_90_2mm_1.nii.gz']);

fprintf('processing %s...\n', dirname);
coord = load('/fs/nara-scratch/qwang37/brain_data/scripts/keyfile', '-ascii');
% coord = single(coord(:,1:3));
% parameters
% num_clusters = 90;
num_voxels = size(coord,1);
% field_bound = [128,104,64];
field_bound = size(nii_ref.img);

%% neighbor_map
% construct the coordinate mapping first
fprintf('constructing coordinate mapping...\n');
tic;

neighbor_dist = 2; % distance of "neighbor nodes"
num_neighbors = 0;
for x = -neighbor_dist : neighbor_dist
    for y = -floor(sqrt(neighbor_dist^2-x^2)) : floor(sqrt(neighbor_dist^2-x^2))
        num_neighbors = num_neighbors + 2*floor(sqrt(neighbor_dist^2-x^2-y^2)) + 1;
    end
end
num_neighbors = num_neighbors - 1;

grid_map_start = [min(coord(:,1)), min(coord(:,2)), min(coord(:,3))];
grid_map_end = [max(coord(:,1)), max(coord(:,2)), max(coord(:,3))];
grid_map = zeros(grid_map_end(1)-grid_map_start(1)+1+2*neighbor_dist, ...
    grid_map_end(2)-grid_map_start(2)+1+2*neighbor_dist, ...
    grid_map_end(3)-grid_map_start(3)+1+2*neighbor_dist);

coord_voxel_1d = zeros(num_voxels, 1);
for i = 1:num_voxels
    coord_voxel = coord(i,1:3) - grid_map_start + 1 + neighbor_dist;
    coord_voxel_1d(i) = 1 + coord(i,1) + field_bound(1) * (coord(i,2) + field_bound(2) * coord(i,3));
    grid_map(coord_voxel(1), coord_voxel(2), coord_voxel(3)) = i;
end

dist = zeros(1, num_neighbors);
x_lim = neighbor_dist;
idn = 1;
for x = -x_lim:x_lim
    y_lim = floor(sqrt(neighbor_dist^2-x^2));
    for y = -y_lim:y_lim
        z_lim = floor(sqrt(neighbor_dist^2-x^2-y^2));
        for z = -z_lim:z_lim
            if x==0 && y==0 && z==0, continue; end
            dist(idn) = sqrt(x^2+y^2+z^2);
            idn = idn+1;
        end
    end
end

neighbor_map = zeros(num_voxels, num_neighbors);
for i = 1:num_voxels
    coord_voxel = coord(i,1:3) - grid_map_start + 1 + neighbor_dist;
    idn = 1;
    x_lim = neighbor_dist;
    for x = -x_lim:x_lim
        y_lim = floor(sqrt(neighbor_dist^2-x^2));
        for y = -y_lim:y_lim
            z_lim = floor(sqrt(neighbor_dist^2-x^2-y^2));
            for z = -z_lim:z_lim
                if x==0 && y==0 && z==0, continue; end
                neighbor_map(i,idn) = grid_map(coord_voxel(1)+x, coord_voxel(2)+y, coord_voxel(3)+z);
                idn = idn+1;
            end
        end
    end
end
% add the virtual neighbors of the 0 node
neighbor_map = [zeros(1, num_neighbors); neighbor_map];
toc;




%% coarser map
fprintf('constructing the coarser map...\n');
% neighbor distance
neighbor_dist_low = 1; % distance of "neighbor nodes"
num_neighbors_low = 0;
for x = -neighbor_dist_low : neighbor_dist_low
    for y = -floor(sqrt(neighbor_dist_low^2-x^2)) : floor(sqrt(neighbor_dist_low^2-x^2))
        num_neighbors_low = num_neighbors_low + 2*floor(sqrt(neighbor_dist_low^2-x^2-y^2)) + 1;
    end
end
num_neighbors_low = num_neighbors_low - 1;

% distance map
dist_low = zeros(1, num_neighbors_low);
x_lim = neighbor_dist_low;
idn = 1;
for x = -x_lim:x_lim
    y_lim = floor(sqrt(neighbor_dist_low^2-x^2));
    for y = -y_lim:y_lim
        z_lim = floor(sqrt(neighbor_dist_low^2-x^2-y^2));
        for z = -z_lim:z_lim
            if x==0 && y==0 && z==0, continue; end
            dist_low(idn) = sqrt(x^2+y^2+z^2);
            idn = idn+1;
        end
    end
end


% high-low map: map the connectivity profile to low dimensional grid
coarse_set = load('/fs/nara-scratch/qwang37/brain_data/scripts/coarse_map_file', '-ascii'); % the set of all low dim coordinates
num_voxels_low = size(coarse_set,1);
grid_map_end_low = max(coarse_set(:,1:3), [], 1);


grid_map_low = zeros( grid_map_end_low + 1 + 2*neighbor_dist_low);
for i = 1:num_voxels_low
    coord_voxel = coarse_set(i,:)+1+neighbor_dist_low;
    grid_map_low(coord_voxel(1), coord_voxel(2), coord_voxel(3)) = coarse_set(i,4);
end

fprintf('num_voxels_low = %d;\n', num_voxels_low);
neighbor_map_low = zeros(num_voxels_low, num_neighbors_low);
for i = 1:num_voxels_low
    coord_voxel = coarse_set(i,:)+1+neighbor_dist_low;
    idn = 1;
    x_lim = neighbor_dist_low;
    for x = -x_lim:x_lim
        y_lim = floor(sqrt(neighbor_dist_low^2-x^2));
        for y = -y_lim:y_lim
            z_lim = floor(sqrt(neighbor_dist_low^2-x^2-y^2));
            for z = -z_lim:z_lim
                if x==0 && y==0 && z==0, continue; end
                neighbor_map_low(coarse_set(i,4),idn) = grid_map_low(coord_voxel(1)+x, coord_voxel(2)+y, coord_voxel(3)+z);
                idn = idn+1;
            end
        end
    end
end

neighbor_map_low = [zeros(1, num_neighbors_low); neighbor_map_low];
clear grid_map_low;


%% connectivity matrix
if ~exist([dirname, '/graph_', conn_file, '_dropthres', num2str(drop_thres), '.mat'], 'file')  
    %% prepare the connectivity profile
    fprintf('loading the pre-computed connectivity profile...\n');
    tic;
    conn_profile = load([dirname, '/', conn_file]);
    toc;
    conn_profile = conn_profile(:,4:end);
    fprintf('dimension of profile = %d\n', size(conn_profile,2));
    conn_profile = [zeros(1, num_voxels_low+1); zeros(num_voxels, 1), conn_profile];
    
    %% smoothing: smoothing need to use the new neighbor map which is of lower
    % dimension
    fprintf('gaussian smoothing...\n');
    tic;
    conn_profile_tmp = conn_profile;
    for n = 1:num_neighbors_low
        %     append_conn = uint8( exp(-dist_low(n) ^2 / 4) * conn_profile(:,neighbor_map_low(:,n)+1) );
        append_conn = single(exp(-dist_low(n) ^2)/(4/dim_low)^2) * conn_profile(:,neighbor_map_low(:,n)+1);
        conn_profile_tmp = conn_profile_tmp + append_conn;
    end
    conn_profile = conn_profile_tmp;
    clear conn_profile_tmp;
    conn_norm = sqrt(sum(conn_profile.^2, 2)) + single(0.01);
    toc;
    
    thres_conn = drop_thres;
    invalid_idx = find(conn_norm(2:end) < thres_conn); % voxels with not too little total connectivity
    valid_idx = find(conn_norm(2:end) >= thres_conn);
    conn_profile(invalid_idx+1,:) = 0;
    
    %% create the similarity graph
    fprintf('creating the similarity graph...\n');
    tic;
    G_sparse = zeros((num_voxels+1)*num_neighbors, 3);
    G_sparse(:,1) = repmat( (1:num_voxels+1).', num_neighbors, 1 );
    G_sparse(:,2) = reshape( neighbor_map+1, (num_voxels+1)*num_neighbors, 1 );
    
    for n= 1:num_neighbors
        %     G_sparse( (n-1)*(num_voxels+1)+1 : n*(num_voxels+1), 3 ) = sum(conn_profile.*conn_profile(neighbor_map(:,n)+1, :), 2);
        G_sparse( (n-1)*(num_voxels+1)+1 : n*(num_voxels+1), 3 ) = sum(conn_profile.*conn_profile(neighbor_map(:,n)+1, :), 2)...
            ./ conn_norm ./ conn_norm(neighbor_map(:,n)+1); % "cosine" distance
    end
    clear conn_profile;
    
    balance = 0;
    G_sparse(:,3) = G_sparse(:,3) - balance;
    % form the sparse matrix; get rid of the virtual first row and first column
    G = sparse(G_sparse(:,1), G_sparse(:,2), G_sparse(:,3), num_voxels+1, num_voxels+1);
    G(1,:) = [];
    G(:,1) = [];
    
    % for i = 1:num_voxels
    %     if mod(i, 10000)==0, fprintf('%d\n', i); end
    %     j = nonzeros(neighbor_map(i,:));
    %     G(i,j) = sim_conn_one2m(conn_profile(i,:), conn_profile(j,:));
    %     G(j,i) = G(i,j);
    % end
    
    toc;
    save([dirname, '/graph_', conn_file, '_dropthres', num2str(drop_thres), '.mat'], ...
        'G', 'valid_idx', 'invalid_idx');
else
    load([dirname, '/graph_', conn_file, '_dropthres', num2str(drop_thres), '.mat']);
end  % endif exist graph.mat

% G_support = G(G~=0);
% % G_support = G_support - mean(G_support);
% G_support = G_support - 0.5;
%
% G(G~=0) = G_support;
G = G(valid_idx, valid_idx);

%% spectral clustering
fprintf('computing required matrices...\n');
G = (G+G')/2;
Dvec = sum(G,2);
D = diag(Dvec);
L = D - G;
fprintf('computing Dinv...\n');
Dinv12 = sqrt(diag(sparse(1./Dvec)));
fprintf('computing normalized laplacian...\n');
L = Dinv12 * L * Dinv12;
L = (L+L') /2;

fprintf('computing the eigen vectors...\n');
tic;
[U,S] = eigs(L, num_clusters, 'sa');
toc;

fprintf('kmeans clustering...\n');
tic;
labels_new = kmeans(U(:,2:end), num_clusters, 'Distance', 'sqEuclidean', 'EmptyAction', 'singleton', 'Replicates', 10);
toc;

labels = zeros(num_voxels,1);
labels(valid_idx) = labels_new;

%% convert to index
% make nii file for view in fslview
fprintf('generating nii file...\n');
view_field = zeros(field_bound(1), field_bound(2), field_bound(3));
for i = 1:num_voxels
    view_field(coord(i,1)+1, coord(i,2)+1, coord(i,3)+1) = labels(i);
end
nii_struct = make_nii(view_field);
hdr = nii_ref.hdr;
hdr.dime.datatype = nii_struct.hdr.dime.datatype;
hdr.dime.bitpix = nii_struct.hdr.dime.bitpix;
hdr.dime.cal_max = nii_struct.hdr.dime.cal_max;
hdr.dime.cal_min = nii_struct.hdr.dime.cal_min;
hdr.dime.glmax = nii_struct.hdr.dime.glmax;
hdr.dime.glmin = nii_struct.hdr.dime.glmin;
nii_struct.hdr = hdr;
save_nii(nii_struct, [dirname,'/',result_name]);


