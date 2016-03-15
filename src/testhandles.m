function a= testhandles(X)
a = zeros(size(X));
func = @aa;
for i = 1: length(X)
a(i)= func(X(i));
end
end
function Y = aa(X)
Y = X*2+3;
end