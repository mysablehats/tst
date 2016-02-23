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
allskeli1 = [9,10,11,4,8,5,3,6]; %% comment these out to have random new samples
allskeli2 = [1,2,7];%% comment these out to have random new samples
sampling_type = 'type2'

[SLASH, pathtodata] = OS_VARS();

%%%% type 1 data sampling: known subjects, unknown individual activities from them:
if strcmp(sampling_type,'type1')
    allskel = LoadDataBase(1:11); %main data
    if ~exist('allskeli1')
        allskeli1 = randperm(length(allskel),fix(length(allskel)*.8)); % generates the indexes for sampling the dataset
    end
    allskel1 = allskel(allskeli1);
    allskeli2 = setdiff(1:length(allskel),allskeli1); % use the remaining data as validation set
    allskel2 = allskel(allskeli2);
end

%%%% type 2 data sampling: unknown subjects, unknown individual activities from them:
if strcmp(sampling_type,'type2')
    if ~exist('allskeli1')
        allskeli1 = randperm(11,fix(11*.8)); % generates the indexes for sampling the dataset
    end
    allskel1 = LoadDataBase(allskeli1(1)); %initializes the training dataset
    for i=2:length(allskeli1)
        allskel1 = cat(2,LoadDataBase(allskeli1(i)),allskel1 ); 
    end

    allskeli2 = setdiff(1:11,allskeli1); % use the remaining data as validation set

    allskel2 = LoadDataBase(allskeli2(1)); %initializes the training dataset
    for i=2:length(allskeli2)
        allskel2 = cat(2,LoadDataBase(allskeli2(i)),allskel2 ); 
    end
end
%%%%%%
% saves data
%%%%%%

[X, data_train,y_train] = extractdata(allskel1);
save(strcat('..',SLASH,'share',SLASH,'tst_skel'),'data_train', 'y_train','allskeli1','-v7.3');

[X, data_val,y_val] = extractdata(allskel2);
save(strcat('..',SLASH,'share',SLASH,'tst_skel_val'),'data_val', 'y_val','allskeli2','-v7.3');
