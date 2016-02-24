function newskel = centerhips(skel)
%%%%%%%%%MESSAGES PART
dbgmsg('Removing displacement based on hip coordinates (1st point on 25x3 skeleton matrix) from every other')
dbgmsg('This makes the dataset translation invariant')
%%%%%%%%%%%%%%%%%%%%%

%%%% reshape skeleton
if all(size(skel) == [75 1]) % checks if the skeleton is a 75x1
    tdskel = zeros(25,3);
    for i=1:3
        for j=1:25
            tdskel(j,i) = skel(j+25*(i-1));
        end
    end
elseif all(size(skel) == [150 1])
    tdskel = zeros(50,3);
    for i=1:3
        for j=1:50
            tdskel(j,i) = skel(j+25*(i-1));
        end
    end
elseif all(size(skel) == [25 3])
        tdskel = skel;
else
    error('Do not know this size of skeleton yet!')
end
hips = tdskel(1,:); 
newskel = zeros(size(tdskel)-[1 0]);
for i = 2:25
    newskel(i-1,:) = tdskel(i,:)- 1*hips;
end
%I need to shape it back into 75(-3 now) x 1
newskel = [newskel(:,1);newskel(:,2);newskel(:,3)]; % I think....
if ~(all(size(newskel) == [72 1])||all(size(newskel) == [147 1]))
    error('wrong skeleton size!')
end