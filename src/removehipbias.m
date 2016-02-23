%removehipbias
%have to initiate a newer array with one dimension less...
function [nohips_train, nohips_val] = removehipbias(data_train, data_val)
nohips_train = zeros(size(data_train)-[3 0]);
nohips_val = zeros(size(data_val)-[3 0]);

for i = 1:size(data_train,2)
    nohips_train(:,i) = centerhips(data_train(:,i));
end
for i = 1:size(data_val,2)
    nohips_val(:,i) = centerhips(data_val(:,i));
end
