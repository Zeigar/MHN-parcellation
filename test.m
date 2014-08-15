%% test
nd = 10000;
data1 = randn(nd,2) + repmat([3,3],nd,1);
data2 = randn(nd,2) + repmat([-3,-3], nd,1);
data = [data1;data2];
ind = randperm(2*nd);
data = data(ind,:);

[n,d] = size(data);
dnorm = sum(data.^2,2);
dist = repmat(dnorm,1,n) + repmat(dnorm', n,1) - 2*data*data';
dist = sqrt(dist);
% simm = (max(dist(:)) - dist) / (max(dist(:))-min(dist(:)));
simm = -dist;
graph = zeros(n,n);
nn = 20;
% eps = 0.5*nn;
eps = -6;
neighbor = zeros(n,nn);
for i = 1:n
    [sv, si] = sort(simm(i,:), 'descend');
    graph(i,si(2:nn+1)) = sv(2:nn+1);
    neighbor(i,:) = si(2:nn+1);
end

class = dbscanNeighbor(data, neighbor, eps, graph, @cosineDensFunc);
class

scatter(data(:,1), data(:,2), [], class);