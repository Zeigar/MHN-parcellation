%% network analysis of the entire data
clear;close all;
avg_path_len = [];
cluster_coef = []; 
small_world = [];
digree_dist = {};
local_eff = {};
global_eff = [];
betweenness = {};

label_all = [];

[subjID,DX] = importSchizoFile('exp.csv');
d_dir = dir;
id = 1;
for i = 1:length(d_dir)
    dirname = d_dir(i).name;
    if dirname(1) == 'd'
        s_dir = dir(dirname);
        for j = 1:length(s_dir)
            subname = s_dir(j).name;
            [flag, loc] = ismember(subname, subjID);
            if flag
                id = id+1;
                filename = [dirname, '/', subname, '/graph_aal_90.mat'];
                fprintf('processing %s...\n', filename);
                [avg_path_len1, cluster_coef1, small_world1, digree_dist1, local_eff1, global_eff1, betweenness1] = net_analyze(filename);          
                avg_path_len = [avg_path_len; avg_path_len1];
                cluster_coef = [cluster_coef; cluster_coef1];
                small_world = [small_world; small_world1];
                digree_dist = [digree_dist; {digree_dist1}];
                local_eff = [local_eff; {local_eff1}];
                global_eff = [global_eff; global_eff1];
                betweenness = [betweenness; {betweenness1}];
                label_all = [label_all; DX(loc)];
                %                 save([dirname, '/', subname, '/parcel_vec.txt'], 'parcell_vec', '-ascii', '-tabs');
            end
        end
    end
end

pos = (label_all==1);
neg = (label_all==0);

mp_avg_path_len = mean(avg_path_len(pos,:));
mn_avg_path_len = mean(avg_path_len(neg,:));
mp_cluster_coef = mean(cluster_coef(pos,:));
mn_cluster_coef = mean(cluster_coef(neg,:));
mp_small_world = mean(small_world(pos,:));
mn_small_world = mean(small_world(neg,:));
mp_global_eff = mean(global_eff(pos,:));
mn_global_eff = mean(global_eff(neg,:));

stdp_avg_path_len = std(avg_path_len(pos,:));
stdn_avg_path_len = std(avg_path_len(neg,:));
stdp_cluster_coef = std(cluster_coef(pos,:));
stdn_cluster_coef = std(cluster_coef(neg,:));
stdp_small_world = std(small_world(pos,:));
stdn_small_world = std(small_world(neg,:));
stdp_global_eff = std(global_eff(pos,:));
stdn_global_eff = std(global_eff(neg,:));

save net_analyze_results;


load net_analyze_results;

figure; barwitherr([stdp_avg_path_len,stdn_avg_path_len], [mp_avg_path_len,mn_avg_path_len]);
figure; barwitherr([stdp_cluster_coef,stdn_cluster_coef],[mp_cluster_coef,mn_cluster_coef]);
figure; barwitherr([stdp_small_world,stdn_small_world],[mp_small_world,mn_small_world]);
figure; barwitherr([stdp_global_eff,stdn_global_eff],[mp_global_eff,mn_global_eff]);


    