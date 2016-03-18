function [train_class, val_class] = labeller(nodes, train_bestmatchbyindex, val_bestmatchbyindex, train_input, y_train)

nodesl = labeling(nodes,train_input,y_train);


for i =1:size(train_bestmatchbyindex,2)
    train_class(i) = nodesl(train_bestmatchbyindex(i));
end
for i =1:size(val_bestmatchbyindex,2)
    val_class(i) = nodesl(val_bestmatchbyindex(i));
end
