% do the confusion matrix
nodesl = labeling(nodes,data_train,y_train);
class_val = zeros(size(y_val));
for i = 1:length(data_val)
     [s1 s2 distances] = findTwoNearest(data_val(:,i),nodes); % for each data_val find nearest node
     class_val(i) = nodesl(s1);
end
confusion(y_val,class_val) % I am using the wrong names here. My Y is actually the T and the class_val is the y... I should change this everywhere, but for now
     