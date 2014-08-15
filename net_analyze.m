%% network analysis
function [avg_path_len, cluster_coef, small_world, digree_dist, ...
    local_eff, global_eff, betweenness] = ...
    net_analyze(graph_name)
% addpath('matlab_network');
addpath('BCT');
load(graph_name); % connectivity matrix
W = graph;
D = size(W,1);
W(1:D+1:end) = 0; % eliminate self connectivity
L = weight_conversion(W, 'lengths');
%% average path length
path_len = distance_wei(L);
avg_path_len = sum(path_len(:))/(D^2-D);
cluster_coef = clustering_coef_wu(W);
cluster_coef = mean(cluster_coef);
small_world = cluster_coef / avg_path_len;
digree_dist = degrees_und(W);
digree_dist = sort(digree_dist, 'descend');
local_eff = efficiency_wei(W, 1);
local_eff = sort(local_eff, 'descend');
global_eff = efficiency_wei(W, 0);
betweenness = betweenness_wei(L);
betweenness = sort(betweenness, 'descend');
