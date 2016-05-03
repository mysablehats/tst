fclose('all');
clear all;
close all;

%% Generate Skeletons
% This makes a new dataset, so results will be no longer comparable.
% datasettypes are 'CAD60', 'tstv2' and 'stickman'
datasettype = 'tstv2';
%%
% It is possible to input who you want to be on the training and validation
%set using the variables below. The numbers are either the subject number
%for 'type2' "samplingtype" or activity count for 'type1'. It is actually
%not a sampling type, but the way you divide the sets. I could not find a
%better name for it. 
sampling_type = 'type2';
%%
% You can select from either 'act_type' or 'act' to choose if the you want
% classes of actions or each action to be classified. This is an
% unsupervised method, so this can only improve the classification on a
% smaller number of classes.
activity_type = 'act';
%%
%You can pass the variables allskeli1 and allskeli2 to generate_skel_data,
%if you want to generate a specific set of training and validation data
%respectively, by uncommenting the following lines and the the gen... line.
%allskeli1 = [9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
%allskeli2 = [1,2,7];%% comment these out to have random new samples
[allskel1, allskel2, allskeli1, allskeli2] = generate_skel_data(datasettype, sampling_type); %, allskeli1, allskeli2); 

%%
% conformactions is here to enable some preprocessing on the data while it
% is still on a structure form, that is, separated into actions. This is
% necessary to apply filters on the data, since after they are put into a
% sequential form, doing this would merge skeletons together. 
[allskel1, allskel2] = conformactions(allskel1,allskel2, 'filter');

aa_environment
%%
%extractdata actually generates the long matrices to train the algorithm.
%They are generated in a way that you can use nnstart to classify them and
%evaluated how much better (or worse) a neural network can separate these
%datasets.
labels_names = []; 
[~, data_train,y_train, ends_train, labels_names] = extractdata(allskel1, activity_type, labels_names);
[~, data_val,y_val, ends_val, labels_names] = extractdata(allskel2, activity_type, labels_names);
traindataname = strcat(wheretosavestuff,SLASH,datasettype,'_skel_');
valdataname = strcat(wheretosavestuff,SLASH,datasettype,'_skel_val_');

save(traindataname,'data_train','labels_names', 'y_train','allskeli1','ends_train','-v7.3');
dbgmsg('Training data saved.')
save(valdataname,'data_val','labels_names', 'y_val','allskeli2','ends_val','-v7.3');
dbgmsg('Validation data saved.')

%clear all
dbgmsg('Skeleton data (training and validation) generated.')
% %%validation and training set


%%%% Loads environment Variables and saved Data

%%%load_skel_data
%% Awk definition:
important = 1;%0.1;
relevant = 1;%0.03;
minor = 1;%0.005;

awk = [...
    important;...   %1    hips
    important;...   %2    abdomen
    important;...   %3    neck or something
    relevant;...    %4    tip of the head
    important;...   %5    right shoulder
    relevant;...    %6    right also shoulder or elbow
    relevant;...    %7    right elbow maybe
    relevant;...    %8    right hand
    important;...   %9    left part of shoulder
    relevant;...    %10   left something maybe elbow
    relevant;...    %11   left maybe elbow
    relevant;...    %12   left hand
    important;...   %13   left hip
    relevant;...    %14   left knee
    minor;...       %15   left part of foot
    minor;...       %16   left tip of foot
    important;...   %17   right hip %important because hips dont lie
    relevant;...    %18   right knee
    minor;...       %19   right part of foot
    minor;...       %20   right tip of foot
    important;...   %21   middle of upper torax
    minor;...       %22   right some part of the hand
    minor;...       %23   right some other part of the hand
    minor;...       %24   left some part of the hand
    minor];         %25   left some other part of the hand

if size(awk,1)*6~=size(data_val,1)
    awk = ones(size(data_val,1)/6,1);
    dbgmsg('Must update awk for this a skeleton this size.',1)
end

%% Pre-conditioning of data
% 

 [data_train_, data_val_, ~] = conformskel(data_train, data_val, awk,'highhips','nofeet', 'spherical');
 [data_train_mirror, data_val_mirror, skelldef] = conformskel(data_train, data_val, awk,'mirrorx','highhips','nofeet', 'spherical');
%[data_train_, data_val_, ~] = conformskel(data_train, data_val, awk,'nohips','nofeet');
%[data_train_mirror, data_val_mirror, skelldef] = conformskel(data_train, data_val, awk,'mirror');

%% writing data structure
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

%%% this is a bad place to apply the filter because it will merge different
%%% actions together!
% a = 1;
% windowSize = 1;
% b = (1/windowSize)*ones(1,windowSize);
% 
% data_train = medfilt1(data_train,3);
% data_val = medfilt1(data_val,3);



%% Setting up runtime variables
TEST = 0; % set to false to actually run it
PARA = 1;

P = 4;

NODES = 2;

if TEST
    NODES = 2;
end

params.removepoints = false;
params.PLOTIT = false;
params.RANDOMSTART = false; % if true it overrides the .startingpoint variable
params.RANDOMSET = true; % if true, each sample (either alone or sliding window concatenated sample) will be presented to the gas at random
params.savegas.resume = true; % if true, it will see if it can find an old gas from the same dataset and same parameters from before and use it as a starting point for learning. Enables you to resume learning in case there is a computer crash.
params.savegas.path = wheretosavestuff;

n = randperm(size(data_train,2),2);
params.startingpoint = [n(1) n(2)];

params.amax = 50; %greatest allowed age
params.nodes = NODES; %maximum number of nodes/neurons in the gas
params.en = 0.006; %epsilon subscript n
params.eb = 0.2; %epsilon subscript b
params.gamma = 4; % for the denoising function
params.skelldef = skelldef;
params.plottingstep = 100; % zero will make it plot only the end-gas
params.MAX_EPOCHS = 50; 

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
% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
%     {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
%     {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}};

% 
% allconn = {...
%      {'gng1layer',   'gng',{'pos'},                    'pos',[1 0],params}...
%      {'gng2layer',   'gng',{'vel'},                    'vel',[1 0],params}...
%      {'gng3layer',   'gng',{'gng1layer'},              'pos',[3 0],params}...
%      {'gng4layer',   'gng',{'gng2layer'},              'vel',[3 0],params}...
%      {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',[3 0],params}};
% 
% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 2 3],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 2 3],params}...
%     {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
%     {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}};


% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
%     {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 0],params}...
%     {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 0],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 0],params}};
% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[3 2],params}};

% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[3 0],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[3 0],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[1 0],params}};
allconn = {...
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[3 4 2],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[3 4 2],params}...
    {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[3 2],params}};
%  allconn = {...
%      {'gwr1layer',   'gwr',{'pos'},                    'pos',3,params}...
%      {'gwr2layer',   'gwr',{'vel'},                    'vel',3,params}...
%      {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3,params}...
%      {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3,params}...
%      {'gwr5layer',   'gwr',{'gwr3layer'},              'pos',3,params}...
%      {'gwr6layer',   'gwr',{'gwr4layer'},              'vel',3,params}...
%      {'gwrSTSlayer', 'gwr',{'gwr6layer','gwr5layer'},  'all',3,params}};

% allconn = {...
%      {'gng1layer',   'gng',{'pos'},                    'pos',1,params}...
%      {'gng2layer',   'gng',{'vel'},                    'vel',1,params}...
%      {'gng3layer',   'gng',{'gng1layer'},              'pos',3,params}...
%      {'gng4layer',   'gng',{'gng2layer'},              'vel',3,params}...
%      {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',3,params}};

%  allconn = {...
%      {'gwr1layer',   'gwr',{'pos'},                    'pos',3,params}...
%      {'gwr2layer',   'gwr',{'vel'},                    'vel',3,params}...
%      {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3,params}...
%      {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3,params}...
%      {'gwr5layer',   'gwr',{'gwr3layer'},              'pos',3,params}...
%      {'gwr6layer',   'gwr',{'gwr4layer'},              'vel',3,params}...
%      {'gwrSTSlayer', 'gwr',{'gwr6layer','gwr5layer'},  'all',3,params}}; 
%  
%  allconn = {...
%         {'gwr1layer',   'gwr',{'pos'},                    'all',[3 2], params}... %% now there is a vector where q used to be, because we have the p overlap variable...
%         {'gwr2layer',   'gwr',{'gwr1layer'},              'all',[3 2], params}...
%         };
%   allconn = {{'gwr1layer',   'gwr',{'pos'},                    'pos',[3 2], params}... %% now there is a vector where q used to be, because we have the p overlap variable...
%            };
%        


%%  Pre gas conditioning


%% Pos gas conditioning




%%
for i = 1:P
    paramsZ(i) = params;
end


clear a

%a(1:P) = struct();%'best',[0 0 0],'mt',[0 0 0 0], 'bestmtallconn',struct('sensitivity',struct(),'specificity',struct(),'precision',struct()));
b = [];
starttime = tic;
if ~TEST 
while toc(starttime)<1%3600*8
if PARA
    for j = 1:1
        spmd(P)
            a = executioncore_in_starterscript(paramsZ(labindex),allconn, data);
        end
%         save('shithead.mat','a')
        %b = cat(2,b,a.a);
        %b(1:P) = struct();
        %count = length(b);
        b = [a{:} b];
%         for i=length(a)+count:-1:1+count
%             c = a{i};
%             a{i} = [];
%             b(i) = c.a.mt;
%         end
%         clear a c
%         a(1:P) = struct();
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
    executioncore_in_starterscript(paramsZ(1),allconn, data);
end
savevar = strcat('b',num2str(NODES),'_', num2str(params.MAX_EPOCHS),'epochs',num2str(size(b,2)),removepoints_str, sampling_type, datasettype, activity_type);
eval(strcat(savevar,'=b;'))
clear b
save(strcat(wheretosavestuff,SLASH,savevar,'.mat'),savevar)