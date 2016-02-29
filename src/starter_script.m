global VERBOSE logfile
logfile = fopen('../var/log.txt','at');
VERBOSE = true; %%%% this is not really working...
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
NODES = 200*ones(1,16);
%NODES = fix(NODES/30);
gas_methods = struct('layername','','edges',[],'nodes',[],'class',struct('val',[],'train',[]),'bestmatch',[]); %bestmatch will have the training matrix for subsequent layers
all_gas = struct('gwr',gas_methods,'gng',gas_methods);
sts_structure = struct('data',[],'gwr',gas_methods);
savestructure(length(NODES)) = struct('nodes',[], 'pos', all_gas, 'vel', all_gas, 'train',struct('y',[],'data',[]),'STS',sts_structure,'confusions',struct('val',[],'train',[]));

dbgmsg('Starting parallel pool for GWR and GNG for nodes:',num2str(NODES),1)
dbgmsg('###Using multilayer GWR and GNG ###',1)
[polidx, velidx] = generateidx(size(data_train,1));

parfor i = 1:length(NODES)
    [savestructure(i).train.data, savestructure(i).train.y] = shuffledataftw(data_train, y_train);
    num_of_nodes = NODES(i);
    savestructure(i).nodes = num_of_nodes;
    %%%%%% POSITIONS
    dbgmsg('POS: Starting gwr for process:',num2str(i),1)
    [savestructure(i).pos.gwr.nodes, savestructure(i).pos.gwr.edges, ~, ~] = gng_lax(savestructure(i).train.data(polidx,:),num_of_nodes); %gets the upper part
    dbgmsg('POS: Finished gwr for process:',num2str(i),1)
    %%%%%% VELOCITIES
    dbgmsg('VEL: Starting gwr for process:',num2str(i),1)
    [savestructure(i).vel.gwr.nodes, savestructure(i).vel.gwr.edges, ~, ~] = gng_lax(savestructure(i).train.data(velidx,:),num_of_nodes); %gets the part below
    dbgmsg('VEL: Finished gwr for process:',num2str(i),1)
    
    %%%%%% FIND BEST MATCHING UNITS TO DO IT OVER...
    dbgmsg('POS: Rebuilding matrix with best matching units for process:',num2str(i),1)
    savestructure(i).pos.gwr.bestmatch = genbestmmatrix(savestructure(i).pos.gwr.nodes, savestructure(i).train.data, 'pos');
    
    dbgmsg('VEL: Rebuilding matrix with best matching units for process:',num2str(i),1)
    savestructure(i).vel.gwr.bestmatch = genbestmmatrix(savestructure(i).vel.gwr.nodes, savestructure(i).train.data, 'vel');
    
    %%%%%% there should be here another layer of gwrs; I am not building it
    %%%%%% for the time being...
    dbgmsg('PRE-STS: Combining position and velocity gwr best matching unit matrices:',num2str(i),1)
    savestructure(i).STS.data = cat(2,savestructure(i).pos.gwr.bestmatch,savestructure(i).vel.gwr.bestmatch);
    
%         
%     dbgmsg('POS: Applying GWR labels for process:',num2str(i),1)
%     %%%%%% POSITIONS
%     [savestructure(i).pos.gwr.class.train, savestructure(i).pos.gwr.class.val] = untitled6(savestructure(i).pos.gwr.nodes, savestructure(i).train.data(),data_val(), savestructure(i).train.y);
%     dbgmsg('VEL: Applying GWR labels for process:',num2str(i),1)
%     %%%%%% VELOCITIES
%     [savestructure(i).vel.gwr.class.train, savestructure(i).vel.gwr.class.val] = untitled6(savestructure(i).vel.gwr.nodes, savestructure(i).train.data(),data_val(), savestructure(i).train.y);
%     
    
    %%%%%% STS-LAYER
    dbgmsg('STS-LAYER: Starting gwr for process:',num2str(i),1)
    [savestructure(i).STS.gwr.nodes, savestructure(i).STS.gwr.edges, ~, ~] = gng_lax(savestructure(i).STS.data,num_of_nodes); %gets the part below
    dbgmsg('STS-LAYER: Finished gwr for process:',num2str(i),1)
    dbgmsg('STS-LAYER: Applying gwr labels for process:',num2str(i),1)
    [savestructure(i).STS.gwr.class.train, savestructure(i).STS.gwr.class.val] = untitled6(savestructure(i).STS.gwr.nodes, savestructure(i).train.data,data_val, savestructure(i).train.y);
    
    
%     dbgmsg('Starting gng for process:',num2str(i),1)
%     [savestructure(i).nodes_gng,savestructure(i).edges_gng, ~, ~] = gng_lax(savestructure(i).data_train,num_of_nodes);
%     dbgmsg('Finished gng for process:',num2str(i),1)
%         
%     dbgmsg('Applying GNG labels for process:',num2str(i),1)
%     [savestructure(i).class_train_gng, savestructure(i).class_val_gng] = untitled6(savestructure(i).nodes_gng, savestructure(i).data_train,data_val, savestructure(i).y_train);
end

dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(NODES),1)
u = {};
for i=1:length(savestructure)
    [~,savestructure(i).confusions.val,~,~] = confusion(y_val,savestructure(i).STS.gwr.class.val);
    [~,savestructure(i).confusions.train,~,~] = confusion(savestructure(i).train.y,savestructure(i).STS.gwr.class.train);
    %tempvar = num2str(savestructure(i).confusions.val);
    dbgmsg(strcat(num2str(i),'-th set. Confusion matrix on this validation set:',writedownmatrix(savestructure(i).confusions.val)),1)
    gwr_u = {y_val,savestructure(i).STS.gwr.class.val, strcat('GWR Val ', num2str(savestructure(i).nodes)),savestructure(i).train.y,savestructure(i).STS.gwr.class.train,strcat('GWR Train ', num2str(savestructure(i).nodes))};
    %gng_u = {y_val,savestructure(i).gng.class.val, strcat('GNG Val ', num2str(savestructure(i).nodes)),savestructure(i).train.y,savestructure(i).gwr.class.train,strcat('GNG Train ', num2str(savestructure(i).nodes))};
    
    u = {u{:}, gwr_u{:}};%, gng_u{:}}; 
end
% plotconfusion(u{:})
% figure
% plotconfusion(ones(size(y_val)),y_val, 'always guess "it''s a fall" on Validation Set:',zeros(size(y_val)),y_val, 'always guess "it''s NOT a fall" on Validation Set:')
% clear i
f1 = howgood(savestructure);
dbgmsg('F1 for validation:', num2str(f1(1)),1)
dbgmsg('F1 for training:', num2str(f1(2)),1)
disp(f1(1))