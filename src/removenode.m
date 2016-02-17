function [C, A, C_age, h,r ] = removenode(C, A, C_age, h,r) %depends only on C operates on everything
[row,col] = find(C);
a = [row;col];
if max(a)>r
    warning(strcat('the highest point is:',num2str(r),' but somehow I have the connection with the point:',num2str(maxa),'. This seems wrong.'))
end
for i = 1:max(a)% r
    if isempty(find(a == i))
        %has to do this to every matrix and vector
        C = clipsimmat(C,i);
        A(:,i) = []; % A is a different guy
        %A = padarray(A,[0 1],'post'); %A is indeed a different guy
        C_age = clipsimmat(C_age,i);
        h = clipvect(h,i);
        r = r-1;
        break%hack: this will only remove 1 node per iteration
    end
    %I gave up on the idea of zeroing everything after this. seems
    %unnecessary...
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

