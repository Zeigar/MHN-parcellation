%% cosine density function (using raw data)
function density = euclidDensFunc(data, i, neighborPoints, graph, knn)
% when applied, we assume data to have uniform length
dists = sqrt(sum(data(i,:).^2) + sum(data(neighborPoints,:).^2,2) - 2*data(neighborPoints,:)*data(i,:)');
density = -sum(dists)/knn;