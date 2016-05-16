function [allskel1, allskel2, allskeli1, allskeli2] = generate_skel_data(varargin)
% generates the .mat files that have the generated datasets for training and
% validation
% based on 2 types of random sampling
%
%%%% type 1 data sampling: known subjects, unknown individual activities from them:
%
%%%% type 2 data sampling: unknown subjects, unknown individual activities from them:
%
%
% data_train, y_train
% data_val, y_val
% 

%aa_environment
if nargin<2
    error('I need at least the name of the data set (either ''CAD60'' or ''tstv2'') and the data sampling type (either ''type1'' or ''type2'')')
end

dataset = varargin{1};
sampling_type = varargin{2};
if nargin>2
    allskeli1 = varargin{3};
end
if nargin>3
    allskeli2 = varargin{4};
end

switch dataset
    case 'CAD60'
        loadfun = @readcad60;
        datasize = 4;
    case 'tstv2'
        loadfun = @LoadDataBase;
        datasize = 11;
    case 'stickman'
        loadfun = @generate_falling_stick;
        datasize = 20; 
        if strcmp(sampling_type,'type1')
            dbgmsg('Sampling type1 not implemented for falling_stick!!! Using type2',1)
            sampling_type = 'type2';
        end
    otherwise
        error('Unknown database.')
end

%%% checks to see if indices will be within array range
if exist('allskeli1','var')
    if any(allskeli1>datasize)
        error('Index 1 is out of range for selected dataset.')
    end
end
if exist('allskeli2','var')
    if any(allskeli2>datasize)
        error('Index 2 is out of range for selected dataset.')
    end
end


%%%%%%%%Messages part: provides feedback for the user
dbgmsg('Generating random datasets for training and validation')
if exist('allskeli1','var')
    dbgmsg('Variable allskeli1 is defined. Will skip randomization.')
end
%%%%%%%%%%%%

%%%% type 1 data sampling: known subjects, unknown individual activities from them:
if strcmp(sampling_type,'type1')
    allskel = loadfun(1:datasize); %main data
    if ~exist('allskeli1','var')
        allskeli1 = randperm(length(allskel),fix(length(allskel)*.8)); % generates the indexes for sampling the dataset
    end
    allskel1 = allskel(allskeli1);
    if ~exist('allskeli2','var')
        allskeli2 = setdiff(1:length(allskel),allskeli1); % use the remaining data as validation set
    end
    allskel2 = allskel(allskeli2);
end

%%%% type 2 data sampling: unknown subjects, unknown individual activities from them:
if strcmp(sampling_type,'type2')
    if ~exist('allskeli1','var')
        allskeli1 = randperm(datasize,fix(datasize*.8)); % generates the indexes for sampling the dataset
    end
    allskel1 = loadfun(allskeli1(1)); %initializes the training dataset
    for i=2:length(allskeli1)
        allskel1 = cat(2,loadfun(allskeli1(i)),allskel1 ); 
    end

    allskeli2 = setdiff(1:datasize,allskeli1); % use the remaining data as validation set

    allskel2 = loadfun(allskeli2(1)); %initializes the training dataset
    for i=2:length(allskeli2)
        allskel2 = cat(2,loadfun(allskeli2(i)),allskel2 ); 
    end
end
%%%%%%
% saves data
%%%%%%

