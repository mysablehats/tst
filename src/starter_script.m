%script to run the differential parts
%load('tst_skel.mat')
%a = diff(Data')';
%b = diff(a')';
%cl_skel(b)

[SLASH, pathtodata] = OS_VARS();

allskel1 = LoadDataBase(1, 5, false);
allskel2 = LoadDataBase(6, 11, true);

load(strcat('..',SLASH,'share',SLASH,'tst_skel_val.mat'))
load(strcat('..',SLASH,'share',SLASH,'tst_skel.mat'))