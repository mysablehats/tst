function trialid = starter_script()
% fclose('all');
% clear all;
% close all;

aa_environment % load environment variables

%%%% STARTING MESSAGES PART FOR THIS RUN
global VERBOSE LOGIT
VERBOSE = true;
LOGIT = true;
dbgmsg('=======================================================================================================================================================================================================================================')
dbgmsg('Running starter script')
dbgmsg('=======================================================================================================================================================================================================================================')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Each trial is trained on freshly partitioned/ generated data, so that we
% have an unbiased understanding of how the chained-gas is classifying.
%
% They are generated in a way that you can use nnstart to classify them and
% evaluated how much better (or worse) a neural network or some other
% algorithm can separate these datasets. Also, the data for each action
% example has different length, so the partition of datapoints is not
% equitative (there will be some fluctuation in the performance of putting
% every case in one single bin) and it will not be the same in validation
% and training sets. So in case this is annoying to you and you want to run
% always with a similar dataset, set
% generatenewdataset = false
generatenewdataset = true;

%% Choose dataset
% datasettypes are 'CAD60', 'tstv2' and 'stickman'
datasettype = 'tstv2';
%%
% It is possible to input who you want to be on the training and
% validation
%set using the variables below. The numbers are either the subject
%number for 'type2' "samplingtype" or activity count for 'type1'. It is
%actually not a sampling type, but the way you divide the sets. I could
%not find a better name for it.
sampling_type = 'type2';
%%
% You can select from either 'act_type' or 'act' to choose if the you
% want classes of actions or each action to be classified. This is an
% unsupervised method, so this can only improve the classification on a
% smaller number of classes.
activity_type = 'act';
%%
% conformactions is here to enable some preprocessing on the data while
% it is still on a structure form, that is, separated into actions.
% This is necessary to apply filters on the data, since after they are
% put into a sequential form, doing this would merge skeletons
% together.
%
% 'filter', 'none', 'median?'
prefilter = 'none';
%%
combname = strcat(datasettype,'_',sampling_type,activity_type,'_',prefilter,'_skel_');
traindataname = strcat(wheretosavestuff,SLASH,combname);
valdataname = strcat(wheretosavestuff,SLASH,combname,'val_');
% if you want to save plot graphs and other information, set saveb = true;
saveb = true;
nodatayet = true;
while(nodatayet)
    if generatenewdataset
        %% Generate Skeletons
        % This makes a new dataset, so results will be no longer comparable.
        %%
        %You can pass the variables allskeli1 and allskeli2 to generate_skel_data,
        %if you want to generate a specific set of training and validation data
        %respectively, by uncommenting the following lines and the the gen... line.
        %allskeli1 = [9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
        %allskeli2 = [1,2,7];%% comment these out to have random new samples
        [allskel1, allskel2, allskeli1, allskeli2] = generate_skel_data(datasettype, sampling_type); %, allskeli1, allskeli2);
        
        %%
        % the place to apply the prefilter is here.
        [allskel1, allskel2] = conformactions(allskel1,allskel2, prefilter);
        %%
        % extractdata actually generates the long matrices to train the
        % algorithm. creates long data matrices from the data structures and
        % save them for future use. Load these with load_skel_data
        
        labels_names = []; % necessary so that same actions keep their order number
        [~, data_train,y_train, ends_train, labels_names] = extractdata(allskel1, activity_type, labels_names);
        [~, data_val,y_val, ends_val, labels_names] = extractdata(allskel2, activity_type, labels_names);
        
        
        save(traindataname,'data_train','labels_names', 'y_train','allskeli1','ends_train','datasettype', 'sampling_type',  'activity_type', 'prefilter','-v7.3');
        dbgmsg('Training data saved.')
        save(valdataname,'data_val','labels_names', 'y_val','allskeli2','ends_val','datasettype', 'sampling_type',  'activity_type', 'prefilter','-v7.3');
        dbgmsg('Validation data saved.')
        
        %clear all
        dbgmsg('Skeleton data (training and validation) generated.')
        nodatayet = false;
        % %%validation and training set
        
    else
        %%%% Loads environment Variables and saved Data
        try
            load(traindataname)
            load(valdataname)
            nodatayet = false;
        catch
            dbgmsg('There is no data on the specified location. Will generate new dataset.',1)
            generatenewdataset = true;
        end
    end
end
%% Pre-conditioning of data
%
preconditions = {'highhips', 'normal', 'intostick2'};
[data_train_, data_val_, ~] = conformskel(data_train, data_val,preconditions{:});
[data_train_mirror, data_val_mirror, skelldef] = conformskel(data_train, data_val,'mirrorx',preconditions{:});

%% writing data structure
% interrupt here to test other algorithms with preprocessed data, why? For
% instance to evaluate if the classifier is the preprocessing or the gas.

%%% TODO put this function inside conformskel and remove the need for
%%% double lines and this ugly concatenation outside!

data.train = [data_train_, data_train_mirror];
data.ends.train = [ends_train, ends_train];
data.val = [data_val_, data_val_mirror];
data.ends.val = [ends_val, ends_val];
data.y.train = [y_train y_train];
data.y.val = [y_val y_val];

% %%
% data.val = data_val;
% data.train = data_train;
% data.y.val = y_val;
% data.y.train = y_train;
% data.ends.train = ends_train;
% data.ends.val = ends_val;
%

%% Setting up runtime variables
TEST = 0; % set to false to actually run it
PARA = 1;

% P = 4;
%
% NODES_VECT = [3 ];
% MAX_EPOCHS_VECT = [1];
% ARCH_VECT = [1 ];
% MAX_NUM_TRIALS = 1;
% MAX_RUNNING_TIME = 1; %%% in seconds, will stop after this

P = 4;

NODES_VECT = [100];
MAX_EPOCHS_VECT = [1 3];
ARCH_VECT = [1 3];
MAX_NUM_TRIALS = 56;
MAX_RUNNING_TIME = 3600*10; %%% in seconds, will stop after this


for architectures = ARCH_VECT
    for NODES = NODES_VECT
        for MAX_EPOCHS = MAX_EPOCHS_VECT
            if NODES ==100000 && (MAX_EPOCHS==1||MAX_EPOCHS==1)
                dbgmsg('Did this already',1)
                break
            end
            params.MAX_EPOCHS = MAX_EPOCHS;
            
            params.removepoints = true;
            params.PLOTIT = false;
            params.RANDOMSTART = true; % if true it overrides the .startingpoint variable
            params.RANDOMSET = false; % if true, each sample (either alone or sliding window concatenated sample) will be presented to the gas at random
            params.savegas.resume = false; % do not set to true. not working
            params.savegas.save = false;
            params.savegas.path = wheretosavestuff;
            params.savegas.parallelgases = true;
            params.savegas.parallelgasescount = 0;
            params.savegas.accurate_track_epochs = true;
            params.savegas.P = P;
            
            n = randperm(size(data_train,2),2);
            params.startingpoint = [n(1) n(2)];
            
            params.amax = 50; %greatest allowed age
            params.nodes = NODES; %maximum number of nodes/neurons in the gas
            params.en = 0.006; %epsilon subscript n
            params.eb = 0.2; %epsilon subscript b
            params.gamma = 4; % for the denoising function
            params.skelldef = skelldef;
            params.plottingstep = 0; % zero will make it plot only the end-gas
            
            %Exclusive for gwr
            params.STATIC = true;
            params.at = 0.95; %activity threshold
            params.h0 = 1;
            params.ab = 0.95;
            params.an = 0.95;
            params.tb = 3.33;
            params.tn = 3.33;
            
            %Exclusive for gng
            params.age_inc                  = 1;
            params.lambda                   = 3;
            params.alpha                    = .5;     % q and f units error reduction constant.
            params.d                           = .99;   % Error reduction factor.
            %Just so that I can name the b_?? variable accurately
            if params.removepoints
                removepoints_str = strcat('rem',num2str(params.gamma),'sig');
            else
                removepoints_str = '';
            end
            %% Classifier structure definitions
            % This is the basic network
            %%%% gas structures region
            
            %%%% connection definitions:
            
            
            %%%% to allow cross comparison of multiple different layered
            %%%% structures, this was moved into a function.
            allconn = allconnset(architectures, params);
            
            %         allconn = {...
            %             {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
            %             {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
            %             {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
            %             {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
            %             {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}};
            
            
            %%  Pre gas conditioning
            
            
            %% Pos gas conditioning
            
            
            
            
            %%
            for i = 1:P
                paramsZ(i) = params;
            end
            
            
            clear a
            
            %a(1:P) = struct();%'best',[0 0 0],'mt',[0 0 0 0], 'bestmtallconn',struct('sensitivity',struct(),'specificity',struct(),'precision',struct()));
            b = [];
            
            if ~TEST
                starttime = tic;
                while toc(starttime)< MAX_RUNNING_TIME
                    if length(b)> MAX_NUM_TRIALS
                        break
                    end
                    if PARA
                        for j = 1:1
                            spmd(P)
                                a(labindex).a = executioncore_in_starterscript(paramsZ(labindex),allconn, data);
                            end
                            %b = cat(2,b,a.a);
                            for i=1:length(a)
                                c = a{i};
                                a{i} = [];
                                b = [c.a b];
                            end
                            clear a c
                            a(1:P) = struct();
                        end
                        
                    else
                        for j = 1:1
                            for i = 1:P
                                a(i).a = executioncore_in_starterscript(paramsZ(i),allconn, data);
                            end
                            b = cat(2,b,a.a);
                            clear a
                            a(1:P) = struct();
                        end
                    end
                end
            else
                b = executioncore_in_starterscript(paramsZ(1),allconn, data);
            end
            cstfilename=strcat(wheretosavestuff,SLASH,'cst.mat');
            if exist(cstfilename,'file')
                load(cstfilename,'cst')
            end
            gen_cst
            save(strcat(wheretosavestuff,SLASH,'cst.mat'),'cst')
            trialid = cst(end);
            if saveb
                savevar = strcat('b',num2str(NODES),'_', num2str(params.MAX_EPOCHS),'epochs',num2str(size(b,2)),removepoints_str, sampling_type, datasettype, activity_type);
                eval(strcat(savevar,'=trialid;'))
                savesave = strcat(wheretosavestuff,SLASH,savevar,'.mat');
                ver = 1;
                while exist(savesave,'file')
                    savesave = strcat(wheretosavestuff,SLASH,savevar,'ver(',num2str(ver),').mat');
                    ver = ver+1;
                end
                save(savesave,savevar, 'cst')
            end
            clear b
            clock
        end
    end
end
end
function allconn = allconnset(n, params)
allconn_set = {...
    {... %%%% ARCHITECTURE 1
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
    {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
    {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
    {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}...
    }...
    {...%%%% ARCHITECTURE 2
    {'gng1layer',   'gng',{'pos'},                    'pos',[1 0],params}...
    {'gng2layer',   'gng',{'vel'},                    'vel',[1 0],params}...
    {'gng3layer',   'gng',{'gng1layer'},              'pos',[3 2],params}...
    {'gng4layer',   'gng',{'gng2layer'},              'vel',[3 2],params}...
    {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',[3 2],params}...
    }...
    {...%%%% ARCHITECTURE 3
    {'gng1layer',   'gng',{'pos'},                    'pos',[1 0],params}...
    {'gng2layer',   'gng',{'vel'},                    'vel',[1 0],params}...
    {'gng3layer',   'gng',{'gng1layer'},              'pos',[3 0],params}...
    {'gng4layer',   'gng',{'gng2layer'},              'vel',[3 0],params}...
    {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',[3 0],params}...
    }...
    {...%%%% ARCHITECTURE 4
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
    {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 0],params}...
    {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 0],params}...
    {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 0],params}...
    }...
    {...%%%% ARCHITECTURE 5
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 2 3],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 2 3],params}...
    {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
    {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
    {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}...
    }...
    {...%%%% ARCHITECTURE 6
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[3 4 2],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[3 4 2],params}...
    {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[3 2],params}...
    }...
    {...%%%% ARCHITECTURE 7
    {'gwr1layer',   'gwr',{'all'},                    'all',[3 2], params}...
    {'gwr2layer',   'gwr',{'gwr1layer'},              'all',[3 2], params}...
    }...
    {...%%%% ARCHITECTURE 8
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[3 2], params}... %% now there is a vector where q used to be, because we have the p overlap variable...
    }...
    {...%%%% ARCHITECTURE 9
    {'gwr1layer',   'gwr',{'pos'},                    'pos',3,params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',3,params}...
    {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3,params}...
    {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3,params}...
    {'gwr5layer',   'gwr',{'gwr3layer'},              'pos',3,params}...
    {'gwr6layer',   'gwr',{'gwr4layer'},              'vel',3,params}...
    {'gwrSTSlayer', 'gwr',{'gwr6layer','gwr5layer'},  'all',3,params}
    }...
    {... %%%% ARCHITECTURE 10
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
    {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[3 2],params}...
    }...
    };
allconn = allconn_set{n};
end
function a = executioncore_in_starterscript(paramsZ,allconn, data)
n = randperm(size(data.train,2)-3,2); % -(q-1) necessary because concatenation reduces the data size!
paramsZ.startingpoint = [n(1) n(2)];
pallconn = allconn;
pallconn{1,1}{1,6} = paramsZ; % I only change the initial points of the position gas
%pallconn{1,3}{1,6} = paramsZ; %but I want the concatenation to reflect the same position that I randomized. actually this is not going to happen because of the sliding window scheme
%pallconn{1,4}{1,6} = pallconn{1,2}{1,6};

%[a.sv, a.mt] = starter_sc(data, pallconn, 1);
[~, a.mt] = starter_sc(data, pallconn, 1);

end
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
dbgmsg('ENTERING MAIN LOOP')
% dbgmsg('=======================================================================================================================================================================================================================================')
% dbgmsg('Running starter script')
% dbgmsg('=======================================================================================================================================================================================================================================')
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
        savestructure(i) = gas_method(savestructure(i), arq_connect(j),j, size(data_train,1)); % I had to separate it to debug it.
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
        %savestructure(i).figset = [savestructure(i).figset, savestructure(i).gas(j).fig.val, savestructure(i).gas(j).fig.train];
        %%%
        metrics(i,j).conffig = savestructure(i).gas(j).fig;
    end
end

%% Actual display of the confusion matrices:
if PLOTIT
    for i = 1:length(savestructure)
        figure
        plotconf([metrics(i,:)])
        %plotconf(savestructure(i).figset{:})
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
function savestructure = gas_method(savestructure, arq_connect,j, dimdim)
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
dbgmsg('Finished working on gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with method: ',savestructure.gas(j).method ,'.Num of nodes reached:',num2str(savestructure.gas(j).outparams.graph.nodesvect(end)),' for process:',num2str(labindex),1)
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
dbgmsg('Finding best matching units for gas: ''',savestructure.gas(j).name,''' (', num2str(j),') for process:',num2str(labindex),1)
[~, savestructure.train.gas(j).bestmatchbyindex] = genbestmmatrix(savestructure.gas(j).nodes, savestructure.train.gas(j).inputs.input, arq_connect.layertype, arq_connect.q); %assuming the best matching node always comes from initial dataset!

%% Post-conditioning function
%This will be the noise removing function. I want this to be optional or allow other things to be done to the data and I
%am still thinking about how to do it. Right now I will just create the
%whattokill property and let setinput deal with it.
if arq_connect.params.removepoints
    dbgmsg('Flagging noisy input for removal from gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with points with more than',num2str(arq_connect.params.gamma),' standard deviations, for process:',num2str(labindex),1)
    savestructure.train.gas(j).whotokill = removenoise(savestructure.gas(j).nodes, savestructure.train.gas(j).inputs.input, savestructure.train.gas(j).inputs.oldwhotokill, arq_connect.params.gamma, savestructure.train.gas(j).inputs.index);
else
    dbgmsg('Skipping removal of noisy input for gas:',savestructure.gas(j).name)
end
end
