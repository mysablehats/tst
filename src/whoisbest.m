function f = whoisbest(savestructure,j)
sensitivity = 0;
specificity = 0;
precision = 0;
f1 = 0;
i1 = 0;
i2 = 0;
i3 = 0;
i4 = 0; 
for i = 1:length(savestructure)
        A = savestructure(i).gas(j).confusions.val;
        a = A(2,2)/(A(2,2)+A(2,1)); %sensitivity
        b = A(1,1)/(A(1,1)+A(1,2)); %specificity
        c = A(2,2)/(A(2,2)+A(1,2)); %precision
        d = 2*A(2,2)/(2*A(2,2)+A(1,2)+A(2,1)); %f1
        if a > sensitivity
            sensitivity = a;
            i1 = i;
        end
        if b > specificity
            specificity = b;
            i2 = i;
        end
        if c > precision
            precision = c;
            i3 = i;
        end
        if d > f1
            f1 = d;
            i4 = i;
        end
end

f= [sensitivity*100 specificity*100 precision*100 f1*100 i1 i2 i3 i4];
