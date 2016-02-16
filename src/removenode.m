function [C, A, C_age, h ] = removenode(C, A, C_age, h) %depends only on C operates on everything
[row,col] = find(C);
a = [row;col];
maxa = max(a);
for i = 1:max(a)
    if isempty(find(a == i))
        %has to do this to every matrix and vector
        C = clipsimmat(C,i);
        A(:,i) = []; % A is a different guy
        A = padarray(A,[0 1],'post');
        C_age = clipsimmat(C_age,i);
        h = clipvect(h,i);
    end
%clip everything after max(a)
%C = clip(C, maxa)

end
end

function C = clipsimmat(C,i)
C(i,:) = [];
C(:,i) = [];
C = padarray(C,[1 1],'post');
end

function V = clipvect(V, i)
V(i) = [];
V = [V 0];
end

