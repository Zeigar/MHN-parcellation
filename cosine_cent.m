function cent = cosine_cent(X)
% X is N-by-P, unnormalized, cent is a 1-by-P row vector
[N,P] = size(X);
Xnorm = sqrt(sum(X.^2, 2));
X = X ./ repmat(Xnorm, 1, P);
cent = sum(X,1)/N;
cent = cent / norm(cent);


