% do the confusion matrix
function [class_train, class_val] = untitled6(nodes, data_train, data_val, y_train)
nodesl = labeling(nodes,data_train,y_train);
class_val = labeling(data_val, nodes, nodesl); % puts labels based on nodes labels on validation data 
class_train = labeling(data_train, nodes, nodesl); % puts labels based on nodes labels on training data 
