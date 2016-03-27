function wchop = chop_procedure(w, whichisit,q)
vectorsize = size(w,1);
[polidx_prim, velidx_prim] = generateidx(vectorsize/q);
polidx = zeros(1,size(polidx_prim,2)*q);
velidx = zeros(1,size(velidx_prim,2)*q);
for i = 1:q
    polidx(1+(i-1)*size(polidx_prim,2):i*size(polidx_prim,2)) = polidx_prim +(i-1)*vectorsize/q;
    velidx(1+(i-1)*size(velidx_prim,2):i*size(velidx_prim,2)) = velidx_prim +(i-1)*vectorsize/q;
end
switch whichisit
    case 'pos'
        wchop = w(polidx,:);
    case 'vel'
        wchop = w(velidx,:);
    case 'all'
        wchop = w;
    otherwise
        if ~ischar(whichisti)
            error('variable whichisit isn''t even a char, wtf man')
        else
            error(strcat('no idea what parameter you wanted me to compare it to...\n you gave me:', whichisit))
        end
end