%% separate subjects according to class labels
% clear;close all;
BASE_DIR = '/fs/nara-scratch/qwang37/brain_data'
num_clusters = 90;
[subjID,DX] = importSchizoFile([BASE_DIR, '/exp.csv']);
d_dir = dir(BASE_DIR);
mkdir([BASE_DIR, '/data_pos']);
mkdir([BASE_DIR, '/data_neg']);
mkdir([BASE_DIR, '/data_others']);

for i = 1:length(d_dir)
    dirname = d_dir(i).name;
    if ~isempty(regexp(dirname, 'd[0-9][0-9]', 'once'))
        s_dir = dir([BASE_DIR, '/', dirname, '/processed']);
        for j = 1:length(s_dir)
            subname = s_dir(j).name;
            if ~isempty(regexp(subname, 'S[0-9][0-9][0-9][0-9]', 'once'))
                fprintf('processing %s\n', [BASE_DIR, '/', dirname, '/processed/', subname]);
                [flag, loc] = ismember(subname, subjID);
                if flag
                    label = DX(loc);
                    if label==1
                        movefile([BASE_DIR, '/', dirname, '/processed/', subname], [BASE_DIR, '/data_pos/']);
                    elseif label==0
                        movefile([BASE_DIR, '/', dirname, '/processed/', subname], [BASE_DIR, '/data_neg/']);
                    end
                else
                    movefile([BASE_DIR, '/', dirname, '/processed/', subname], [BASE_DIR, '/data_others/']);
                end
            end
        end
    end
end




    