function f = howgood(savematrix)
a = zeros(2);
b = a;
for i = 1:length(savematrix)
    a = a + savematrix(i).confusions.val;
    b = b + savematrix(i).confusions.train;
end
result = a;
f1 = 2*result(1,1)/(2*result(1,1)+result(2,1)+result(1,2));
result = b;
f2 = 2*result(1,1)/(2*result(1,1)+result(2,1)+result(1,2));
f = [f1, f2];