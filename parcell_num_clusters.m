function parcell_num_clusters(dirname, black_hole, coarse_size, result_name, num_clusters, conn_file, drop_thres)
%% main function of dataset parcellation
% parcell_num_clusters(dirname, black_hole, coarse_size, result_name, num_clusters, conn_file, drop_thres)

for i = 1:length(num_clusters);
%       parcell_aal([root,'/',sub_name],black_hole,coarse_size,result_name);
%         parcell_aal_sa([root,'/',sub_name],black_hole,coarse_size,result_name); 
%         parcell_aal_kmeans([root,'/',sub_name], num_clusters, coarse_size, result_name);
%         parcell_aal_sa_patched([root,'/',sub_name],black_hole,coarse_size,result_name);
    fprintf('num_clusters = %d:\n', num_clusters(i));
    tic;
    parcell_aal_spec_patched_with_profile_file(dirname, coarse_size, num_clusters(i), ...
            [result_name, '_cluster', num2str(num_clusters(i)), '.nii.gz'], conn_file, drop_thres);
    toc;

%         parcell_aal_spec_sa_patched([root, '/', sub_name], black_hole, coarse_size, num_clusters, result_name)
end

