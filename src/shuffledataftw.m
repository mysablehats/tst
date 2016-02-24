function [shuffled_data_train, shuffled_y_train] = shuffledataftw(data_train, y_train)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Shuffles training data (data_train) and training labels (y_train) together.',1)
dbgmsg('This is supposed to make training from the gas faster.',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

crazyI = randperm(length(y_train));
shuffled_data_train = data_train(:,crazyI);
shuffled_y_train = y_train(crazyI);