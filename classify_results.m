%% classification results
clear; close all;
%% unnormalized region
figure(1);
hold on;
load acc_region_unnorm;
plot(2:2:40, accuracy, 'r');
load acc_region_aal_unnorm;
plot(2:2:40, accuracy, 'b');
xlabel('number of features');
ylabel('accuracy');
legend('Hopfield', 'AAL-90');

%% normalized region
figure(2);
hold on;
load acc_region;
plot(2:2:40, accuracy, 'r');
load acc_region_aal;
plot(2:2:40, accuracy, 'b');
xlabel('number of features');
ylabel('accuracy');
legend('Hopfield', 'AAL-90');

%% connectivity
figure(3);
hold on;
load acc_conn;
plot(100:100:4000, accuracy, 'r');
load acc_conn_aal;
plot(100:100:4000, accuracy(1:40), 'b');
xlabel('number of features');
ylabel('accuracy');
legend('Hopfield', 'AAL-90');