%% classify using connectivity
n_feats = 100:100:4000;
accuracy = zeros(1, length(n_feats));
n_exp = 100;
n_exp_real = zeros(1, length(n_feats));
k = 1;
for i = n_feats
    fprintf('number of feats:%d\n', i);
    for t = 1:n_exp
        try
            n_all = length(label_all);
            n_train = round(4/5*n_all); % training set
            perm_ind = randperm(length(label_all));
            train_ind = perm_ind(1:n_train);
            test_ind = perm_ind(n_train+1:end);
            
            Xtrain = conn_vec_all(train_ind,st_i_conn(1:i));
            ytrain = label_all(train_ind);
            Xtest = conn_vec_all(test_ind,st_i_conn(1:i));
            ytest = label_all(test_ind);
            
            model = svmtrain(Xtrain, ytrain, 'kernel_function', 'linear');
%             model = svmtrain(Xtrain, ytrain);
            ypred = svmclassify(model, Xtest);
            % model = ClassificationTree.fit(Xtrain,ytrain);
            % ypred = predict(model, Xtest);
            
            accuracy(k) = accuracy(k) + length(find(ypred==ytest)) / length(ytest);
            n_exp_real(k) = n_exp_real(k) + 1;
        catch err
            fprintf('error catched at exp feats-%d, exp-%d!\n', i, t);
            continue;
        end
    end
    k = k+1;
end

accuracy = accuracy ./ n_exp_real;
figure(2);hold on;
plot(n_feats, accuracy, 'b');

% save acc_conn_rbf accuracy;