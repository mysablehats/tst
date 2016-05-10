function [fval,ftrain] = calculatemetrics(cst)

[gasindex,gaslayer] = size(cst.metrics);

A = zeros(2);
for i = 1:gaslayer
    for j = 1:

A = cst.metrics(i,j).val;
sensitivity = A(2,2)/(A(2,2)+A(1,2));
specificity = A(1,1)/(A(1,1)+A(2,1));
precision = A(2,2)/(A(2,2)+A(2,1)); 
f1 = 2*A(2,2)/(2*A(2,2)+A(2,1)+A(1,2));
f = [sensitivity specificity precision f1]*100;
