% the labeling function for the GNG
% cf parisi, adopt the label of the nearest node

%so first we need to know the label of each node
% we do exactly as parisi, with the labeling after the learning phase
% this he calls the training phase (but everything is the training phase)
% go through the nodeset and see in the data_set what is more similar
function labels = labeling(nodes, data, y)

labels = zeros(1,length(nodes));
for i = 1:length(nodes)
    progress(i,length(nodes))
    [s1 s2 distances] = findTwoNearest(nodes(:,i),data); % s1 is the index of the nearest point in data
    labels(i) = y(s1);
end