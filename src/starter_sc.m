function [savestructure, metrics] = starter_sc(data, allconn, P)

PLOTIT = true;
data_val = data.val;
data_train = data.train;
y_val = data.y.val;
y_train = data.y.train;
ends_train = data.ends.train;
ends_val = data.ends.val;


%% starter_script
% This is the main function to run the chained classifier, label and generate
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
%%% making metrics structure

metrics = struct('confusions',[],'conffig',[],'outparams',[]);
%%%% building arq_connect
arq_connect(1:length(allconn)) = struct('name','','method','','sourcelayer','', 'layertype','','q',[1 0],'params',struct());
for i = 1:length(allconn)
    arq_connect(i).name = allconn{i}{1};
    arq_connect(i).method = allconn{i}{2};
    arq_connect(i).sourcelayer = allconn{i}{3};
    arq_connect(i).layertype = allconn{i}{4};
    arq_connect(i).q = allconn{i}{5};
    arq_connect(i).params = allconn{i}{6};
    %%% hack I need this info in params as well
    arq_connect(i).params.q = arq_connect(i).q;
end
inputs = struct('input_clip',[],'input',[],'input_ends',[],'oldwhotokill',{}, 'index', {});
gas_data = struct('name','','class',[],'y',[],'inputs',inputs,'bestmatch',[],'bestmatchbyindex',[],'whotokill',{});
gas_methods(1:length(arq_connect)) = struct('name','','edges',[],'nodes',[],'fig',[],'nodesl',[]); %bestmatch will have the training matrix for subsequent layers
vt_data = struct('indexes',[],'data',[],'ends',[],'gas',gas_data);
savestructure(1:P) = struct('maxnodes',[], 'gas', gas_methods, 'train',vt_data,'val',vt_data,'figset',[]); % I have a problem with figset. I don't kno
for i = 1:length(savestructure) % oh, I don't know how to do it elegantly
    savestructure(i).figset = {};
end

%%% end of gas structures region


%% Gas-chain Classifier
% This part executes the chain of interlinked gases. Each iteration is one
% gas, and currently it works as follows:
% 1. Function setinput() chooses based on the input defined in allconn
% 2. Run either a Growing When Required (gwr) or Growing Neural Gas (GNG)
% on this data
% 3. Generate matrix of best matching units to be used by the next gas
% architecture

dbgmsg('Starting chain structure for GWR and GNG for nodes:',num2str(P),1)
dbgmsg('###Using multilayer GWR and GNG ###',1)

for i = 1:P
    %[savestructure(i).train.data, savestructure(i).train.indexes] =
    %shuffledataftw(data_train); % I cant shuffle any longer...
    %but I still need to assign it !
    savestructure(i).train.data = data_train;
    savestructure(i).train.ends = ends_train;
    savestructure(i).train.y = y_train;
    
    for j = 1:length(arq_connect)
        savestructure(i) = gas_method(savestructure(i), arq_connect(j), i,j, size(data_train,1)); % I had to separate it to debug it.
        metrics(i,j).outparams = savestructure(i).gas(j).outparams;
    end
    
end
%% Gas Outcomes
% This should be made into a function... It is a nice graph to perhaps
% debug the gas...
if 1% PLOTIT
    for i = 1:length(savestructure)
        figure
        for j = 1:length(arq_connect)
            subplot (1,length(arq_connect),j)
            hist(savestructure(i).gas(j).outparams.graph.errorvect)
            title((savestructure(i).gas(j).name))
        end        
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
dbgmsg('Labelling',num2str(P),1)

whatIlabel = 1:length(savestructure(1).gas); %change this series for only the last value to label only the last gas

for i=1:length(savestructure)
    savestructure(i).val.data = data_val;
    savestructure(i).val.ends = ends_val;
    savestructure(i).val.y = y_val;
    %%
    % Concatenating the inputs to be labelled (has to be done on all layers:
    for j =  1:length(arq_connect)
        %labeling
        %pretty much useless unless it is the last layer, but I can label
        %everyone, so I will.
        savestructure(i).train.gas(j).name = arq_connect(j).name;
        savestructure(i).val.gas(j).name = arq_connect(j).name;
        
        dbgmsg('Setting validation input (and clipping output) for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [~, savestructure(i).val.gas(j).inputs.input, savestructure(i).val.gas(j).inputs.input_ends, savestructure(i).val.gas(j).y, ~, savestructure.val.gas(j).inputs.index, savestructure.val.gas(j).inputs.awk]  = setinput(arq_connect(j), savestructure(i), size(data_train,1), savestructure(i).val);
       
        % I didn't realize, but I need to do this for the validation
        % dataset as well.
        dbgmsg('Finding best matching units for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [~, savestructure(i).val.gas(j).bestmatchbyindex] = genbestmmatrix(savestructure(i).gas(j).nodes, savestructure(i).val.gas(j).inputs.input, arq_connect(j).layertype, arq_connect(j).q); %assuming the best matching node always comes from initial dataset!
    end
    %%
    % Specific part on what I want to label
    for j = whatIlabel
        dbgmsg('Applying labels for gas: ''',savestructure(i).gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [savestructure(i).train.gas(j).class, savestructure(i).val.gas(j).class,savestructure(i).gas(j).nodesl ] = labeller(savestructure(i).gas(j).nodes, savestructure(i).train.gas(j).bestmatchbyindex,  savestructure(i).val.gas(j).bestmatchbyindex, savestructure(i).train.gas(j).inputs.input, savestructure(i).train.gas(j).y);
        %%%% I dont understand what I did, so I will code this again.
        %%% why did I write .bestmatch when it should be nodes??? what was I thinnking [savestructure(i).train.gas(j).class, savestructure(i).val.gas(j).class] = untitled6(savestructure(i).gas(j).bestmatch, savestructure(i).train.gas(j).inputs.input,savestructure(i).val.gas(j).inputs.input, y_train);
        
    end
end

%% Displaying multiple confusion matrices for GWR and GNG for nodes
% This part creates the matrices that can later be shown with the
% plotconfusion() function.
for i =1:length(savestructure)
    savestructure(i).figset = {}; %% you should clear the set first if you want to rebuild them
    dbgmsg('Displaying multiple confusion matrices for GWR and GNG for nodes:',num2str(P),1)
end
for i=1:length(savestructure)
    for j = whatIlabel
        [~,metrics(i,j).confusions.val,~,~] = confusion(savestructure(i).val.gas(j).y,savestructure(i).val.gas(j).class);
        [~,metrics(i,j).confusions.train,~,~] = confusion(savestructure(i).train.gas(j).y,savestructure(i).train.gas(j).class);
        
        dbgmsg(num2str(i),'-th set.',savestructure(i).gas(j).name,' Confusion matrix on this validation set:',writedownmatrix(metrics(i,j).confusions.val),1)
        savestructure(i).gas(j).fig.val =   {savestructure(i).val.gas(j).y,     savestructure(i).val.gas(j).class,  strcat(savestructure(i).gas(j).name,savestructure(i).gas(j).method,'V', num2str(savestructure(i).maxnodes))};
        savestructure(i).gas(j).fig.train = {savestructure(i).train.gas(j).y,   savestructure(i).train.gas(j).class,strcat(savestructure(i).gas(j).name,savestructure(i).gas(j).method,'T', num2str(savestructure(i).maxnodes))}; 
        savestructure(i).figset = [savestructure(i).figset, savestructure(i).gas(j).fig.val, savestructure(i).gas(j).fig.train];
        %%%
        metrics(i,j).conffig = savestructure(i).gas(j).fig;
    end
end

%% Actual display of the confusion matrices:
if PLOTIT
    for i = 1:length(savestructure)
        figure
        plotconfusion(savestructure(i).figset{:})
        figure 
        plotconfusion(savestructure(i).gas(end).fig.val{:})
    end    
end
% plotconfusion(ones(size(y_val)),y_val, 'always guess "it''s a fall" on Validation Set:',zeros(size(y_val)),y_val, 'always guess "it''s NOT a fall" on Validation Set:')
% clear i
% %% Calculate my own measures over the matrices
% % TO DO: This is bad. I should probably read the confusion documentation instead of doing this
% % manually
% for j = whatIlabel %this is weird, but I just changed this to show only the last gas
%     metrics = howgood(savestructure,j);
%     dbgmsg(savestructure(1).gas(j).name,'\t [All data for Validation set] Sensitivity/Recall overall mean:\t', num2str(metrics(1)),'%%\t|| Specificity overall mean:\t', num2str(metrics(2)),'%%\t|| Precision overall mean:\t', num2str(metrics(3)),'%%\t|| F1 overall mean:\t', num2str(metrics(4)),'%%',1)
%     metrics = whoisbest(savestructure,j);
%     dbgmsg(savestructure(1).gas(j).name,'\t [All data for Validation set] Best Sensitivity/Recall:        \t', num2str(metrics(1)),'%%\t|| Best Specificity:        \t', num2str(metrics(2)),'%%\t|| Best Precision:        \t', num2str(metrics(3)),'%%\t|| Best F1:       \t', num2str(metrics(4)),'%%',1)
% end
end
function savestructure = gas_method(savestructure, arq_connect, i,j, dimdim)
%% Gas Method
% This is a function to go over a gas of the classifier, populate it with the apropriate input and generate the best matching units for the next layer.  
%% Setting up some labels
        savestructure.gas(j).name = arq_connect.name;
        savestructure.gas(j).method = arq_connect.method;
        savestructure.gas(j).layertype = arq_connect.layertype;
        arq_connect.params.layertype = arq_connect.layertype;
        
%% Choosing the right input for this layer
% This calls the function set input that chooses what will be written on the .inputs variable. It also handles the sliding window concatenations and saves the .input_ends properties, so that this can be done recursevely. 
% After some consideration, I have decided that all of the long inputing
% will be done inside setinput, because it it would be easier. 

        [savestructure.train.gas(j).inputs.input_clip, savestructure.train.gas(j).inputs.input, savestructure.train.gas(j).inputs.input_ends, savestructure.train.gas(j).y, savestructure.train.gas(j).inputs.oldwhotokill, savestructure.train.gas(j).inputs.index, savestructure.train.gas(j).inputs.awk ]  = setinput(arq_connect, savestructure, dimdim, savestructure.train); %%%%%%
  
%% 
% After setting the input, we can actually run the gas, either a GNG or the
% GWR function we wrote.
        %%%% PRE-MESSAGE
        dbgmsg('Working on gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with method: ',savestructure.gas(j).method ,' for process:',num2str(labindex),1)
        %DO GNG OR GWR

        [savestructure.gas(j).nodes, savestructure.gas(j).edges, savestructure.gas(j).outparams] = gas_wrapper(savestructure.train.gas(j).inputs.input_clip,arq_connect); 

        %%%% POS-MESSAGE
        dbgmsg('Finished working on gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with method: ',savestructure.gas(j).method ,'.Num of nodes reached:',num2str(savestructure.gas(j).outparams.graph.nodesvect(end)),' for process:',num2str(i),1)
        %%%% FIND BESTMATCHING UNITS
        
%% Best-matching units
% The last part is actually finding the best matching units for the gas.
% This is a simple procedure where we just find from the gas units (nodes
% or vectors, as you wish to call them), which one is more like our input.
% It is a filter of sorts, and the bestmatch matrix is highly repetitive. 

% I questioned if I actually need to compute this matrix here or maybe
% inside the setinput function. But I think this doesnt really matter.
% Well, for the last gas it does make a difference, since these units will
% not be used... Still I will  not fix it unless I have to.
        %PRE MESSAGE  
        dbgmsg('Finding best matching units for gas: ''',savestructure.gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [~, savestructure.train.gas(j).bestmatchbyindex] = genbestmmatrix(savestructure.gas(j).nodes, savestructure.train.gas(j).inputs.input, arq_connect.layertype, arq_connect.q); %assuming the best matching node always comes from initial dataset!
        
%% Post-conditioning function
%This will be the noise removing function. I want this to be optional or allow other things to be done to the data and I
%am still thinking about how to do it. Right now I will just create the
%whattokill property and let setinput deal with it. 
        dbgmsg('Flagging noisy input for removal from gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with points with more than',num2str(arq_connect.params.gamma),' standard deviations, for process:',num2str(i),1)
        savestructure.train.gas(j).whotokill = removenoise(savestructure.gas(j).nodes, savestructure.train.gas(j).inputs.input, savestructure.train.gas(j).inputs.oldwhotokill, arq_connect.params.gamma, savestructure.train.gas(j).inputs.index);
end