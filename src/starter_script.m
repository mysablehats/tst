%% starter_script
% This is the main script to run the chained classifier, label and generate
% confusion matrices and recall, precision and F1 values for the skeleton
% classifier of activities using an architecture of chained neural gases on
% skeleton activities data (the STS V2 Dataset). This work was done as
% implemented by Parisi, 2015's paper.

%%
%%%% STARTING MESSAGES PART FOR THIS RUN
global VERBOSE LOGIT
VERBOSE = true;
LOGIT = true;
dbgmsg('=======================================================================================================================================================================================================================================')
dbgmsg('Running starter script')
dbgmsg('=======================================================================================================================================================================================================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Generate Skeletons
% This takes quite a while to execute, so I rarely run it. 
%%% >>>>> this has to be changed into a function.
%generate_skel_data %% very time consuming -> also will generate a new
% clear all
% dbgmsg('Skeleton data (training and validation) generated.')
% %%validation and training set

%% Loads environment Variables and saved Data
fclose('all');
aa_environment
load_skel_data


NODES = 3; %*ones(1,8);
%NODES = fix(NODES/30);

%% Classifier structure definitions
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
gas_data = struct('name','','class',[],'inputs',inputs,'confusions',[],'bestmatch',[],'bestmatchbyindex',[]);
gas_methods(1:length(arq_connect)) = struct('name','','edges',[],'nodes',[],'fig',[]); %bestmatch will have the training matrix for subsequent layers
vt_data = struct('indexes',[],'data',[],'ends',[],'gas',gas_data);
savestructure(1:length(NODES)) = struct('maxnodes',[], 'gas', gas_methods, 'train',vt_data,'val',vt_data,'figset',[]); % I have a problem with figset. I don't kno
parfor i = 1:length(savestructure) % oh, I don't know how to do it elegantly
    savestructure(i).figset = {};
end

%%% end of gas structures region

%% Pre-conditioning of data
% 
%[data_train, data_val] = removehipbias(data_train, data_val); 
[data_train, data_val] = conformskel(data_train, data_val,'nohips');

%% Gas-chain Classifier
% This part executes the chain of interlinked gases. Each iteration is one
% gas, and currently it works as follows:
% 1. Function setinput() chooses based on the input defined in allconn
% 2. Run either a Growing When Required (gwr) or Growing Neural Gas (GNG)
% on this data
% 3. Generate matrix of best matching units to be used by the next gas
% architecture

dbgmsg('Starting chain structure for GWR and GNG for nodes:',num2str(NODES),1)
dbgmsg('###Using multilayer GWR and GNG ###',1)

for i = 1:length(NODES)
    %[savestructure(i).train.data, savestructure(i).train.indexes] =
    %shuffledataftw(data_train); % I cant shuffle any longer...
    %but I still need to assign it !
    num_of_nodes = NODES(i);
    savestructure(i).maxnodes = num_of_nodes;
    savestructure(i).train.data = data_train;
    savestructure(i).train.ends = ends_train;
    
    for j = 1:length(arq_connect)
        savestructure = gas_method(savestructure(i), arq_connect(j), i,j, num_of_nodes, size(data_train,1)); % I had to separate it to debug it.

    end
    
end
%% Labelling
% The current labelling procedure for both the validation and training datasets. As of this moment I label all the gases
% to see how adding each part increases the overall performance of the
% structure, but since this is slow, the variable whatIlabel can be changed
% to contain only the last gas.
%
% The labelling procedure is simple. It basically picks the label of the
% closest point and assigns to that. In a sense the gas can be seen as a
% dimensional (as opposed to temporal) filter, encoding prototypical
% action-lets.
dbgmsg('Labelling',num2str(NODES),1)

whatIlabel = 1:length(savestructure(1).gas); %change this series for only the last value to label only the last gas

for i=1:length(savestructure)
    savestructure(i).val.data = data_val;
    savestructure(i).val.ends = ends_val;
    for j = whatIlabel
        %labeling
        %pretty much useless unless it is the last layer, but I can label
        %everyone, so I will.
        savestructure(i).train.gas(j).name = arq_connect(j).name;
        savestructure(i).val.gas(j).name = arq_connect(j).name;
        
        dbgmsg('Setting validation input for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [savestructure(i).val.gas(j).inputs.input, savestructure(i).val.gas(j).inputs.input_ends]  = setinput(arq_connect(j), savestructure(i), size(data_train,1), savestructure(i).val);
                
        % I didn't realize, but I need to do this for the validation
        % dataset as well.
        dbgmsg('Finding best matching units for gas: ''',savestructure.gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [savestructure(i).val.gas(j).bestmatch, savestructure(i).val.gas(j).bestmatchbyindex] = genbestmmatrix(savestructure(i).gas(j).nodes, savestructure(i).val.gas(j).inputs.input, arq_connect(j).layertype, arq_connect(j).q); %assuming the best matching node always comes from initial dataset!
        
        dbgmsg('Applying labels for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [savestructure(i).train.gas(j).class, savestructure(i).val.gas(j).class] = labeller(savestructure(i).gas(j).nodes, savestructure(i).train.gas(j).bestmatchbyindex,  savestructure(i).val.gas(j).bestmatchbyindex, savestructure(i).train.gas(j).inputs.input, y_train);
        %%%% I dont understand what I did, so I will code this again.
        %%% why did I write .bestmatch when it should be nodes??? what was I thinnking [savestructure(i).train.gas(j).class, savestructure(i).val.gas(j).class] = untitled6(savestructure(i).gas(j).bestmatch, savestructure(i).train.gas(j).inputs.input,savestructure(i).val.gas(j).inputs.input, y_train);
        
    end
end

%% Displaying multiple confusion matrices for GWR and GNG for nodes
% This part creates the matrices that can later be shown with the
% plotconfusion() function.
dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(NODES),1)

parfor i=1:length(savestructure)
    for j = whatIlabel
        [~,savestructure(i).gas(j).confusions.val,~,~] = confusion(y_val,savestructure(i).gas(j).class.val);
        [~,savestructure(i).gas(j).confusions.train,~,~] = confusion(y_train,savestructure(i).gas(j).class.train);
        
        dbgmsg(num2str(i),'-th set.',savestructure(i).gas(j).name,' Confusion matrix on this validation set:',writedownmatrix(savestructure(i).gas(j).confusions.val),1)
        savestructure(i).gas(j).fig = {y_val,                   savestructure(i).gas(j).class.val,  strcat(savestructure(i).gas(j).method,' Val ', num2str(savestructure(i).maxnodes)),...
                                       y_train,savestructure(i).gas(j).class.train,strcat(savestructure(i).gas(j).method,'Train ', num2str(savestructure(i).maxnodes))}; %difficult to debug line, sorry. if it doesn't work, weep.
        savestructure(i).figset = {savestructure(i).figset{:}, savestructure(i).gas(j).fig{:}};
    end
end

%% Actual display of the confusion matrices:
for i = 1:length(savestructure)
 plotconfusion(savestructure(i).figset{:})
 figure
end
% plotconfusion(ones(size(y_val)),y_val, 'always guess "it''s a fall" on Validation Set:',zeros(size(y_val)),y_val, 'always guess "it''s NOT a fall" on Validation Set:')
% clear i
%% Calculate my own measures over the matrices
% TO DO: This is bad. I should probably read the confusion documentation instead of doing this
% manually
for j = whatIlabel %this is weird, but I just changed this to show only the last gas
    f1 = howgood(savestructure,j);
    dbgmsg(savestructure(1).gas(j).name,'F1 for validation overall mean:', num2str(f1(1)),'||','F1 for training overall mean:', num2str(f1(2)),1)
    disp(f1(1))
    f1 = whoisbest(savestructure,j);
    dbgmsg(savestructure(1).gas(j).name,'F1 for validation best:', num2str(f1(1)),'||','F1 for training best:', num2str(f1(2)),1)
    disp(f1(1))
end
