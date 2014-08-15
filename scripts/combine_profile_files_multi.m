function combine_profile_files_multi(dirname, profile_file, save_file, num_profiles, partition_file)
%% combine multiple profile files - multiple sampled combined profiles
% function combine_profile_files_multi(dirname, profile_file, save_file, num_profiles, partition_file)
fst = true(num_profiles,1); % whether it is the first profile to combine
total = cell(num_profiles, 1);
t1 = [];
d1s = dir(dirname);
fid = fopen([dirname, '/', partition_file], 'w');
for i = 1:length(d1s)
    d1n = d1s(i).name;
    if ~isempty(regexp(d1n, '^d[0-9][0-9]$', 'once'))
        d2s = dir([dirname, '/', d1n]);
        for j = 1:length(d2s)
            d2n = d2s(j).name;
            if ~isempty(regexp(d2n, '^S[0-9][0-9][0-9][0-9]$', 'once'))
                fprintf('Processing %s\n', [dirname, '/', d1n, '/' d2n]);
                tic;
                t1 = load([dirname, '/', d1n ,'/', d2n, '/', profile_file]);
                
                ind = randi(num_profiles);
                fprintf(fid, '%s %d\n', d2n, ind);

                if fst(ind)
                    total{ind} = t1;
                    fst(ind) = false;
                else
                    total{ind}(:,4:end) = total{ind}(:,4:end) + t1(:, 4:end);
                end
                toc;
            end
        end
    end
end

fclose(fid);

for i = 1:num_profiles
    fprintf('writing part %d\n', i);
    tic;
    dlmwrite([dirname, '/', save_file, '_part', num2str(i)], total{i}, 'delimiter', ' ');
    toc;
end


                