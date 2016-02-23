%removehipbias

for i = 1:size(data_train,2)
    data_train(:,1) = centerhips(data_train(:,1));
end
for i = 1:size(data_val,2)
    data_val(:,1) = centerhips(data_val(:,1));
end
