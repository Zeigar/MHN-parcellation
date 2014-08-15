%% combine profiles
BASE_DIR = 'data_neg';
d1s = dir(BASE_DIR);
first = true;
for i = 1:length(d1s)
    d1n = d1s(i).name;
    if ~isempty(regexpi(d1n, 'S[0-9][0-9][0-9][0-9]', 'once'))
        fprintf('processing %s\n', [BASE_DIR, '/', d1n]);
        tic;
        if first
            conn_profile = load([BASE_DIR, '/', d1n, '/partial_profile'], '-ascii');
        else
            append = load([BASE_DIR, '/', d1n, '/partial_profile'], '-ascii');
            conn_profile = conn_profile + append;
        end
        toc;
    end
end

fprintf('writing\n');
dlmwrite([BASE_DIR, '/combined_profile'], conn_profile, ' ');


    
            