fclose('all');
clear all;
close all;

%% Generate Skeletons
% This takes quite a while to execute, so I rarely run it. 
%%% >>>>> this has to be changed into a function.
%generate_skel_data %% very time consuming -> also will generate a new
% clear all
% dbgmsg('Skeleton data (training and validation) generated.')
% %%validation and training set

%% Pre-conditioning of data
% 
%[data_train, data_val] = removehipbias(data_train, data_val); 
[data_train_, data_val_] = conformskel(data_train, data_val,'nohips','normal');
[data_train_mirror, data_val_mirror] = conformskel(data_train, data_val,'mirror','nohips','normal');
data_train = [data_train_, data_train_mirror];
ends_train = [ends_train, ends_train];
data_val = [data_val_, data_val_mirror];
ends_val = [ends_val, ends_val];
y_train = [y_train y_train];
y_val = [y_val y_val];

%% Loads environment Variables and saved Data

load_skel_data

TEST = true; % set to false to actually run it
PARA = true;
P = 4;
NODES = 1000;


if TEST
    NODES = 3;
end
if ~PARA
    P = 1;
end


params.PLOTIT = false;
params.RANDOMSTART = false;

params.amax = 50; %greatest allowed age
params.nodes = NODES; %maximum number of nodes/neurons in the gas
params.en = 0.006; %epsilon subscript n
params.eb = 0.2; %epsilon subscript b

%Exclusive for gwr
params.STATIC = true;
params.MAX_EPOCHS = 1; % this means data will be run over twice
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
%      {'gng1layer',   'gng',{'pos'},                    'pos',1}...
%      {'gng2layer',   'gng',{'vel'},                    'vel',1}...
%      {'gng3layer',   'gng',{'gng1layer'},              'pos',3}...
%      {'gng4layer',   'gng',{'gng2layer'},              'vel',3}...
%      {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',3}};

  allconn = {...
      {'gwr1layer',   'gwr',{'pos'},                    'pos',1,params}...
      {'gwr2layer',   'gwr',{'vel'},                    'vel',1,params}...
      {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3,params}...
      {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3,params}...
      {'gwrSTSlayer', 'gwr',{'gwr4layer','gwr3layer'},  'all',3,params}};

%  allconn = {...
%      {'gwr1layer',   'gwr',{'pos'},                    'pos',3}...
%      {'gwr2layer',   'gwr',{'vel'},                    'vel',3}...
%      {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3}...
%      {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3}...
%      {'gwr5layer',   'gwr',{'gwr3layer'},              'pos',3}...
%      {'gwr6layer',   'gwr',{'gwr4layer'},              'vel',3}...
%      {'gwrSTSlayer', 'gwr',{'gwr6layer','gwr5layer'},  'all',3}}; 
 
% allconn = {{'gwr1layer',   'gwr',{'pos'},                    'pos',3, params}...
%            };
%        


%%  Pre gas conditioning


%% Pos gas conditioning


%%
% a = 1;
% windowSize = 1;
% b = (1/windowSize)*ones(1,windowSize);
% 
% data_train = medfilt1(data_train,3);
% data_val = medfilt1(data_val,3);

data.val = data_val;
data.train = data_train;
data.y.val = y_val;
data.y.train = y_train;
data.ends.train = ends_train;
data.ends.val = ends_val;

sv = starter_sc(data, allconn, P);


