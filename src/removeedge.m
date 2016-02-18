function [C, C_age ] = removeedge(C, C_age) 
global amax
[row, col] = find(C_age > amax);
if ~isempty(row)
    a = size(row,2);
    for i = 1:a
        if i>size(row,2)
            disp('oops, something wrong with removeedge, nevermind...')
            break
        end
        C_age(row(i),col(i)) = 0;
        C(row(i),col(i)) = 0;
    end
end
end
