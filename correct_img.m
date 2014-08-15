%% correct the flipping problem of the originally generated atlases
function correct_img(img_name,out_name)
d_dir = dir;
for i = 1:length(d_dir)
    dirname = d_dir(i).name;
    if dirname(1) == 'd'
        s_dir = dir(dirname);
        for j = 1:length(s_dir)
            subname = s_dir(j).name;
            if subname(1) == 'S'
                fprintf('processing %s...\n', [dirname,'/',subname,'/',img_name]);
                nii_img = load_untouch_nii([dirname,'/',subname,'/',img_name]);
                nii_ref = load_untouch_nii([dirname,'/',subname,'/dti.bedpostX/nodif_brain.nii.gz']);
                nii_struct = make_nii(nii_img.img);
                hdr = nii_ref.hdr;
                hdr.dime.datatype = nii_struct.hdr.dime.datatype;
                hdr.dime.bitpix = nii_struct.hdr.dime.bitpix;
                hdr.dime.cal_max = nii_struct.hdr.dime.cal_max;
                hdr.dime.cal_min = nii_struct.hdr.dime.cal_min;
                hdr.dime.glmax = nii_struct.hdr.dime.glmax;
                hdr.dime.glmin = nii_struct.hdr.dime.glmin;
                
                if ~all(hdr.dime.dim(2:4) == nii_struct.hdr.dime.dim(2:4))
                    fprintf('warning: data dimension mismatche for %s: [%d,%d,%d] vs [%d,%d,%d]\n', ...
                        [dirname,'/',subname,'/',img_name], hdr.dime.dim(2),hdr.dime.dim(3),hdr.dime.dim(4),...
                        nii_struct.hdr.dime.dim(2),nii_struct.hdr.dime.dim(3),nii_struct.hdr.dime.dim(4));
                    expanded_img = zeros(hdr.dime.dim(2:4));
                    expanded_img(1:nii_struct.hdr.dime.dim(2), 1:nii_struct.hdr.dime.dim(3), 1:nii_struct.hdr.dime.dim(4)) = nii_struct.img;
                    nii_struct.img = expanded_img;
                end
                
                nii_struct.hdr = hdr;
                save_nii(nii_struct, [dirname,'/',subname,'/',out_name]);
            end
        end
    end
end

