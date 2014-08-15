function combine_profile_files(dirname, profile_file, save_file)
%% combine multiple profile files
% function combine_profile_files(dirname, profile_file, save_file)
fst = true; % whether it is the first profile to combine
total = [];
t1 = [];
d1s = dir(dirname);
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
                if fst
                    total = t1(:, 4:end);
                    fst = false;
                else
                    total = total + t1(:, 4:end);
                end
                toc;
            end
        end
    end
end

dlmwrite([dirname, '/', save_file], total, 'delimiter', ' ');

                