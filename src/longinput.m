function [linput,newends, newy] = longinput(shortinput, qp, ends, y)
% this function was getting messy, so I decided to recreate the structure
% that generated her, so to make easier debugging
% It is very disellegant of me. I apologise.
q = qp(1);
p = qp(2);

realends = cumsum(ends,2);

actionstructure(1:size(ends,2)) = struct();
actionstructure(1).pose = shortinput(:,1:realends(1)); 
actionstructure(1).end = ends(1);
actionstructure(1).y = y(1);

for i = 2:size(ends,2)
    actionstructure(i).pose = shortinput(:,realends(i-1)+1:realends(i));
    actionstructure(i).end = ends(i);
    actionstructure(i).y = y(realends(i));
end
shortdim = size(shortinput,1);
for i = 1:length(actionstructure)
    m = 1;
    for j = 1:1+p:actionstructure(i).end
        a = zeros(shortdim*q,1);
        if j+q-1>actionstructure(i).end
            %cant complete the whole vector!
            break
        else
            for k = 1:q
                a(1+(k-1)*shortdim:k*shortdim) = actionstructure(i).pose(:,j+k-1);
            end
        end
        %have to save a somewhere
        actionstructure(i).long(m).vec = a;
        m = m+1;
    end
    %should concatenate long now
    actionstructure(i).newend = length(actionstructure(i).long);
    actionstructure(i).longinput = zeros(q*shortdim,actionstructure(i).newend);
    actionstructure(i).longy = actionstructure(i).y*ones(1,actionstructure(i).newend);
    for j = 1:actionstructure(i).newend
        actionstructure(i).longinput(:,j) = actionstructure(i).long(j).vec;
    end
end
linput = actionstructure(1).longinput;
newy = actionstructure(1).longy;
newends(1) = actionstructure(1).newend;
for i = 2:length(actionstructure)
    linput = cat(2,linput,actionstructure(i).longinput);
    newy = cat(2,newy, actionstructure(i).longy);
    newends(i) = actionstructure(i).newend;
end