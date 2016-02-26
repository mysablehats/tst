function matmat = genbestmmatrix(gwr_nodes, data, whichisit)

matmat = zeros(size(data,1),size(gwr_nodes,2));    
for i = 1:size(gwr_nodes,2)
        matmat(:,i) = bestmatchingunit(gwr_nodes(:,1),data,whichisit);
end
end
function s = bestmatchingunit(w,data,whichisit)
%finds the best matching unit
[polidx, velidx] = generateidx(size(data,1));
switch whichisit
    case 'pos'
        datachop = data(polidx,:);
    case 'vel'
        datachop = data(velidx,:);
    otherwise
        if ~ischar(whichisti)
            error('variable whichisit isn''t even a char, wtf man')
        else
            error(strcat('no idea what parameter you wanted me to compare it to...\n you gave me:', whichisit))
        end
end

maxmax = size(datachop,2);
a = zeros(maxmax,1);
for i = 1:maxmax
    a(i) = norm(w-datachop(:,i));
end
[~, indexx] = min(a);
s = data(:,indexx);
end
