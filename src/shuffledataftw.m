function [shuffled_data_train, shuffled_y_train] = shuffledataftw(data_train, y_train)
    crazyI = randperm(length(y_train));
    shuffled_data_train = data_train(crazyI);
    shuffled_y_train = y_train(crazyI);     