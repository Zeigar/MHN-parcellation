function ind = vec2ind(vec)
ind = zeros(size(vec,1),1);
[y, x] = find(vec'==1);
ind(x) = y;