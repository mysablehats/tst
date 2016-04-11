fclose('all');
clear all;
close all;

%% Generate Skeletons
% This takes quite a while to execute, so I rarely run it. 
%%% >>>>> this has to be changed into a function.
generate_skel_data %% very time consuming -> also will generate a new
clear all
dbgmsg('Skeleton data (training and validation) generated.')
% %%validation and training set


%% Loads environment Variables and saved Data

load_skel_data

important = 0.1;
relevant =0.03;
minor = 0.005;

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

%% Pre-conditioning of data
% 
[data_train_, data_val_, ~] = conformskel(data_train, data_val, awk,'nohips','nofeet');
[data_train_mirror, data_val_mirror, skelldef] = conformskel(data_train, data_val, awk,'mirror','nohips','nofeet');
data_train = [data_train_, data_train_mirror];
ends_train = [ends_train, ends_train];
data_val = [data_val_, data_val_mirror];
ends_val = [ends_val, ends_val];
y_train = [y_train y_train];
y_val = [y_val y_val];

% a = 1;
% windowSize = 1;
% b = (1/windowSize)*ones(1,windowSize);
% 
% data_train = medfilt1(data_train,3);
% data_val = medfilt1(data_val,3);



%% Setting up runtime variables
TEST = 1; % set to false to actually run it
PARA = 0;

P = 4;

NODES = 1000;

if TEST
    NODES = 2;
end

params.PLOTIT =0 ;
params.RANDOMSTART = false; % if true it overrides the .startingpoint variable

n = randperm(size(data_train,2),2);
params.startingpoint = [n(1) n(2)];

params.amax = 50; %greatest allowed age
params.nodes = NODES; %maximum number of nodes/neurons in the gas
params.en = 0.006; %epsilon subscript n
params.eb = 0.2; %epsilon subscript b
params.gamma = 4; % for the denoising function
params.skelldef = skelldef;

%Exclusive for gwr
params.STATIC = true;
params.MAX_EPOCHS = 2; % this means data will be run over twice
params.at = 0.95; %activity threshold
params.h0 = 1;
params.ab = 0.95;
params.an = 0.95;
params.tb = 3.33;
params.tn = 3.33;

%Exclusive for gng
params.lambda                   = 3;
params.alpha                    = .5;     % q and f units error reduction constant.
params.d                           = .99;   % Error reduction factor.


%% Classifier structure definitions
%%%% gas structures region

%%%% connection definitions:
%  allconn = {...
%      {'gng1layer',   'gng',{'pos'},                    'pos',1,params}...
%      {'gng2layer',   'gng',{'vel'},                    'vel',1,params}...
%      {'gng3layer',   'gng',{'gng1layer'},              'pos',3,params}...
%      {'gng4layer',   'gng',{'gng2layer'},              'vel',3,params}...
%      {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',3,params}};
% 
% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 2 3],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 2 3],params}...
%     {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
%     {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}};

allconn = {...
    {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
    {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
    {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',[3 2],params}...
    {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',[3 2],params}...
    {'gwrSTSlayer', 'gwr',{'gwr3layer','gwr4layer'},  'all',[3 2],params}};

% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[1 0],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[1 0],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[3 2],params}};

% allconn = {...
%     {'gwr1layer',   'gwr',{'pos'},                    'pos',[3 0],params}...
%     {'gwr2layer',   'gwr',{'vel'},                    'vel',[3 0],params}...
%     {'gwrSTSlayer', 'gwr',{'gwr1layer','gwr2layer'},  'all',[1 0],params}};
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
data.val = data_val;
data.train = data_train;
data.y.val = y_val;
data.y.train = y_train;
data.ends.train = ends_train;
data.ends.val = ends_val;

for i = 1:P
    paramsZ(i) = params;
end


clear a

a(1:P) = struct();%'best',[0 0 0],'mt',[0 0 0 0], 'bestmtallconn',struct('sensitivity',struct(),'specificity',struct(),'precision',struct()));
b = [];
starttime = tic;
if ~TEST 
while toc(starttime)<3600*10
if PARA
    for j = 1:1
        parfor i = 1:P
            a(i).a = executioncore_in_starterscript(paramsZ(i),allconn, data);
        end
        b = cat(2,b,a.a);
    end
else
    for j = 1:1
        for i = 1:P
            a(i).a = executioncore_in_starterscript(paramsZ(i),allconn, data);
        end
        b = cat(2,b,a.a);
    end
end
end
else
    executioncore_in_starterscript(paramsZ(1),allconn, data);
end
savevar = strcat('b',num2str(NODES),'_', num2str(params.MAX_EPOCHS),'epochs',num2str(size(b,2)),'remove4sigma');
eval(strcat(savevar,'=b;'))
save(strcat(pathtodropbox,'/classifier/',savevar,'.mat'),savevar)