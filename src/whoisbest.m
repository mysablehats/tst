function f = whoisbest(savestructure,j)
f1 = 0;
f2 = 0;
for i = 1:length(savestructure)
    result = savestructure(i).gas(j).confusions.val;
    f = 2*result(1,1)/(2*result(1,1)+result(2,1)+result(1,2));
    if f>f1
        f1=f;
    end
    
    result = savestructure(i).gas(j).confusions.train;
    f = 2*result(1,1)/(2*result(1,1)+result(2,1)+result(1,2));
    
    if f>f2
        f2=f;
    end
end
f = [f1, f2];