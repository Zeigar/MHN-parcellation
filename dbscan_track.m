
% -------------------------------------------------------------------------
% Function: [class,type]=dbscan_track(x,k,Eps,mass)
% -------------------------------------------------------------------------
% Aim:
% Clustering the data with Density-Based Scan Algorithm with Noise (DBSCAN)
% -------------------------------------------------------------------------
% Input:
% x - data set (m,6); m-objects, 6-variables
% k - number of objects in a neighborhood of an object
% (minimal number of objects considered as a cluster)
% Eps - neighborhood radius, if not known avoid this parameter or put []
% mass - mass vector, how many replicates for the track
% -------------------------------------------------------------------------
% Output:
% class - vector specifying assignment of the i-th object to certain
% cluster (m,1)
% type - vector specifying type of the i-th object
% (core: 1, border: 0, outlier: -1)
% -------------------------------------------------------------------------
% Example of use:
% x=[randn(30,2)*.4;randn(40,2)*.5+ones(40,1)*[4 4]];
% [class,type]=dbscan(x,5,[])
% clusteringfigs('Dbscan',x,[1 2],class,type)
% -------------------------------------------------------------------------
% References:
% [1] M. Ester, H. Kriegel, J. Sander, X. Xu, A density-based algorithm for
% discovering clusters in large spatial databases with noise, proc.
% 2nd Int. Conf. on Knowledge Discovery and Data Mining, Portland, OR, 1996,
% p. 226, available from:
% www.dbs.informatik.uni-muenchen.de/cgi-bin/papers?query=--CO
% [2] M. Daszykowski, B. Walczak, D. L. Massart, Looking for
% Natural Patterns in Data. Part 1: Density Based Approach,
% Chemom. Intell. Lab. Syst. 56 (2001) 83-92
% -------------------------------------------------------------------------
% Written by Michal Daszykowski
% Department of Chemometrics, Institute of Chemistry,
% The University of Silesia
% December 2004
% http://www.chemometria.us.edu.pl

function [class,type]=dbscan_track(x,k,Eps,mass)

[m,n]=size(x);

if isempty(Eps)
    [Eps]=epsilon(x,k,mass);
end

% x=[[1:m]' x];
[m,n]=size(x);
type=zeros(1,m);
class = zeros(1,m);
no=1;
touched=zeros(m,1);

for i=1:m
    if mod(i, 10000) == 0 
        fprintf('%d\n', i);
    end
    if touched(i)==0;
        ob=x(i,:);
        D=dist(ob,x);
        ind=find(D<=Eps);
        indm = sum(mass(ind)); % true mass that satisfies
        
        if indm>1 && indm<k+1
            type(i)=0;
            class(i)=0;
        end
        if indm==1 % outlier
            type(i)=-1;
            class(i)=-1;
            touched(i)=1;
        end
        
        if indm>=k+1;
            type(i)=1;
            class(i)=no;
            
            while ~isempty(ind)
                idx = ind(1);
                ind(1) = [];
                if touched(idx) == 0
                    ob=x(idx,:);
                    class(idx) = no;
                    touched(idx)=1;
                    D=dist(ob,x);
                    
                    i1=find(D<=Eps);
                    im1 = sum(mass(i1));
                    if im1>=k+1;
                        type(idx)=1;
                    else
                        type(idx)=0;
                    end
                    
                    for i2 = 1:length(i1)
                        if touched(i1(i2)) == 0
                            ind = [ind i1(i2)];
                        end
                    end
                end
            end
            no=no+1;
        end
    end
end



%...........................................
function [Eps]=epsilon(x,k,mass)

% Function: [Eps]=epsilon(x,k)
%
% Aim:
% Analytical way of estimating neighborhood radius for DBSCAN
%
% Input:
% x - data matrix (m,n); m-objects, n-variables
% k - number of objects in a neighborhood of an object
% (minimal number of objects considered as a cluster)



[m,n]=size(x);
mm = sum(mass);

Eps=((prod(max(x)-min(x))*k*gamma(.5*n+1))/(mm*sqrt(pi.^n))).^(1/n);


%............................................
function [D]=dist(i,x)

% function: [D]=dist(i,x)
%
% Aim:
% Calculates the Euclidean distances between the i-th object and all objects in x
%
% Input:
% i - an object (1,n)
% x - data matrix (m,n); m-objects, n-variables
%
% Output:
% D - Euclidean distance (1,m)

[m,n]=size(x);
% if n~=6
%     fprintf('error! data dimension should be 6!\n');
%     D = []; return;
% end

D1=sqrt(sum((((ones(m,1)*i)-x).^2)'));
x2 = [x(:,floor(n/2)+1:n), x(:,1:floor(n/2))];
D2 = sqrt(sum((((ones(m,1)*i)-x2).^2)'));
D = min([D1;D2],[],1);


