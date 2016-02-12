%script to run the differential parts
%load('tst_skel.mat')
a = diff(Data')';
b = diff(a')';
cl_skel(b)