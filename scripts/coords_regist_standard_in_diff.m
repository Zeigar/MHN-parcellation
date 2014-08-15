%% coordinate transform script
BASE_DIR='/fs/nara-scratch/qwang37/brain_data';
trans_mat = 'field_diff2standard.nii.gz';
d1s = dir(BASE_DIR);

%src_nii = load_untouch_nii('/fs/nara-scratch/qwang37/fsl/data/standard/MNI152_T1_2mm_brain_mask.nii.gz');
%ind = find(src_nii.img>0);


for i=1:length(d1s)
    d1n = d1s(i).name;
    if isdir([BASE_DIR,'/',d1n]) && ~isempty(regexpi(d1n, '^data_','once'))
        d2s = dir([BASE_DIR,'/',d1n]);       
        for j=1:length(d2s)
            d2n = d2s(j).name;
            if isdir([BASE_DIR, '/', d1n, '/', d2n]) && ~isempty(regexpi(d2n, '^S[0-9][0-9][0-9][0-9]', 'once'))
                fprintf('processing %s\n', [d1n,'/',d2n]);
                src = [BASE_DIR, '/scripts/keyfile'];
                trans = [BASE_DIR, '/', d1n, '/', d2n, '/dti.bedpostX/xfms/', trans_mat];
                dest = [BASE_DIR, '/', d1n, '/', d2n, '/track_aal_90_0/coords_standard_in_diff'];
                ref = [BASE_DIR, '/', d1n, '/', d2n, '/dti.bedpostX/nodif_brain.nii.gz'];
                coord_transform(src, trans, dest, ref);
            end
        end        
    end
end
