global VERBOSE
VERBOSE = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%MESSAGES PART
dbgmsg('Running starter script')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate_skel_data %% very time consuming -> also will generate a new
% %%validation and training set
% dbgmsg('Skeleton data (training and validation) generated.')

%clear all

%load_skel_data
%[data_train, data_val] = removehipbias(data_train, data_val);
%[data_train, y_train] = shuffledataftw(data_train, y_train);
NODES = [10 10 10];
%NODES = fix(NODES/30);
savestructure = struct();

dbgmsg('Starting parallel pool for GWR and GNG for nodes:',num2str(NODES),1)
parfor i = 1:length(NODES)
    num_of_nodes = NODES(i);
    savestructure(i).nodes = num_of_nodes;
    dbgmsg('Starting gwr for process:',num2str(i),1)
    [savestructure(i).nodes_gwr, savestructure(i).edges_gwr, ~, ~] = gwr(data_train,num_of_nodes);
    dbgmsg('Finished gwr for process:',num2str(i),1)
    dbgmsg('Starting gng for process:',num2str(i),1)
    [savestructure(i).nodes_gng,savestructure(i).edges_gng, ~, ~] = gng_lax(data_train,num_of_nodes);
    dbgmsg('Finished gnr for process:',num2str(i),1)
    
end
save('../share/gng_gwr','data_train', 'data_val', 'y_train', 'y_val','savestructure')
%%%%%%%%%%%%%%%%%%%%%%%%%%
load('../share/gng_gwr')
%%%%%%%dbgmsg('Starting parallel pool for labelling GWR and GNG nodes:',num2str(NODES),1)
%doesnt work with parfor. don't know why, maybe should debug in the future.
%but labelling isn't that time consuming
for i = 1:length(savestructure)
    num_of_nodes = savestructure(i).nodes;
    [savestructure(i).class_train_gwr, savestructure(i).class_val_gwr] = untitled6(savestructure(i).nodes_gwr, data_train,data_val, y_train);
    [savestructure(i).class_train_gng, savestructure(i).class_val_gng] = untitled6(savestructure(i).nodes_gng, data_train,data_val, y_train);
end
%figure
%plotconfusion(ones(size(y_val)),y_val, 'always a fall on Validation Set:',zeros(size(y_val)),y_val, 'never a fall on Validation Set:')
dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(NODES),1)
u = {};
for i=1:length(savestructure)
    
    gwr_u = {y_val,savestructure(i).class_val_gwr, strcat('GWR Val ', num2str(savestructure(i).nodes)),y_train,savestructure(i).class_train_gwr,strcat('GWR train ', num2str(savestructure(i).nodes))};
    gng_u = {y_val,savestructure(i).class_val_gng, strcat('GNG Val ', num2str(savestructure(i).nodes)),y_train,savestructure(i).class_train_gng,strcat('GNG train ', num2str(savestructure(i).nodes))};
    
    u = {u{:}, gwr_u{:}, gng_u{:}}; 
end
plotconfusion(u{:})
clear i
