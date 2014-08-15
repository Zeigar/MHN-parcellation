%% label-to-binary-all
clear;close all;
num_clusters = 90;
d_dir = dir;

for i = 1:length(d_dir)
    dirname = d_dir(i).name;
    if dirname(1) == 'd'
        s_dir = dir(dirname);
        for j = 1:length(s_dir)            
            subname = s_dir(j).name;
            if subname(1) == 'S'
                fprintf('processing %s...\n', [dirname, '/', subname]);
                img = [dirname, '/', subname, '/', 'parcel_result_aal_90_black0.5_low4_patched.nii.gz']; % the labeled atlas
                out_dir = [dirname, '/', subname, '/atlas_local'];
                label_to_binary(img, out_dir, num_clusters);
            end
        end
    end
end


