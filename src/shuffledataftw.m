function [shuffled_data_train, shuffled_indexes ] = shuffledataftw(data_train)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Shuffles training data (data_train) and generates the indexes for unshuffling',1)
dbgmsg('Shuffling is supposed to make training from the gas faster.',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

crazyI = randperm(size(data_train,2));
indexes = 1:size(data_train,2);
shuffled_indexes = indexes(crazyI);
shuffled_data_train = data_train(:,crazyI);


% %this is the old shuffledata function. I've changed to get an index and
% require itself to be unshuffled, because the sequence of the action is
% important for the next steps, so it got a bit different.
% function [shuffled_data_train, shuffled_y_train] = shuffledataftw(data_train, y_train)
% %%%%%%%%%%MESSAGES PART
% dbgmsg('Shuffles training data (data_train) and training labels (y_train) together.',1)
% dbgmsg('This is supposed to make training from the gas faster.',1)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% crazyI = randperm(length(y_train));
% shuffled_data_train = data_train(:,crazyI);
% shuffled_y_train = y_train(crazyI);