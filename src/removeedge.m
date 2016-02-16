function [C, C_age ] = removeedge(C, C_age) 
global amax
[row, col] = find(C_age >= amax);
if ~isempty(row)
    for i = 1:size(row)
        C_age = xerocol(C_age,i);
        C = xerocol(C,i);
    end
end
end
function C = xerocol(C,i)
C(:,i) = zeros(size(C,1),1);
C(i,:) = zeros(1,size(C,1));
end