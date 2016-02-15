%script to run the differential parts
%load('tst_skel.mat')
%a = diff(Data')';
%b = diff(a')';
%cl_skel(b)

[SLASH, pathtodata] = OS_VARS();

allskel1 = LoadDataBase(1, 5); %main data
allskel2 = LoadDataBase(6, 11); %validate data


[X, data,y] = extractdata(allskel1);
save(strcat('..',SLASH,'share',SLASH,'tst_skel_val'),'data', 'y','-v7.3');

[X, Data,Y] = extractdata(allskel2);
save(strcat('..',SLASH,'share',SLASH,'tst_skel'),'Data', 'Y','-v7.3');


load(strcat('..',SLASH,'share',SLASH,'tst_skel_val.mat'))
load(strcat('..',SLASH,'share',SLASH,'tst_skel.mat'))