function a = turtlesallthewaydown(a)

while(length(a)==1||~isempty(a))
    try
        a = [a{:}];
    catch
        break
    end
end
a = num2cell(a);