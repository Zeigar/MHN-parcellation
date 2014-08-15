function vec = ind2vec(ind, d)
n = length(ind);
vec = zeros(n,d);
ind1 = (ind-1)*n+(1:n)';
vec(ind1) = 1;