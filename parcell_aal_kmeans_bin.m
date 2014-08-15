function parcell_aal_kmeans_bin(dirname, dim_low,result_name)
%% kmeans clustering, with binary connectivity profile
fprintf('processing %s...\n', dirname);
coord = load([dirname,'/track_aal_90_0/coords_for_fdt_matrix3']);
coord = single(coord(:,1:3));
% parameters
num_clusters = 6;
num_voxels = size(coord,1);
% field_bound = [128,104,64];
field_bound = [128,128,53];

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
    
    
    
if ~exist([dirname, '/conn_profile_dimlow',num2str(dim_low), '_bin.mat'], 'file')    
    %% similar for the coarser map
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
    
    % load data
    conn_profile = single(zeros(num_voxels, num_voxels_low));
    
    for d = 0:3
        fprintf('reading data %d...\n', d);
        tic;
        A = load([dirname,'/track_aal_90_',num2str(d),'/fdt_matrix3.dot']); A = single(A);
        toc;
        %% decide the boundary indices in the connectivity data
        fprintf('deciding the boundary points of the connectivity data %d...\n', d);
        tic;
        start_point = zeros(num_voxels,1);
        start_point(1) = 1;
        vox_ind = 1;
        for i = 1:size(A,1)
            while A(i,2) ~= vox_ind
                vox_ind = vox_ind+1;
                start_point(vox_ind) = i;
            end
        end
        start_point = [start_point; size(A,1)+1];
        toc;
        
        %% update the connectivity profile for each voxel
        fprintf('generating the connectivity profiles...\n');
        tic;
        for i = 1:num_voxels
            if mod(i,10000) == 0, fprintf('%d\n', i); end
            chunk = A(start_point(i):start_point(i+1)-1, :);
            chunk(:,1) = high_low_map(chunk(:,1));
            v = zeros(1,num_voxels_low);
            for l = 1:size(chunk,1)
                v(chunk(l,1)) = v(chunk(l,1)) + chunk(l,3);
            end
            conn_profile(i,:) = conn_profile(i,:) + v;
        end
        toc;
        clear A;
    end
    % add the virtual conn_profile of the 0 node
    conn_profile = [zeros(1, num_voxels_low+1); zeros(num_voxels, 1), conn_profile];
    %% binarize
    fprintf('binarizing...\n');
    thres_bin = 0;
    num_keep = round(size(conn_profile,2)/10); % keep the first 10%
    [sv, ind] = sort(conn_profile, 2, 'descend');
    ind = ind(:,1:num_keep);
    ind = (ind-1)*size(conn_profile,1) + repmat((1:num_voxels+1)',1,num_keep);
    conn_profile_tmp = zeros(size(conn_profile));
    conn_profile_tmp(ind(:)) = 1;
    conn_profile_tmp = conn_profile_tmp .* (conn_profile>thres_bin);
    conn_profile = single(conn_profile_tmp);
    clear conn_profile_tmp;
    save([dirname, '/conn_profile_dimlow', num2str(dim_low), '_bin.mat'], 'conn_profile');
else
    load([dirname, '/conn_profile_dimlow', num2str(dim_low), '_bin.mat']);
end  % endif exist conn_profile


%% kmeans clustering
fprintf('doing kmeans clustering...\n');
tic;
% labels_new = zeros(num_voxels,1);
labels_new = kmeans(conn_profile, num_clusters, 'Distance', 'hamming', 'replicate', 5);
toc;

%% load reference header structure
% nii_standard = load_untouch_nii('/usr/share/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-2mm.nii.gz');
nii_ref = load_untouch_nii([dirname, '/dti.bedpostX/nodif_brain.nii.gz']);

%% make nii file for view in fslview
fprintf('generating nii file...\n');
view_field = zeros(field_bound(1), field_bound(2), field_bound(3));
for i = 1:num_voxels
    view_field(coord(i,1)+1, coord(i,2)+1, coord(i,3)+1) = labels_new(i);
end
view_field_nii = make_nii(view_field);
view_field_nii.hdr.dime.pixdim = nii_ref.hdr.dime.pixdim;
save_nii(view_field_nii, [dirname,'/',result_name]);


% %% convert original to index
% [y, x] = find(labels.' == 1);
% labels = zeros(num_voxels, 1);
% labels(x) = y;
% fprintf('generating nii file...\n');
% view_field = zeros(field_bound(1), field_bound(2), field_bound(3));
% for i = 1:num_voxels
%     view_field(coord(i,1)+1, coord(i,2)+1, coord(i,3)+1) = labels(i);
% end
% view_field_nii = make_nii(view_field);
% view_field_nii.hdr.dime.pixdim = nii_ref.hdr.dime.pixdim;
% save_nii(view_field_nii, [dirname, '/parcel_result_start_aal_90_single.nii.gz']);

