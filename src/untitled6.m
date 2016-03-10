% do the confusion matrix
function [class_train, class_val] = untitled6(nodes, data_train, data_val, y_train)
%%%%% ok, I will do a change in this function. data_train and data_val need
%%%%% to be chopped to the size of the nodes before labelling!

%old procedure would chop it. I need to put more parts together to make the
%adequate data again. I think it is just a matter of doing the right input
%calls

chopped_data_train = data_train;
chopped_data_val = data_val;
% chopped_data_train = zeros(size(chop_procedure(data_train(:,1),whichisit,q),1),size(data_train,2));
% for i =1:size(data_train,2)
%     chopped_data_train(:,i) = chop_procedure(data_train(:,i),whichisit,q);
% end
% 
% chopped_data_val = zeros(size(chop_procedure(data_val(:,1),whichisit,q),1),size(data_val,2));
% for i =1:size(data_val,2)
%     chopped_data_val(:,i) = chop_procedure(data_val(:,i),whichisit,q);
% end

%%%%%%
nodesl = labeling(nodes,chopped_data_train,y_train);
class_val = labeling(chopped_data_val, nodes, nodesl); % puts labels based on nodes labels on validation data 
class_train = labeling(chopped_data_train, nodes, nodesl); % puts labels based on nodes labels on training data 
