global VERBOSE
VERBOSE = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%MESSAGES PART
dbgmsg('Running starter script')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate_skel_data %% very time consuming -> also will generate a new
% %%validation and training set
% dbgmsg('Skeleton data (training and validation) generated.')

clear all

load_skel_data
[data_train, data_val] = removehipbias(data_train, data_val);
[data_train, y_train] = shuffledataftw(data_train, y_train);
NODES = [10 10 10 10 10];
%NODES = fix(NODES/30);
savestructure = struct();

dbgmsg('Starting parallel pool for GWR and GNG for nodes:',num2str(NODES),1)
for i = 1:length(NODES)
    num_of_nodes = NODES(i);
    dbgmsg('Starting gwr for process:',num2str(i),1)
    [savestructure(i).nodes_gwr, savestructure(i).edges_gwr, ~, ~] = gwr(data_train,num_of_nodes);
    dbgmsg('Finished gwr for process:',num2str(i),1)
%     
%     [nodes_gng,edges_gng, ~, ~] = gng_lax(data_train,num_of_nodes);
%   
    savestructure(i).nodes = num_of_nodes;
    
%    savestructure(i).nodes_gng = nodes_gng;
%    savestructure(i).edges_gng = edges_gng;
end
dbgmsg('Saving gng_gwr nodes and edges matrices...',1)
for i = 1:length(NODES)
    num_of_nodes = NODES(i);
    nodes_gwr = savestructure(i).nodes_gwr;
    edges_gwr = savestructure(i).edges_gwr;
%     nodes_gng = savestructure(i).nodes_gng;
%     edges_gng = savestructure(i).edges_gng;
    save(strcat('../share/gng_gwr',num2str(num_of_nodes),'_',num2str(i),'.mat' ))
end
dbgmsg('Loading gng_gwr nodes and edges matrices...',1)
for i = 1:length(NODES)
    num_of_nodes = NODES(i);
    load(strcat('../share/gng_gwr',num2str(num_of_nodes),'_',num2str(i),'.mat' ))
end
confusionstruc = struct();
%%%%%%%dbgmsg('Starting parallel pool for labelling GWR and GNG nodes:',num2str(NODES),1)
%doesnt work with parfor. don't know why, maybe should debug in the future.
%but labelling isn't that time consuming
for i = 1:length(NODES)
    num_of_nodes = NODES(i);
    nodes_gwr = savestructure(i).nodes_gwr;
    [class_train_gwr, class_val_gwr] = untitled6(nodes_gwr, data_train,data_val, y_train);
    confusionstruc(i).class_train_gwr = class_train_gwr;
    confusionstruc(i).class_val_gwr = class_val_gwr;
%     figure
% 
%     [class_train_gng, class_val_gng] = untitled6(nodes_gng, data_train, data_val, y_train, y_val,strcat('GNG Classifier ', num2str(num_of_nodes)));
%     confusionstruc(i).class_train_gng = class_train_gng;
%     confusionstruc(i).class_val_gng = class_val_gng;
end
%figure
%plotconfusion(ones(size(y_val)),y_val, 'always a fall on Validation Set:',zeros(size(y_val)),y_val, 'never a fall on Validation Set:')
dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(NODES),1)
for i=1:length(confusionstruc)
    num_of_nodes = NODES(i);
    class_train = confusionstruc(i).class_train_gwr;
    class_val = confusionstruc(i).class_val_gwr;
    namename = strcat('GWR Classifier ',num2str(num_of_nodes));
    figure
    u = plotconfusion(y_val,class_val, 'Performed on Validation Set:',y_train,class_train,'Performed on the Training Set:'); % I am using the wrong names here. My Y is actually the T and the class_val is the y... I should change this everywhere, but for now
    u.Name = namename;    
end
clear i
