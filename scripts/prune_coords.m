%% preprocess that coordinate files
cd ..;
d1 = dir;
for i=1:length(d1)
    d1n = d1(i).name;
    if isdir(d1n) && d1n(1) == 'd'
        d2 = dir(d1n);
        for j=1:length(d2)
            d2n = d2(j).name;
            if isdir([d1n,'/',d2n]) && d2n(1) == 'S'
                fprintf('processing %s\n', [d1n,'/',d2n]);
                coords = load([d1n,'/',d2n,'/track_aal_90_0/coords_for_fdt_matrix3'], '-ascii');
                coords = coords(:,1:3);
                dlmwrite([d1n,'/',d2n,'/track_aal_90_0/coords_pruned'], coords, ' ')
            end
        end
    end
end
