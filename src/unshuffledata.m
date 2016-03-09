function [unshuffled_data_train] = unshuffledata(shuffled_data_train,indexes)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Unshuffles training data (data_train)',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
unshuffled_data_train = zeros(size(shuffled_data_train));
for i = 1:max(indexes)
    unshuffled_data_train(indexes(i)) = shuffled_data_train(indexes(i));
end