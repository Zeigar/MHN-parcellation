function graph_gen_dir(dir_name, parcel_name, graph_name)
root = dir_name;
s_dir = dir(root);
for j = 1:length(s_dir)
    sub_name = s_dir(j).name;
    if sub_name(1) == 'S'
        graph_gen([root,'/',sub_name], parcel_name, graph_name);
    end
end