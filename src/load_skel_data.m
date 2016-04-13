% loads the mat files that have the generated datasets for training and
% validation
% data_train, y_train
% data_val, y_val
% 
aa_environment % load environment variables

load(strcat(pathtodropbox,SLASH,'share',SLASH,'tst_skel_val_.mat'))
load(strcat(pathtodropbox,SLASH,'share',SLASH,'tst_skel_.mat'))