%% network analysis
function indices = ...
    net_analyze_v1(graph_name, index_names)
% addpath('matlab_network');
addpath('BCT');
load(graph_name); % connectivity matrix
W = graph;
D = size(W,1);
W(1:D+1:end) = 0; % eliminate self connectivity
L = weight_conversion(W, 'lengths');

indices = containers.Map;
if any(strcmp('avg_path_len', index_names)) || any(strcmp('small_world', index_names))
    fprintf('average path length...\n');
    tic;
    path_len = distance_wei(L);
    ind = find(path_len(:)~=0 & path_len(:)~=Inf);
    indices('avg_path_len') = mean(path_len(ind));
    toc;
end

if any(strcmp('cluster_coef', index_names)) || any(strcmp('small_world', index_names))
    fprintf('clustering coefficient...\n');
    tic;
    cluster_coef = clustering_coef_wu(W);
    ind = find(cluster_coef ~=Inf);
    indices('cluster_coef') = mean(cluster_coef(ind));
    toc;
end

if any(strcmp('small_world', index_names))
    fprintf('small_worldness...\n');
    tic;
    indices('small_world') = indices('cluster_coef') / indices('avg_path_len');
    toc;
end

if any(strcmp('degree_dist', index_names))
    fprintf('degree distribution...\n');
    tic;
    digree_dist = degrees_und(W);
    indices('degree_dist') = {sort(digree_dist, 'descend')};
    toc;
end

if any(strcmp('local_eff', index_names))
    fprintf('local efficiency...\n');
    tic;
    local_eff = efficiency_wei(W, 1);
    indices('local_eff') = {sort(local_eff, 'descend')};
    toc;
end

if any(strcmp('global_eff', index_names))
    fprintf('global efficiency...\n');
    tic;
    indices('global_eff') = efficiency_wei(W, 0);
    toc;
end


if any(strcmp('betweenness', index_names))
    fprintf('betweenness...\n');
    tic;
    betweenness = betweenness_wei(L);
    indices('betweenness') = {sort(betweenness, 'descend')};
    toc;
end

if any(strcmp('sparsity', index_names))
    fprintf('sparsity...\n');
    tic;
    indices('sparsity') = size(W,1) / sum(W(:));
    toc;
end

    
    
    
