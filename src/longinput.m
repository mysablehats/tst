function [linput,newends, newy] = longinput(shortinput, q, ends, y)
newends = zeros(size(ends));
linput = zeros(size(shortinput,1)*q,size(shortinput,2)-size(ends,2)*(q-1));
newy = zeros(1,size(linput,2));
%%% I will try with pre allocation if it doesnt work, then I will try with
%%% the cat approach -> start from 2 and cat it...

%there should be some error checking here, so if any "ends" is smaller than
%q then, it should complain, but I won't write it because it is 

newends = ends-(q-1);
k = 1;
dimshort = size(shortinput,1);
maxj = size(ends,2);
endofdata = size(shortinput,2);
for j = 1:maxj
    maxi = newends(j);
    if maxi<0
        newends(j) =0;
    else
        for i = 1:maxi
            a = zeros(dimshort*q,1);
            for l =1:q
                funnyindex = k+l-1+(q-1)*(j-1); %it should have the property of jumping the last q-1 points of a set
                if funnyindex>endofdata
                    newends(j) = newends(j)-1; %perhaps I cannot fill a whole vector? this should never happen, but I don't know, these indexes are funny/.
                    break
                else
                    a(1+dimshort*(l-1):dimshort*l) = shortinput(:,funnyindex);
                end
            end
            linput(:,k) = a;
            newy(k) = y(funnyindex); %% this was done in a hurry and has to be debugged.
            k=k+1;
        end
    end
end
end
