function [linput,newends, newy, indexes] = longinput(shortinput, qp, ends, y, iindex)
% this function was getting messy, so I decided to recreate the structure
% that generated her, so to make easier debugging
% It is very disellegant of me. I apologise.
q = qp(1);
switch length(qp)
    case 1
        p = 0;
        r = 1;
    case 2
        p = qp(2);
        r = 1;
    case 3
        p = qp(2);
        r = qp(3);
end

realends = cumsum(ends,2);

actionstructure(1:size(ends,2)) = struct();
actionstructure(1).pose = shortinput(:,1:realends(1)); 
actionstructure(1).end = ends(1);
actionstructure(1).y = y(:,realends(1));
actionstructure(1).index = iindex(1:ends(1));

for i = 2:size(ends,2)
    actionstructure(i).pose = shortinput(:,realends(i-1)+1:realends(i));
    actionstructure(i).end = ends(i);
    actionstructure(i).y = y(:,realends(i));
    actionstructure(i).index = iindex(realends(i-1):realends(i));
end
shortdim = size(shortinput,1);
for i = 1:length(actionstructure)
    m = 1;
    for j = 1:1+p:actionstructure(i).end
        a = zeros(shortdim*q,1);
        indexx = cell(1,q);
        if j+q*r-1>actionstructure(i).end
            %cant complete the whole vector!
            break
        else
            k = 1;
            for lop = 1:q
                a(1+(k-1)*shortdim:k*shortdim) = actionstructure(i).pose(:,j+lop*r-1);
                indexx{lop} = actionstructure(i).index{j+lop*r-1}; 
                k = k+1;
            end
        end
        %have to save a somewhere
        actionstructure(i).long(m).vec = a;
        actionstructure(i).long(m).index = indexx;
        m = m+1;
    end
    %should concatenate long now
    actionstructure(i).newend = length(actionstructure(i).long);
    actionstructure(i).longinput = zeros(q*shortdim,actionstructure(i).newend);
    actionstructure(i).longy = repmat(actionstructure(i).y,1,actionstructure(i).newend);
    actionstructure(i).longindex = cell(1,size(actionstructure(i).longy,2));
    for j = 1:actionstructure(i).newend
        actionstructure(i).longinput(:,j) = actionstructure(i).long(j).vec;
        actionstructure(i).longindex{j} = actionstructure(i).long(j).index;
    end
end
linput = actionstructure(1).longinput;
newy = actionstructure(1).longy;
newends(1) = actionstructure(1).newend;
indexes = actionstructure(1).longindex;
for i = 2:length(actionstructure)
    linput = cat(2,linput,actionstructure(i).longinput);
    newy = cat(2,newy, actionstructure(i).longy);
    newends(i) = actionstructure(i).newend;
    indexes = cat(2,indexes, actionstructure(i).longindex);
end