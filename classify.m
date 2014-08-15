%% classification of schizophrenia vs non-schizophrenia
n_feats = 2:2:40;
n_exp = 100; % number of  experiments for each parameter setting
accuracy = zeros(1, length(n_feats));
k = 1;
n_exp_real = zeros(1, length(n_feats));
for i = n_feats
    fprintf('number of feats:%d\n', i);
    for t = 1:n_exp
        try
            n_all = length(label_all);
            n_train = round(3/4*n_all); % training set
            perm_ind = randperm(length(label_all));
            train_ind = perm_ind(1:n_train);
            test_ind = perm_ind(n_train+1:end);
            
%             Xtrain = parcell_vec_norm_all(train_ind,st_i_norm(1:i));
            Xtrain = parcell_vec_all(train_ind,st_i(1:i));
            ytrain = label_all(train_ind);
%             Xtest = parcell_vec_norm_all(test_ind,st_i_norm(1:i));
            Xtest = parcell_vec_all(test_ind,st_i(1:i));
            ytest = label_all(test_ind);
            
%             Xtest = Xtrain;
%             ytest = ytrain;
            
%             model = svmtrain(Xtrain, ytrain, 'kernel_function', 'rbf', 'rbf_sigma', 1);
            model = svmtrain(Xtrain, ytrain, 'kernel_function', 'linear');
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
figure(1); hold on;
plot(n_feats,accuracy,'r');

% save acc_region_rbf accuracy;