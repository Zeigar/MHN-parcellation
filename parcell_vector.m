function [parcell_vec_norm, parcell_vec, vol] = parcell_vector(filename, num_clusters, volname)
nii = load_untouch_nii(filename);
nii_img = nii.img(:);
parcell_vec = zeros(1,num_clusters);
for i = 1:num_clusters
    parcell_vec(i) = length(find(nii_img==i));
end
vol = load(volname);
vol = size(vol,1); % total volume of the brain
parcell_vec_norm = parcell_vec / vol; % normalized with respect to the whole brain volume

% vol = sum(parcell_vec);
% parcell_vec_norm = parcell_vec / vol;