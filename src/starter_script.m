global VERBOSE
VERBOSE = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%MESSAGES PART
disp('####### ATTENTION IMBECILE: ####### YOU SHOULD ADD EVERYTHING TO THE PATH AND EXECUTE IT IN THE TST/SRC DIRECTORY. IF YOU WANT TO MAKE YOUR ALGORITHM HARD TO THESE CHANGES, BE MY GUEST, OTHERWISE JUST DO IT EACH TIME YOU START MATLAB, OR THIS WILL NOT RUN!!!!')
dbgmsg('Running starter script')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate_skel_data %% very time consuming -> also will generate a new
% %%validation and training set
% dbgmsg('Skeleton data (training and validation) generated.')

clear all

load_skel_data
[data_train, data_val] = removehipbias(data_train, data_val);
NODES = [10 10 10];
%NODES = fix(NODES/30);
savestructure(length(NODES)) = struct('nodes',[], 'data_train',[], 'y_train',[], 'nodes_gwr',[], 'edges_gwr',[], 'nodes_gng',[], 'edges_gng',[], 'class_train_gwr',[], 'class_val_gwr',[], 'class_train_gng',[], 'class_val_gng',[]);

dbgmsg('Starting parallel pool for GWR and GNG for nodes:',num2str(NODES),1)
parfor i = 1:length(NODES)
    [savestructure(i).data_train, savestructure(i).y_train] = shuffledataftw(data_train, y_train);
    num_of_nodes = NODES(i);
    savestructure(i).nodes = num_of_nodes;
    dbgmsg('Starting gwr for process:',num2str(i),1)
    [savestructure(i).nodes_gwr, savestructure(i).edges_gwr, ~, ~] = gwr(savestructure(i).data_train,num_of_nodes);
    dbgmsg('Finished gwr for process:',num2str(i),1)
    dbgmsg('Starting gng for process:',num2str(i),1)
    [savestructure(i).nodes_gng,savestructure(i).edges_gng, ~, ~] = gng_lax(savestructure(i).data_train,num_of_nodes);
    dbgmsg('Finished gng for process:',num2str(i),1)
    dbgmsg('Applying GWR labels for process:',num2str(i),1)
    [savestructure(i).class_train_gwr, savestructure(i).class_val_gwr] = untitled6(savestructure(i).nodes_gwr, savestructure(i).data_train,data_val, savestructure(i).y_train);
    dbgmsg('Applying GNG labels for process:',num2str(i),1)
    [savestructure(i).class_train_gng, savestructure(i).class_val_gng] = untitled6(savestructure(i).nodes_gng, savestructure(i).data_train,data_val, savestructure(i).y_train);
end

%plotconfusion(ones(size(y_val)),y_val, 'always a fall on Validation Set:',zeros(size(y_val)),y_val, 'never a fall on Validation Set:')
dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(NODES),1)
u = {};
for i=1:length(savestructure)
    
    gwr_u = {y_val,savestructure(i).class_val_gwr, strcat('GWR Val ', num2str(savestructure(i).nodes)),savestructure(i).y_train,savestructure(i).class_train_gwr,strcat('GWR Train ', num2str(savestructure(i).nodes))};
    gng_u = {y_val,savestructure(i).class_val_gng, strcat('GNG Val ', num2str(savestructure(i).nodes)),savestructure(i).y_train,savestructure(i).class_train_gng,strcat('GNG Train ', num2str(savestructure(i).nodes))};
    
    u = {u{:}, gwr_u{:}, gng_u{:}}; 
end
plotconfusion(u{:})
clear i
