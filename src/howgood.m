function f = howgood(savestructure,j)
A = zeros(2);
for i = 1:length(savestructure)
    A = A + savestructure(i).gas(j).confusions.val;
%    b = b + savestructure(i).gas(j).confusions.train;
end

A = savestructure(i).gas(j).confusions.val;
sensitivity = A(2,2)/(A(2,2)+A(2,1));
specificity = A(1,1)/(A(1,1)+A(1,2));
precision = A(2,2)/(A(2,2)+A(1,2)); 
f1 = 2*A(2,2)/(2*A(2,2)+A(1,2)+A(2,1));
f = [sensitivity specificity precision f1]*100;
