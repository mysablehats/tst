fclose('all');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%MESSAGES PART
dbgmsg('=======================================================================================================================================================================================================================================')
dbgmsg('Running starter script')
dbgmsg('=======================================================================================================================================================================================================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%generate_skel_data %% very time consuming -> also will generate a new
% clear all
% dbgmsg('Skeleton data (training and validation) generated.')
% %%validation and training set

aa_environment
load_skel_data
[data_train, data_val] = removehipbias(data_train, data_val); 
% I will take only a part of the data-set out
NODES = 300; %*ones(1,8);
%NODES = fix(NODES/30);

%%%% gas structures region

%%%% connection definitions:
 allconn = {...
     {'gwr1layer',   'gwr',{'pos'},                    'pos',3}...
     {'gwr2layer',   'gwr',{'vel'},                    'vel',3}...
     {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3}...
     {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3}...
     {'gwr5layer',   'gwr',{'gwr3layer'},              'pos',3}...
     {'gwr6layer',   'gwr',{'gwr4layer'},              'vel',3}...
     {'gwrSTSlayer', 'gwr',{'gwr6layer','gwr5layer'},  'all',3}};

%allconn = {{'gwr1layer',   'gwr',{'pos'},                    'pos'}...
%           {'gwr12ayer',   'gwr',{'gwr1layer'},                    'pos'}};

%%%% building arq_connect
arq_connect(1:length(allconn)) = struct('name','','method','','sourcelayer','', 'layertype','','q',1);
parfor i = 1:length(allconn)
    arq_connect(i).name = allconn{i}{1};
    arq_connect(i).method = allconn{i}{2};
    arq_connect(i).sourcelayer = allconn{i}{3};
    arq_connect(i).layertype = allconn{i}{4};
    arq_connect(i).q = allconn{i}{5};
end
inputs = struct('input',[],'input_ends',[]);
gas_data = struct('name','','class',[],'inputs',inputs,'confusions',[]);
gas_methods(1:length(arq_connect)) = struct('name','','edges',[],'nodes',[],'bestmatch',[],'fig',[]); %bestmatch will have the training matrix for subsequent layers
vt_data = struct('indexes',[],'data',[],'ends',[],'gas',gas_data);
savestructure(1:length(NODES)) = struct('maxnodes',[], 'gas', gas_methods, 'train',vt_data,'val',vt_data,'figset',[]); % I have a problem with figset. I don't kno
parfor i = 1:length(savestructure) % oh, I don't know how to do it elegantly
    savestructure(i).figset = {};
end

%%% end of gas structures region

dbgmsg('Starting parallel pool for GWR and GNG for nodes:',num2str(NODES),1)
dbgmsg('###Using multilayer GWR and GNG ###',1)
[posidx, velidx] = generateidx(size(data_train,1));

for i = 1:length(NODES)
    %[savestructure(i).train.data, savestructure(i).train.indexes] =
    %shuffledataftw(data_train); % I cant shuffle any longer...
    %but I still need to assign it !
    num_of_nodes = NODES(i);
    savestructure(i).maxnodes = num_of_nodes;
    savestructure(i).train.data = data_train;
    savestructure(i).train.ends = ends_train;
    
    for j = 1:length(arq_connect)
        %will I shift enormous matrices around? yes.
        savestructure(i).gas(j).name = arq_connect(j).name;
        savestructure(i).gas(j).method = arq_connect(j).method;
      
        %all of the long inputing will be done inside setinput, because it
        %has to be like this...
        [savestructure(i).train.gas(j).inputs.input, savestructure(i).train.gas(j).inputs.input_ends]  = setinput(arq_connect(j), savestructure(i), size(data_train,1), savestructure(i).train); %%%%%%
  
        %shuffle could be applied in input
        
        
        %%%% PRE-MESSAGE
        dbgmsg('Working on gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') with method: ',savestructure(i).gas(j).method ,' for process:',num2str(i),1)
        %DO GNG OR GWR
        if strcmp(arq_connect(j).method,'gng')
            %do gng
            [savestructure(i).gas(j).nodes, savestructure(i).gas(j).edges, ~, ~] = gng_lax(savestructure(i).train.gas(j).inputs.input,num_of_nodes); 
        elseif strcmp(arq_connect(j).method,'gwr')
            %do gwr
            [savestructure(i).gas(j).nodes, savestructure(i).gas(j).edges, ~, ~] = gwr(savestructure(i).train.gas(j).inputs.input,num_of_nodes); 
        else
            error('unknown method')
        end
        %%%% POS-MESSAGE
        dbgmsg('Finished working on gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') with method: ',savestructure(i).gas(j).method ,'.Num of nodes reached:',num2str(size(savestructure(i).gas(j).nodes,2)),' for process:',num2str(i),1)
        %%%% FIND BESTMATCHING UNITS
        
        %PRE MESSAGE  
        dbgmsg('Finding best matching units for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        savestructure(i).gas(j).bestmatch = genbestmmatrix(savestructure(i).gas(j).nodes, savestructure(i).train.gas(j).inputs.input, arq_connect(j).layertype, arq_connect(j).q); %assuming the best matching node always comes from initial dataset!
    
        %since I can't shuffle, then I dont need to unshuffle
        %now I have to unshuffle to label it.
        %dbgmsg('Unshuffling best matching units for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        %savestructure(i).gas(j).bestmatch = unshuffledata(savestructure(i).gas(j).bestmatch ,savestructure(i).train.indexes);
        
       end
    
end

dbgmsg('Labelling',num2str(NODES),1)

for i=1:length(savestructure)
    savestructure(i).val.data = data_val;
    savestructure(i).val.ends = ends_val;
    for j =1:length(savestructure(i).gas)
        %labeling
        %pretty much useless unless it is the last layer, but I can label
        %everyone, so I will.
        savestructure(i).train.gas(j).name = arq_connect(j).name;
        savestructure(i).val.gas(j).name = arq_connect(j).name;
        
        
        dbgmsg('Setting validation input for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [savestructure(i).val.gas(j).inputs.input, savestructure(i).val.gas(j).inputs.input_ends]  = setinput(arq_connect(j), savestructure(i), size(data_train,1), savestructure(i).val);
        dbgmsg('Applying labels for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [savestructure(i).train.gas(j).class, savestructure(i).val.gas(j).class] = untitled6(savestructure(i).gas(j).bestmatch, savestructure(i).train.gas(j).inputs.input,savestructure(i).val.gas(j).inputs.input, y_train);
        
    end
end

dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(NODES),1)

parfor i=1:length(savestructure)
    for j =1:length(savestructure(i).gas)
        [~,savestructure(i).gas(j).confusions.val,~,~] = confusion(y_val,savestructure(i).gas(j).class.val);
        [~,savestructure(i).gas(j).confusions.train,~,~] = confusion(y_train,savestructure(i).gas(j).class.train);
        
        dbgmsg(num2str(i),'-th set.',savestructure(i).gas(j).name,' Confusion matrix on this validation set:',writedownmatrix(savestructure(i).gas(j).confusions.val),1)
        savestructure(i).gas(j).fig = {y_val,                   savestructure(i).gas(j).class.val,  strcat(savestructure(i).gas(j).method,' Val ', num2str(savestructure(i).maxnodes)),...
                                       y_train,savestructure(i).gas(j).class.train,strcat(savestructure(i).gas(j).method,'Train ', num2str(savestructure(i).maxnodes))}; %difficult to debug line, sorry. if it doesn't work, weep.
        savestructure(i).figset = {savestructure(i).figset{:}, savestructure(i).gas(j).fig{:}};
    end
end
%for i = 1:length(savestructure)
% plotconfusion(savestructure(i).figset{:})
% figure
%end
% plotconfusion(ones(size(y_val)),y_val, 'always guess "it''s a fall" on Validation Set:',zeros(size(y_val)),y_val, 'always guess "it''s NOT a fall" on Validation Set:')
% clear i
for j = 1:length(savestructure(1).gas) %this is weird, but I just changed this to show only the last gas
    f1 = howgood(savestructure,j);
    dbgmsg(savestructure(1).gas(j).name,'F1 for validation overall mean:', num2str(f1(1)),'||','F1 for training overall mean:', num2str(f1(2)),1)
    disp(f1(1))
    f1 = whoisbest(savestructure,j);
    dbgmsg(savestructure(1).gas(j).name,'F1 for validation best:', num2str(f1(1)),'||','F1 for training best:', num2str(f1(2)),1)
    disp(f1(1))
end
