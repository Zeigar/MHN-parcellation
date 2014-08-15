%% cosine density function (using raw data)
function density = cosineDensFunc(data, i, neighborPoints, graph, knn)
density = sum(data(i,:)*data(neighborPoints,:)'/sqrt(sum(data(i,:).^2,2))./sum(data(neighborPoints,:).^2,2)')/knn;