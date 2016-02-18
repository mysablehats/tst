% do the confusion matrix
nodesl = labeling(nodes,data_train,y_train);
class_val = labeling(data_val, nodes, nodesl); % puts labels based on nodes labels on validation data 
class_train = labeling(data_train, nodes, nodesl); % puts labels based on nodes labels on training data 
plotconfusion(y_val,class_val) % I am using the wrong names here. My Y is actually the T and the class_val is the y... I should change this everywhere, but for now
figure
plotconfusion(y_train,class_train)