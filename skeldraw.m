% plot the nodes
%reconstruct the nodes from the 75 dimension vector. each 3 is a point
function skeldraw(skel)
tdskel = zeros(25,3);
for i=1:3
    for j=1:25
        tdskel(j,i) = skel(j+25*(i-1));
    end
end

plot3(tdskel(:,1), tdskel(:,2), tdskel(:,3),'.y','markersize',15); view(0,0); axis equal;
hold on
for k=1:25
    text(tdskel(k,1), tdskel(k,2), tdskel(k,3),num2str(k))
end
stick_draw(tdskel)
hold off
end

function stick_draw(tdskel)

%%
%in the end the end the text command upstairs was what did the job and I
%wrote down the connection of the skeleton points
%it is as follows:
% 1-2-21-3 torso
% 3-4 head
%
% 5-6-7 right arm
% 8 22 23 right hand
% 
% 9-10-11 left arm
% 12 24 25 left hand
%
% 5-21-9 shoulder
%
% 13-1-17 hip
%
% 13-14-15 right leg
% 15-16 right foot
%
% 17-18-19 left leg
% 19-20 left foot

draw_1_stick(tdskel, 1,2)
%draw_1_stick(tdskel, 2,3)
draw_1_stick(tdskel, 2,21)
draw_1_stick(tdskel, 21,3)
draw_1_stick(tdskel, 3,4)

draw_1_stick(tdskel, 5,21)
draw_1_stick(tdskel, 21,9)

draw_1_stick(tdskel, 5,6)
draw_1_stick(tdskel, 6,7)

draw_1_stick(tdskel, 7,8) % unsure

draw_1_stick(tdskel, 8,22)
draw_1_stick(tdskel, 22,23) % unsure
draw_1_stick(tdskel, 8,23) % unsure

draw_1_stick(tdskel, 9,10)
draw_1_stick(tdskel, 10,11)

draw_1_stick(tdskel, 11,12) % unsure
draw_1_stick(tdskel, 12,24)
draw_1_stick(tdskel, 12,25) % unsure
draw_1_stick(tdskel, 24,25)
draw_1_stick(tdskel, 13,1)
draw_1_stick(tdskel, 1,17)
draw_1_stick(tdskel, 13,17) % draw a thick hip, because we like hips

draw_1_stick(tdskel, 13,14)
draw_1_stick(tdskel, 14,15)
draw_1_stick(tdskel, 15,16)
draw_1_stick(tdskel, 17,18)
draw_1_stick(tdskel, 18,19)
draw_1_stick(tdskel, 19,20)
%%
% here only because this 
%go through the whole set to find adequate conections
%a = length(tdskel);
%sticks = zeros(2, 3,a*a);
%jj=0;
%for i=1:a
%    for j=(i+1):a %ugly, I know
%        jj=jj+1;
%        [tdskel(i,:); tdskel(j,:)];
%        sticks(:,:,jj) = [tdskel(j,:); tdskel(i,:)];
%    end
%end
%stick = zeros(2,3,24);
%st = 0; %counter for the 24 sticks
%for k = 1:a*a
%    plot3(tdskel(:,1), tdskel(:,2), tdskel(:,3),'.b','markersize',20); view(0,0); axis equal;
%    line(sticks(:,1,k),sticks(:,2,k),sticks(:,3,k))
%    [sticks(:,1,k),sticks(:,2,k),sticks(:,3,k)]
%    addline = input('Is this stick right? [N]', 's');
%    if ~isempty(addline)&&addline=='y'
%        st = st+1;
%        stick(:,:,st) = [sticks(:,1,k),sticks(:,2,k),sticks(:,3,k)]; %this is probably unnecessaryly complex indexing
%    elseif ~isempty(addline)&&addline=='q'
%        break
%    end
%    
%end
%stick

end

function stickman(tdskel,limbmat)
end
function draw_1_stick(tdskel, i,j)
line([tdskel(i,1) tdskel(j,1)], [tdskel(i,2) tdskel(j,2)], [tdskel(i,3) tdskel(j,3)]) 
end
