function combine_profile_files_S(dirname, profile_file, save_file)
%% combine multiple profile files
% function combine_profile_files_S(dirname, profile_file, save_file)
fst = true; % whether it is the first profile to combine
total = [];
t1 = [];

d2s = dir(dirname);
for j = 1:length(d2s)
    d2n = d2s(j).name;
    if ~isempty(regexp(d2n, '^S[0-9][0-9][0-9][0-9]$', 'once'))
        fprintf('Processing %s\n', [dirname, '/', d2n]);
        tic;
        t1 = load([dirname, '/', d2n, '/', profile_file]);
        if fst
            total = t1;
            fst = false;
        else
            total(:,4:end) = total(:,4:end) + t1(:, 4:end);
        end
        toc;
    end
end


dlmwrite([dirname, '/', save_file], total, 'delimiter', ' ');

