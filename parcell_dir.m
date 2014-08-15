function parcell_dir(dirname, black_hole, coarse_size, result_name, num_clusters, conn_file, drop_thres)
%% main function of dataset parcellation
% parcell_dir(dirname, black_hole, coarse_size, result_name, num_clusters, conn_file, drop_thres)
root = dirname;
s_dir = dir(root);
for j = 1:length(s_dir)
    sub_name = s_dir(j).name;
    if ~isempty(regexp(sub_name, '^S[0-9][0-9][0-9][0-9]$', 'once'))
%       parcell_aal([root,'/',sub_name],black_hole,coarse_size,result_name);
%         parcell_aal_sa([root,'/',sub_name],black_hole,coarse_size,result_name); 
%         parcell_aal_kmeans([root,'/',sub_name], num_clusters, coarse_size, result_name);
%         parcell_aal_sa_patched([root,'/',sub_name],black_hole,coarse_size,result_name); 
%         parcell_aal_spec_patched_with_profile_file([root,'/',sub_name], coarse_size, num_clusters, result_name, conn_file, drop_thres)
        parcell_aal_spec_sa_patched([root, '/', sub_name], black_hole, coarse_size, num_clusters, result_name)
    end
end

