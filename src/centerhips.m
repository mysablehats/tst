function newskel = centerhips(skel)
%%%% reshape skeleton
if all(size(skel) == [75 1]) % checks if the skeleton is a 75x1
    tdskel = zeros(25,3);
    for i=1:3
        for j=1:25
            tdskel(j,i) = skel(j+25*(i-1));
        end
    end
else
        tdskel = skel;
end
hips = tdskel(1,:); 
newskel = zeros(size(tdskel));
for i = 1:25
    newskel(i,:) = tdskel(i,:)- 1*hips;
end
%I need to shape it back into 75 x 1
newskel = [newskel(:,1);newskel(:,2);newskel(:,3)]; % I think....
%disp('hello')