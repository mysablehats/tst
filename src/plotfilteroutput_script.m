a = 1;
windowSize = 1;
b = (1/windowSize)*ones(1,windowSize);
for i = 1:size(savestructure.val.gas)
    yy(i,:) = filter(b,a,savestructure.val.gas(i).class);
end
plot(yy)
hold on
plot(savestructure.val.y,'LineWidth',3)