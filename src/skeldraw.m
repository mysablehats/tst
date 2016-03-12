function A = skeldraw(varargin)
%makes a beautiful skeleton of the 75 dimension vector
%or the 25x3 skeleton or random crazy skeletons of the 25 points type...
%will improve to draw the 20 point one...
% plot the nodes
%reconstruct the nodes from the 75 dimension vector. each 3 is a point
%I use the NaN interpolation to draw sticks which is much faster!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%MESSAGES PART
%dbgmsg('This function is very often called in drawing functions and this message will cause serious slowdown.',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(varargin)==1
    doIdraw = true;
    skel = varargin{1};
elseif length(varargin)==2
    skel = varargin{1};
    doIdraw = varargin{2};
else
    error('too many input arguments, don''t know what to do with all of them!')

end

tdskel = makefatskel(skel);

%check size of tdskel
% there are many different possibilities here, but the size might be enough
% to tell what is happening
%if > 50 then it has to have small paths. I will draw just the first
%then...
%if == 49 then it has velocities, I will also take those out

if size(tdskel,1) > 25
    %have to remove all the n*25 parts from the end 
    tdskel = tdskel(1:end-(size(tdskel,1)/25-1)*25,:);
end

if size(tdskel,1) == 24
    tdskel = [[0 0 0 ];tdskel];
elseif size(tdskel,1) < 24
    error('Don''t know what to do weird size :-( ')
end

A = stick_draw(tdskel);

if doIdraw ==true 
    hold_initialstate = ishold();
    plot3(tdskel(:,1), tdskel(:,2), tdskel(:,3),'.y','markersize',15); view(0,0); axis equal;
    hold on
    for k=1:25 % I used this to make the drawings, but now I think it looks cool and I don't want to remove it
        text(tdskel(k,1), tdskel(k,2), tdskel(k,3),num2str(k))
    end
    plot3(A(1,:),A(2,:), A(3,:))
    hold off
    if hold_initialstate == 1
        hold on
    end
   
end
end

function a = stick_draw(tdskel)

%
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

a = draw_1_stick(tdskel, 1,2);
%draw_1_stick(tdskel, 2,3)
a= [a draw_1_stick(tdskel, 2,21)];
a= [a draw_1_stick(tdskel, 21,3)];
a= [a draw_1_stick(tdskel, 3,4)];

a= [a draw_1_stick(tdskel, 5,21)];
a= [a draw_1_stick(tdskel, 21,9)];

a= [a draw_1_stick(tdskel, 5,6)];
a= [a draw_1_stick(tdskel, 6,7)];

a= [a draw_1_stick(tdskel, 7,8)]; % unsure

a= [a draw_1_stick(tdskel, 8,22)];
a= [a draw_1_stick(tdskel, 22,23)]; % unsure
a= [a draw_1_stick(tdskel, 8,23)]; % unsure

a= [a draw_1_stick(tdskel, 9,10)];
a= [a draw_1_stick(tdskel, 10,11)];

a= [a draw_1_stick(tdskel, 11,12)]; % unsure
a= [a draw_1_stick(tdskel, 12,24)];
a= [a draw_1_stick(tdskel, 12,25)]; % unsure
a= [a draw_1_stick(tdskel, 24,25)];
a= [a draw_1_stick(tdskel, 13,1)];
a= [a draw_1_stick(tdskel, 1,17)];
a= [a draw_1_stick(tdskel, 13,17)]; % draw a thick hip, because we like hips

a= [a draw_1_stick(tdskel, 13,14)];
a= [a draw_1_stick(tdskel, 14,15)];
a= [a draw_1_stick(tdskel, 15,16)];
a= [a draw_1_stick(tdskel, 17,18)];
a= [a draw_1_stick(tdskel, 18,19)];
a= [a draw_1_stick(tdskel, 19,20)];

end

function A = draw_1_stick(tdskel, i,j)
A = [[tdskel(i,1) tdskel(j,1) NaN]; [tdskel(i,2) tdskel(j,2) NaN]; [tdskel(i,3) tdskel(j,3) NaN]];
end
