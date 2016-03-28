function rndcf = randclassifier(y, bias, M)
rndcf(1:M) = struct();
for i = 1:M
    rndclass = round((rand(size(y))+bias*rand())/2);
    [~, savestructure.gas.confusions.val, ~, ~] = confusion(y,rndclass); %omg this is totally bad programming
    rndcf(i).mt = whoisbest(savestructure,1);
end