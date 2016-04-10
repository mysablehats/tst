function a = turtlesallthewaydown(a)

while(iscell(a)||~isempty(a))
    try
        a = [a{:}];
    catch
        break
    end
end
%a = num2cell(a);