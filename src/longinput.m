function [linput,newends] = longinput(shortinput, q, ends)
newends = zeros(size(ends));
linput = zeros(size(shortinput,1)*q,size(shortinput,2)-size(ends,2)*(q-1))
%%% I will try with pre allocation if it doesnt work, then I will try with
%%% the cat approach -> start from 2 and cat it...
k = 1;
dimshort = size(shortinput,1);
for j = 1:size(ends,2)
    for i = 1:(ends(j)-(q-1))
        a = zeros(dimshort*q,1);
        for l =1:q
            a(1+dimshort*(l-1):dimshort*l) = shortinput(:,k);
        end
        linput(:,k) = a;
        k=k+1;
    end
end
end
