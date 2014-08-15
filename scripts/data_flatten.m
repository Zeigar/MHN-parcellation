function data_flatten(BASE_DIR)
% data_flatten(BASE_DIR)
d1s = dir(BASE_DIR);
for i=1:length(d1s)
    d1n = d1s(i).name;
    if ~isempty(regexp(d1n, '^d[0-9][0-9]$', 'once'));
        d2s = dir([BASE_DIR, '/', d1n]);
        for j=1:length(d2s)
            d2n = d2s(j).name;
            if ~isempty(regexp(d2n, '^S[0-9][0-9][0-9][0-9]$', 'once'))
                movefile([BASE_DIR, '/', d1n, '/', d2n], [BASE_DIR, '/', d2n]);
            end
        end
        rmdir([BASE_DIR, '/', d1n]);
    end
end

            