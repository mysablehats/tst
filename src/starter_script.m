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


%% Loads environment Variables and saved Data

load_skel_data


%% Pre-conditioning of data
% 
[data_train_, data_val_] = conformskel(data_train, data_val,'nohips','normal');
[data_train_mirror, data_val_mirror] = conformskel(data_train, data_val,'mirror','nohips','normal');
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
TEST = false; % set to false to actually run it
PARA = false;

P = 4;

NODES = 1000;

if TEST
    NODES = 100;
end
if ~PARA
    P = 1;
end

params.PLOTIT = false; %not really working
params.RANDOMSTART = false; % if true it overrides the .startingpoint variable

n = randperm(size(data_train,2),2);
params.startingpoint = [n(1) n(2)];

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
%      {'gng1layer',   'gng',{'pos'},                    'pos',1,params}...
%      {'gng2layer',   'gng',{'vel'},                    'vel',1,params}...
%      {'gng3layer',   'gng',{'gng1layer'},              'pos',3,params}...
%      {'gng4layer',   'gng',{'gng2layer'},              'vel',3,params}...
%      {'gngSTSlayer', 'gng',{'gng4layer','gng3layer'},  'all',3,params}};
% 
%   allconn = {...
%       {'gwr1layer',   'gwr',{'pos'},                    'pos',1,params}...
%       {'gwr2layer',   'gwr',{'vel'},                    'vel',1,params}...
%       {'gwr3layer',   'gwr',{'gwr1layer'},              'pos',3,params}...
%       {'gwr4layer',   'gwr',{'gwr2layer'},              'vel',3,params}...
%       {'gwrSTSlayer', 'gwr',{'gwr4layer','gwr3layer'},  'all',3,params}};

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
 allconn = {{'gwr1layer',   'gwr',{'pos'},                    'pos',3, params}...
            };
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

for i = 1:8
    paramsZ(i) = params;
end

tic
clear a
a(1:4) = struct('best',[0 0 0],'mt',[0 0 0 0], 'bestmtallconn',struct('sensitivity',struct(),'specificity',struct(),'precision',struct()));
for j = 1:1    
    parfor i = 1:4
        n = randperm(size(data_train,2)-3,2); % -(q-1) necessary because concatenation reduces the data size!
        paramsZ(i).startingpoint = [n(1) n(2)];
        allconn = {{'gwr1layer',   'gwr',{'pos'},                    'pos',3, paramsZ(i)}...
            };
        [~, a(i).mt] = starter_sc(data, allconn, P);
        if a(i).mt(1)>a(i).best(1)&&a(i).mt(4)>40
            a(i).best(1) = a(i).mt(1);
            a(i).bestmtallconn.sensitivity = allconn;
        end
        if a(i).mt(2)>a(i).best(2)&&a(i).mt(4)>40
            a(i).best(2) = a(i).mt(2);
            a(i).bestmtallconn.specificity = allconn;
        end
        if a(i).mt(3)>a(i).best(3)&&a(i).mt(4)>40
            a(i).best(3) = a(i).mt(3);
            a(i).bestmtallconn.precision = allconn;
        end
    end
end
toc