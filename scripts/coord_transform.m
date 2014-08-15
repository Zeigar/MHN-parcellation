function coord_transform(src, trans, dest, ref)
%% coordinate mapping: diff->standard, according to field_standard2diff.nii.gz
% function coord_transform(src, trans, dest, ref)

if size(src,1) == 1 % check whether input is string
    coords_vox_src = load(src, '-ascii');
else
    coords_vox_src = src; % a matrix
end

nii_trans = load_untouch_nii(trans);
nii_ref = load_untouch_nii(ref);
dim_trans = nii_trans.hdr.dime.pixdim(2:4);
dim_ref = nii_ref.hdr.dime.pixdim(2:4);
img_trans = nii_trans.img;
size_trans = size(img_trans);

% transform to mm units
coords_mm_src(:,1) = coords_vox_src(:,1)*dim_trans(1);
coords_mm_src(:,2) = coords_vox_src(:,2)*dim_trans(2);
coords_mm_src(:,3) = coords_vox_src(:,3)*dim_trans(3);

coords_vox_1d = 1 + coords_vox_src(:,1) + size_trans(1)*(coords_vox_src(:,2) + size_trans(2)*coords_vox_src(:,3));

% apply warp transformation
vol = size_trans(1)*size_trans(2)*size_trans(3);
coords_mm_dest = coords_mm_src + [img_trans(coords_vox_1d), img_trans(vol+coords_vox_1d), img_trans(2*vol+coords_vox_1d)];

% convert back to voxel domain
coords_vox_dest = [coords_mm_dest(:,1)/dim_ref(1), coords_mm_dest(:,2)/dim_ref(2), coords_mm_dest(:,3)/dim_ref(3)];
dlmwrite(dest, coords_vox_dest, ' ');
% coords_vox_dest

