function wchop = chop_procedure(w, whichisit)
[polidx, velidx] = generateidx(size(w,1));
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