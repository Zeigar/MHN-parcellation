function parcell_aal_sa_patched(dirname, black_hole, dim_low, num_clusters, result_name)
%% hopfield network with aal initialization, using (softmax) simulated annealing
%% load reference header structure
% nii_standard = load_untouch_nii('/usr/share/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz');
nii_ref = load_untouch_nii([dirname, '/dti.bedpostX/nodif_brain.nii.gz']);
% nii_ref = load_untouch_nii([dirname, '/atlas_aal_90/aal_90_2mm_1.nii.gz']);

fprintf('processing %s...\n', dirname);
coord = load([dirname,'/track_aal_90_0/coords_for_fdt_matrix3']);
coord = single(coord(:,1:3));
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
% dim_low = 3;
grid_low = false( floor((grid_map_end(1)-grid_map_start(1))/dim_low ) + 1 + 2*neighbor_dist_low, ...
    floor((grid_map_end(2)-grid_map_start(2))/dim_low ) + 1 + 2*neighbor_dist_low, ...
    floor((grid_map_end(3)-grid_map_start(3))/dim_low ) + 1 + 2*neighbor_dist_low);
x = floor( (coord(:,1) - grid_map_start(1)) / dim_low ) + 1 + neighbor_dist_low;
y = floor( (coord(:,2) - grid_map_start(2)) / dim_low ) + 1 + neighbor_dist_low;
z = floor( (coord(:,3) - grid_map_start(3)) / dim_low ) + 1 + neighbor_dist_low;
for i = 1:num_voxels
    grid_low(x(i),y(i),z(i)) = true;
end

ind = find(grid_low);
x_low = mod(ind-1, size(grid_low,1)) + 1;
y_low = mod((ind-x_low)/size(grid_low,1), size(grid_low,2)) + 1;
z_low = ((ind-x_low)/size(grid_low,1)-y_low+1)/size(grid_low,2) + 1;

num_voxels_low = length(x_low);
grid_map_low = zeros(size(grid_low));
grid_map_low(grid_low) = 1:num_voxels_low;

high_low_map = zeros(num_voxels,1);
for i = 1:num_voxels
    high_low_map(i) = grid_map_low(x(i), y(i), z(i));
end
coord_map_low = [x_low, y_low, z_low];



neighbor_map_low = zeros(num_voxels_low, num_neighbors_low);
for i = 1:num_voxels_low
    coord_voxel = coord_map_low(i,:);
    idn = 1;
    x_lim = neighbor_dist_low;
    for x = -x_lim:x_lim
        y_lim = floor(sqrt(neighbor_dist_low^2-x^2));
        for y = -y_lim:y_lim
            z_lim = floor(sqrt(neighbor_dist_low^2-x^2-y^2));
            for z = -z_lim:z_lim
                if x==0 && y==0 && z==0, continue; end
                neighbor_map_low(i,idn) = grid_map_low(coord_voxel(1)+x, coord_voxel(2)+y, coord_voxel(3)+z);
                idn = idn+1;
            end
        end
    end
end

neighbor_map_low = [zeros(1, num_neighbors_low); neighbor_map_low];

if ~exist([dirname, '/conn_profile_patched_dimlow',num2str(dim_low), '.mat'], 'file')
    % load data
    conn_profile = single(zeros(num_voxels, num_voxels_low));
    
    for d = 0:0
        fprintf('reading data %d...\n', d);
        tic;
        A = load([dirname,'/track_aal_90_',num2str(d),'/fdt_matrix3.dot']); A = single(A);
        toc;
        %% decide the boundary indices in the connectivity data
        fprintf('updating the connectivity profiles...\n');
        tic;
        for i = 1:size(A,1)
            term1 = high_low_map(A(i,1)); term2 = high_low_map(A(i,2));
            conn_profile(A(i,1),term2) = conn_profile(A(i,1),term2) + A(i,3);
            conn_profile(A(i,2),term1) = conn_profile(A(i,2),term1) + A(i,3);
        end
        toc;
        clear A;
    end
    
    % add the virtual conn_profile of the 0 node
    conn_profile = [zeros(1, num_voxels_low+1); zeros(num_voxels, 1), conn_profile];
    save([dirname, '/conn_profile_raw_patched_dimlow', num2str(dim_low), '.mat'], 'conn_profile');
    
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
    save([dirname, '/conn_profile_patched_dimlow', num2str(dim_low), '.mat'], 'conn_profile', 'conn_norm');
else
    load([dirname, '/conn_profile_patched_dimlow', num2str(dim_low), '.mat']);
end  % endif exist conn_profile

if ~exist([dirname, '/graph_patched_dimlow',num2str(dim_low), '.mat'], 'file')
    thres_conn = 10;
    invalid_idx = find(conn_norm < thres_conn); % voxels with not too little total connectivity
    conn_profile(invalid_idx,:) = 0;
    
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
    save([dirname, '/graph_patched_dimlow', num2str(dim_low), '.mat'], 'G');
else
    load([dirname, '/graph_patched_dimlow', num2str(dim_low), '.mat']);
end  % endif exist graph.mat

% G_support = G(G~=0);
% % G_support = G_support - mean(G_support);
% G_support = G_support - 0.5;
%
% G(G~=0) = G_support;

%% grow initial parcellation with the aal atlas
fprintf('growing initial parcellation...\n');
tic;
thres = 0.2; % threshold for valid initial parcellation
mask = [];
for i = 1:num_clusters
    nii_struct = load_untouch_nii([dirname, '/atlas_aal_90/aal_90_2mm_', num2str(i), '.nii.gz']);
    nii_img = nii_struct.img(:);
    mask = [mask, nii_img(coord_voxel_1d)];
end

labels = zeros(num_voxels, num_clusters);
for i = 1:num_voxels
    [mv, mi] = max(mask(i,:), [], 2);
    if mv > thres
        labels(i,mi) = 1;
    end
end
% nii_struct = load_untouch_nii([dirname, '/parcel_result_kmeans.nii.gz']);
% nii_img = nii_struct.img(:);
% mask = nii_img(coord_voxel_1d);
% for i =1:num_voxels
%     if mask(i) > 0
%         labels(i,mask(i)) = 1;
%     end
% end
% toc;

%% hopfield network dynamics
%% phase 1: "free phase"
fprintf('doing hopfield network iterations: phase 1...\n');
% num_iter = 200;
labels_new = labels*(1-black_hole) + black_hole;
% T = 20; % temperature
% for iter = 1:num_iter
%     fprintf('iter %d\n', iter);
%     T = T/2;
%     labels_new = G * labels_new;
%     mv = max(labels_new,[],2);
%     labels_new = labels_new - repmat(mv, 1, num_clusters);
%     labels_new = exp(labels_new/T);
%     labels_new = labels_new ./ repmat(sum(labels_new, 2), 1, num_clusters);
%     labels_new = mnrnd(1,labels_new);
%     labels_new(labels_new~=1) = black_hole;
% end

% smoothing stage
fprintf('doing hopfield network iterations: phase 2...\n');
for iter = 1:100
    fprintf('iter %d\n', iter);
    labels_new = G * labels_new;
    [mv, ind] = max(labels_new,[],2);
    kept_ind = find(mv > 0);
    ind = (ind(kept_ind)-1)*num_voxels + kept_ind;
    labels_new = black_hole*ones(size(labels_new));
    labels_new(ind) = 1; % constructed new labeling
end
% convert to index
labels_new = vec2ind(labels_new);

%% make nii file for view in fslview
fprintf('generating nii file...\n');
view_field = zeros(field_bound(1), field_bound(2), field_bound(3));
for i = 1:num_voxels
    view_field(coord(i,1)+1, coord(i,2)+1, coord(i,3)+1) = labels_new(i);
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


%% convert original to index
[y, x] = find(labels.' == 1);
labels = zeros(num_voxels, 1);
labels(x) = y;
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
save_nii(nii_struct, [dirname, '/parcel_result_start_aal_90_single.nii.gz']);

