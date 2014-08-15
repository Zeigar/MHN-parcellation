%% DBSCAN graph version
function class = dbscanNeighbor(data, neighbor, eps, graph, densityFunc)
% data + neighboring graph version of dbscan
% inputs:
% data - raw signatures of data
% neighbor - the neighbor index map
% eps - threshold for density
% outputs:
% class - cluster assignment

[n,knn] = size(neighbor);
visited = false(n,1);
C = 0; % cluster label
class = zeros(n,1);
for i = 1:n
%     fprintf('%d\n',i);
    if (visited(i)), continue; end
    visited(i) = true;
    neighborPoints = neighbor(i,:); % topological neighboring points of i
    neighborPoints = neighborPoints(neighborPoints>0);
    density = densityFunc(data, i, neighborPoints, graph, knn);
    if density > eps
        C = C+1; % next cluster
        [class, visited] = expandCluster(data, neighbor, i, neighborPoints, C, eps, class, visited, graph, densityFunc, knn);
    end
    
end

%% expand cluster
function [class, visited] = expandCluster(data, neighbor, i, neighborPoints, C, eps, class, visited, graph, densityFunc, knn)
class(i) = C;
neighborPoints1 = neighborPoints(neighborPoints>0);
neighborPoints = [];
for j = 1:length(neighborPoints1)
    np = neighborPoints1(j);
    if class(np)==0, class(np) = C; end
    if ~visited(np)
        visited(np) = true;
        neighborPoints = [neighborPoints, np]; 
    end
end

while ~isempty(neighborPoints)
    p = neighborPoints(1);
    neighborPoints(1) = [];
    neighborPoints1 = neighbor(p,:);
    neighborPoints1 = neighborPoints1(neighborPoints1>0);
    density = densityFunc(data, p, neighborPoints1, graph, knn);
    if density > eps
        for j = 1:length(neighborPoints1)
            np = neighborPoints1(j);
            if class(np)==0, class(np) = C; end
            if ~visited(np)
                visited(np) = true;
                neighborPoints = [neighborPoints, np]; 
            end
        end
    end
end







    
    
    