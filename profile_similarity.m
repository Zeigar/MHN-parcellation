function score = profile_similarity(A,B)
d = size(A,1);
A(1:d+1:end) = 0;
B(1:d+1:end) = 0;
score = 0;
for i = 1:d
    score = score + A(i,:)*B(i,:)'/norm(A(i,:))/norm(B(i,:));
end
