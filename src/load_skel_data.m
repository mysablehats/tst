% loads the mat files that have the generated datasets for training and
% validation
% data_train, y_train
% data_val, y_val
% 

[SLASH, pathtodata] = OS_VARS();

load(strcat('..',SLASH,'share',SLASH,'tst_skel_val.mat'))
load(strcat('..',SLASH,'share',SLASH,'tst_skel.mat'))