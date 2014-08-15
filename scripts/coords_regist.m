%% coordinate transform script
BASE_DIR='/fs/nara-scratch/qwang37/brain_data';
ref = '/fs/nara-scratch/qwang37/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz';
d1s = dir(BASE_DIR);
for i=1:length(d1s)
    d1n = d1s(i).name;
    if isdir([BASE_DIR,'/',d1n]) && d1n(1)=='d'
        d2s = dir([BASE_DIR,'/',d1n]);       
        for j=1:length(d2s)
            d2n = d2s(j).name;
            if isdir([BASE_DIR, '/', d1n, '/', d2n]) && d2n(1) == 'S'
                fprintf('processing %s\n', [d1n,'/',d2n]);
                src = [BASE_DIR, '/', d1n, '/', d2n, '/track_aal_90_0/coords_pruned'];
                trans = [BASE_DIR, '/', d1n, '/', d2n, '/dti.bedpostX/xfms/field_standard2diff.nii.gz'];
                dest = [BASE_DIR, '/', d1n, '/', d2n, '/track_aal_90_0/coords_standard'];
                coord_transform(src, trans, dest, ref);
            end
        end
        d2s = dir([BASE_DIR,'/',d1n,'/processed']);
        for j=1:length(d2s)
            d2n = d2s(j).name;
            if d2n(1) == 'S'
                fprintf('processing %s\n', [d1n,'/processed/',d2n]);
                src = [BASE_DIR, '/', d1n, '/processed/', d2n, '/track_aal_90_0/coords_pruned'];
                trans = [BASE_DIR, '/', d1n, '/processed/', d2n, '/dti.bedpostX/xfms/field_standard2diff.nii.gz'];
                dest = [BASE_DIR, '/', d1n, '/processed/', d2n, '/track_aal_90_0/coords_standard'];
                coord_transform(src, trans, dest, ref);
            end
        end        
    end
end
