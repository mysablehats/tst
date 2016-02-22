% do the confusion matrix
function [class_train, class_val] = untitled6(nodes, data_train, data_val, y_train, y_val, namename)
nodesl = labeling(nodes,data_train,y_train);
class_val = labeling(data_val, nodes, nodesl); % puts labels based on nodes labels on validation data 
class_train = labeling(data_train, nodes, nodesl); % puts labels based on nodes labels on training data 
u = plotconfusion(y_val,class_val, 'Performed on Validation Set:',y_train,class_train,'Performed on the Training Set:'); % I am using the wrong names here. My Y is actually the T and the class_val is the y... I should change this everywhere, but for now
u.Name = namename;