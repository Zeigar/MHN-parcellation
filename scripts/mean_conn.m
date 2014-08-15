%% collect average connectivity from all input files
BASE_DIR='/fs/nara-scratch/qwang37/brain_data';
[subjID,DX] = importSchizoFile([BASE_DIR, '/exp.csv']);
d1s = dir(BASE_DIR);
for i=1:length(d1s)
    d1n = d1s(i).name;
    if isdir([BASE_DIR, '/', d1n]) && d1n(1)=='d'
        d2s = dir([BASE_DIR,'/',d1n]);
        for j = 1:length(d2s)
            d2n = d2s(j).name;
            [flag, loc] = ismember(d2n, subjID);
            if flag && DX(loc)==0 % negative instance
                coord_mat = load([BASE_DIR,'/',d1n,'/',d2n,'/track_aal_90_0/coords_standard'], '-ascii');
                