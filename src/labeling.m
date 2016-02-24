% the labeling function for the GWR and GNG
% cf parisi, adopt the label of the nearest node

%so first we need to know the label of each node
% we do exactly as parisi, with the labeling after the learning phase
% this he calls the training phase (but everything is the training phase)
% go through the nodeset and see in the data_set what is more similar
function labels = labeling(nodes, data, y)
%%%%%MESSAGES 
dbgmsg('Applying labels to the prototypical nodes.',1)
%%%%%
maxmax = size(nodes,2);
labels = zeros(1,maxmax);

for i = 1:maxmax
    [~, ~, ni1 , ~ , ~] = findnearest(nodes(:,i), data); % s1 is the index of the nearest point in data
    labels(i) = y(ni1);
end