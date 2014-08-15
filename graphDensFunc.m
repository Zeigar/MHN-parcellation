%% graph based density function (using given similarity matrix)
function density = graphDensFunc(data, i, neighborPoints, graph, knn)
density = sum(graph(i,neighborPoints))/knn;