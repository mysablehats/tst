function [A, C ,outparams] = gas_wrapper(data,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cf parisi, 2015 and cf marsland, 2002 based on the GNG algorithm from the
%guy that did the GNG algorithm for matlab

% some tiny differences: in the 2002 paper, they want to show the learning
% of topologies ability of the GWR algorithm, which is not our main goal.
% In this sense they have a function that can generate new points as
% pleased p(eta). This is not our case, we will just go through our data
% 'sequentially' (or with a random permutation)

% Also, I am not taking time into account. the h(time) function is
% therefore something that yields a constant value

% As of yet, the gpu use is poor and not optimized, running at 10x slower
% speed than on the cpu. Also, resuming is only perhaps functional when not
% using parallel threads; this is due to the fact that with many different
% initialization parameters it gets hard to know exactly the
% characteristics of the gas before training time. There are many ways this
% can be solved, it just hasn't been priority yet.

%the initial parameters for the algorithm: global maxnodes at en eb h0 ab
%an tb tn amax
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%maxnodes = params.nodes; %maximum number of nodes/neurons in the gas at =
%params.at;%0.95; %activity threshold en = params.en;%= 0.006; %epsilon
%subscript n eb = params.eb;%= 0.2; %epsilon subscript b amax =
%params.amax;%= 50; %greatest allowed age
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 3
    params = varargin{1};
    gastype = varargin{2};
    arq_connect = struct();
else
    arq_connect = varargin{1};
    gastype = [];
end


if isfield(arq_connect, 'params')&&~isempty(arq_connect.params)
    params = arq_connect.params;
end
if isfield(arq_connect, 'method')&&~isempty(arq_connect.method)
    gastype = arq_connect.method;
elseif 0
    gastype = 'gwr';
    %error('Method must be declared')
end
if ~isfield(params, 'savegas')
    params.savegas.name = 'gas';
    params.savegas.resume = false;
    params.savegas.path = '~/Dropbox/octave_progs/';
end

if isempty(params)
    
    NODES = 100;
    
    params = struct();
    
    params.use_gpu = false;
    params.PLOTIT = true; %
    params.RANDOMSTART = false; % if true it overrides the .startingpoint variable
    params.RANDOMSET = false;
    params.savegas.name = 'gas';
    params.savegas.resume = false;
    params.savegas.path = '~/Dropbox/octave_progs/';
    params.savegas.gasindex = 1;
    
    n = randperm(size(data,2),2);
    params.startingpoint = [n(1) n(2)];
    
    params.amax = 500; %greatest allowed age
    params.nodes = NODES; %maximum number of nodes/neurons in the gas
    params.en = 0.006; %epsilon subscript n
    params.eb = 0.2; %epsilon subscript b
    
    %Exclusive for gwr
    params.STATIC = true;
    params.MAX_EPOCHS = 1; % this means data will be run over twice
    params.at = 0.80; %activity threshold
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
else
   %
    
end
if  isfield(arq_connect, 'name')&&params.savegas.resume
     params.savegas.name = strcat(arq_connect.name,'-n', num2str(params.nodes), '-s',num2str(size(data,1)),'-q',num2str(params.q),'-i',num2str(params.savegas.gasindex));
elseif params.savegas.resume
    error('Strange arq_connect definition. ''.name'' field is needed.')
end


MAX_EPOCHS = params.MAX_EPOCHS;
PLOTIT = params.PLOTIT;

%%% things that are specific for skeletons:
if isfield(params,'skelldef')
    skelldef = params.skelldef;
else
    skelldef = [];
end
if isfield(params,'layertype')
    layertype = params.layertype;
else
    layertype = [];
end

if isfield(params,'plottingstep')        
    if params.plottingstep == 0
        plottingstep = size(data,2);
    else
        plottingstep = params.plottingstep;
    end    
else
    plottingstep = fix(size(data,2)/20);
end
if ~isfield(params,'use_gpu')|| gpuDeviceCount==0
    params.use_gpu = false;
    %or break or error or warning...
end

if PLOTIT
    figure
    plotgwr() % clears plot variables
end

datasetsize = size(data,2);
errorvect = nan(1,MAX_EPOCHS*datasetsize);
epochvect = nan(1,MAX_EPOCHS*datasetsize);
nodesvect = nan(1,MAX_EPOCHS*datasetsize);

if  params.use_gpu 
    data = gpuArray(data);
    errorvect = gpuArray(errorvect);
    epochvect = gpuArray(epochvect);
    nodesvect = gpuArray(nodesvect);
end


switch gastype
    case 'gwr'
        gasfun = @gwr_core;
        gasgas = gas;
        gasgas = gasgas.gwr_create(params,data);
    case 'gng'
        gasfun = @gng_core;
        gasgas = gas;
        gasgas = gasgas.gng_create(params,data);
    otherwise
        error('Unknown method.')
end

%%% ok, I will need to be able to resume working on a gas if I want to
if isfield(params, 'savegas')&&params.savegas.resume
    savegas = strcat(params.savegas.path,'/', params.savegas.name);
    %%% checks if savegas exists
    if 0&&exist(savegas,'file') %%% if it does, then it loads it, because it should have the same %% disabled
        dbgmsg('Found gas with the same characteristics as this one. Will try loading gas',params.savegas.name,1)
        load(savegas)
        try
            gasfun(data(:,1), gasgas);
        catch
            dbgmsg('I failed. Will start a new gas. ')
            
            switch gastype
                case 'gwr'
                    gasfun = @gwr_core;
                    gasgas = gas;
                    gasgas = gasgas.gwr_create(params,data);
                case 'gng'
                    gasfun = @gng_core;
                    gasgas = gas;
                    gasgas = gasgas.gng_create(params,data);
                otherwise
                    error('Unknown method.')
            end
        end
    else
        dbgmsg('Didn''t find gas with the same characteristics as this one. Will use a new gas with name:\t',params.savegas.name,1)
    end    
end


therealk = 0; %% a real counter for epochs

%%%starting main loop

for num_of_epochs = 1:MAX_EPOCHS % strange idea: go through the dataset more times - actually this makes it overfit the data, but, still it is interesting.

    if params.RANDOMSET
        kset = randperm(datasetsize);
    else
        kset = 1:datasetsize;
    end
    % start of the loop
    for k = kset %step 1
        therealk = therealk +1;
        
        gasgas = gasfun(data(:,k), gasgas);
        
        %to make it look nice...
        errorvect(therealk) = gasgas.a;
        epochvect(therealk) = therealk;
        nodesvect(therealk) = gasgas.r-1;
        if PLOTIT&&mod(k,plottingstep)==0&&numlabs==1 %%% also checks to see if it is inside a parpool
            plotgwr(gasgas.A,gasgas.C,errorvect,epochvect,nodesvect, skelldef, layertype)
            drawnow
        end        
    end
    
    %%% updating the number of epochs the gas has run
    gasgas = gasgas.update_epochs(num_of_epochs);
    
    %%% now save the resulting gas
    if isfield(params, 'savegas')&&isfield(params.savegas,'save') &&params.savegas.save
        save(strcat(savegas,'-e',num2str(num_of_epochs)), 'gasgas')
    end
end
outparams.graph.errorvect = errorvect;
outparams.graph.epochvect = epochvect;
outparams.graph.nodesvect = nodesvect;
outparams.accumulatedepochs = gasgas.params.accumulatedepochs;
outparams.initialnodes = [gasgas.ni1,gasgas.ni2];
A = gasgas.A;
C = gasgas.C;
end
