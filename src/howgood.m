function f = howgood(savestructure,j)
a = zeros(2);
b = a;

for i = 1:length(savestructure)
    a = a + savestructure(i).gas(j).confusions.val;
    b = b + savestructure(i).gas(j).confusions.train;
end
result = a;
f1 = 2*result(1,1)/(2*result(1,1)+result(2,1)+result(1,2));
result = b;
f2 = 2*result(1,1)/(2*result(1,1)+result(2,1)+result(1,2));
f = [f1, f2];