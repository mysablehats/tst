function [C, C_age ] = removeedge(C, C_age) 
global amax
[row, col] = find(C_age > amax);
if ~isempty(row)
    disp('I am working!')
    row
    a = size(row,2);
    C_age
    for i = 1:a
        [row, col] = find(C_age > amax);
        if i>size(row,2)
            disp('oops, something wrong with removeedge, nevermind...')
            break
        end
        C_age = xerocol(C_age,i);
        C = xerocol(C,i);
    end
end
end
function C = xerocol(C,i)
C(:,i) = zeros(size(C,1),1);
C(i,:) = zeros(1,size(C,1));
end