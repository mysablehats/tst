%script to run the differential parts
%load('tst_skel.mat')
%a = diff(Data')';
%b = diff(a')';
%cl_skel(b)

LoadDataBase(1, 5, false);
LoadDataBase(6, 11, true);

load('tst_skel.mat')
load('tst_skel.mat')