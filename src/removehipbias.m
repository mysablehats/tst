%removehipbias
%have to initiate a newer array with one dimension less...
function [conform_train, conform_val] = conformskel(data_train, data_val, )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Applies translation invariance on both training and validation datasets',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conform_train = zeros(size(data_train)-[3 0]);
conform_val = zeros(size(data_val)-[3 0]);

for i = 1:size(data_train,2)
    conform_train(:,i) = centerhips(data_train(:,i));
end
for i = 1:size(data_val,2)
    conform_val(:,i) = centerhips(data_val(:,i));
end
end
function newskel = centerhips(skel)
%%%%%%%%%MESSAGES PART
%%%%%%%%ATTENTION: this function is executed in loops, so running it will
%%%%%%%%messages on will cause unpredictable behaviour
%dbgmsg('Removing displacement based on hip coordinates (1st point on 25x3 skeleton matrix) from every other')
%dbgmsg('This makes the dataset translation invariant')
%%%%%%%%%%%%%%%%%%%%%
[tdskel,hh] = makefatskel(skel);

hips = [repmat(tdskel(1,:),25,1);zeros(hh-25,3)]; 

newskel = tdskel - hips;
newskel(1,:) = [];
% newskel = zeros(size(tdskel)-[1 0]);
% for i = 2:hh
%     newskel(i-1,:) = tdskel(i,:)- 1*hips;
% end

%I need to shape it back into 75(-3 now) x 1
newskel = makethinskel(newskel);
end
