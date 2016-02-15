%script to run the differential parts
%load('tst_skel.mat')
%a = diff(Data')';
%b = diff(a')';
%cl_skel(b)

[SLASH, pathtodata] = OS_VARS();

%%%% type 1 data sampling: known subjects, unknown individual activities from them:
% allskel = LoadDataBase(1:11); %main data
% allskeli1 = randperm(length(allskel),fix(length(allskel)*.8)) % generates the indexes for sampling the dataset
% allskel1 = allskel(allskeli1);
% allskeli2 = setdiff(1:length(allskel),allskeli1) % use the remaining data as validation set
% allskel2 = allskel(allskeli2);
% 

%%%% type 2 data sampling: unknown subjects, unknown individual activities from them:

allskeli1 = randperm(11,fix(11*.8)) % generates the indexes for sampling the dataset

allskel1 = LoadDataBase(allskeli1(1)); %initializes the training dataset
for i=2:length(allskeli1)
    allskel1 = cat(2,LoadDataBase(allskeli1(i)),allskel1 ); %this is a hack;loaddatabase should use a 1:11 type syntax
end

allskeli2 = setdiff(1:11,allskeli1) % use the remaining data as validation set

allskel2 = LoadDataBase(allskeli2(1)); %initializes the training dataset
for i=2:length(allskeli2)
    allskel2 = cat(2,LoadDataBase(allskeli2(i)),allskel2 );
end

%%%%%%

[X, data_train,y_train] = extractdata(allskel1);
save(strcat('..',SLASH,'share',SLASH,'tst_skel'),'data_train', 'y_train','-v7.3');

[X, data_val,y_val] = extractdata(allskel2);
save(strcat('..',SLASH,'share',SLASH,'tst_skel_val'),'data_val', 'y_val','-v7.3');

clear all

[SLASH, pathtodata] = OS_VARS();

load(strcat('..',SLASH,'share',SLASH,'tst_skel_val.mat'))
load(strcat('..',SLASH,'share',SLASH,'tst_skel.mat'))