function data_partition(BASE_DIR, num_partitions)
%% data partition
% partition the whole data set into several blocks for parallel processing
% data_partition(BASE_DIR, num_partitions)
ds = dir(BASE_DIR);
% filter
i=1;
while i<=length(ds)
    if isempty(regexp(ds(i).name, '^S[0-9][0-9][0-9][0-9]$', 'once'))
        ds(i) = [];
        continue;
    end
    i=i+1;
end

num_per_part = floor(length(ds)/num_partitions);

for i=1:num_partitions
    mother_dir = ['d', num2str(i, '%02d')];
    mkdir([BASE_DIR, '/', mother_dir]);
end

part = 0;
for i=1:length(ds)
    part = mod(part, num_partitions)+1;
    mother_dir = ['d', num2str(part, '%02d')];
    movefile([BASE_DIR, '/', ds(i).name], [BASE_DIR, '/', mother_dir, '/', ds(i).name]);
end

    
    
    
