%generatetestskel.m
load_skel_data
data = [data_val data_train];

index_a = randperm(size(data,2),10);
a = data(:,index_a);

save(strcat(wheretosavestuff,SLASH,'test_skel.mat'),'a')
clear index_a
clear a
clear data