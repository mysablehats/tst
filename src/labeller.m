function [train_class, val_class, nodesl] = labeller(nodes, train_bestmatchbyindex, val_bestmatchbyindex, train_input, y_train)

nodesl = labeling(nodes,train_input,y_train);

tcsize = size(train_bestmatchbyindex,2);
vcsize = size(val_bestmatchbyindex,2);

train_class = zeros(1,tcsize);
val_class = zeros(1,vcsize);

for i =1:tcsize
    train_class(i) = nodesl(train_bestmatchbyindex(i));
end
for i =1:vcsize
    val_class(i) = nodesl(val_bestmatchbyindex(i));
end
