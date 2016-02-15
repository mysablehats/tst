%makes a beautiful skeleton of the 75 dimension vector
%or the 25x3 skeleton
% plot the nodes
%reconstruct the nodes from the 75 dimension vector. each 3 is a point
function skeldraw(skel)
hold_initialstate = ishold();

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

plot3(tdskel(:,1), tdskel(:,2), tdskel(:,3),'.y','markersize',15); view(0,0); axis equal; 
hold on
for k=1:25 % I used this to make the drawings, but now I think it looks cool and I don't want to remove it
    text(tdskel(k,1), tdskel(k,2), tdskel(k,3),num2str(k))
end
stick_draw(tdskel)
hold off
if hold_initialstate == 1
    hold on
end
   
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

end

function draw_1_stick(tdskel, i,j)
line([tdskel(i,1) tdskel(j,1)], [tdskel(i,2) tdskel(j,2)], [tdskel(i,3) tdskel(j,3)]) 
end
