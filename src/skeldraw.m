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
A = [];
if length(varargin)==1
    doIdraw = true;
    skel = varargin{1};
    swoosh = false;
elseif length(varargin)==2
    skel = varargin{1};
    doIdraw = varargin{2};
    swoosh = false;
elseif nvargin==3
    skel = varargin{1};
    doIdraw = varargin{2};
    swoosh = varargin{3};
else
    error('too many input arguments, don''t know what to do with all of them!')
    
end

if size(skel,2) ~=1&&size(skel,3) ==1&&size(skel,1)>=45
    if doIdraw % if you want to draw you care about pretty, but not speed, I assume...
        % the fast way is create first the A matrix and then do::
        % plot3(A(1,:),A(2,:), A(3,:)) % so no numbered skeletons if drawing a set :-(
        for i = 1:size(skel,2)
            skeldraw(skel(:,i),true,swoosh); % I perhaps should use the fast way, but I am lazy, so I may do this in the future
        end
    else
        A = skeldraw(skel(:,1),false,swoosh);
        for i = 2:size(skel,2)
            A = cat(2, A, skeldraw(skel(:,i),false,swoosh)); % I perhaps should use the fast way, but I am lazy, so I may do this in the future
        end
    end
elseif size(skel,2) ==3&&size(skel,3) ==1 
    %%% this must mean that it is already fat
    tdskel = skel;
    A = drawcore(tdskel, doIdraw,swoosh);
elseif size(skel,2) ==3&&size(skel,3) >1 %wow such confuse, very mess
    %%% it is fat AND a sequence
    hold on
    for i = 1:(size(skel,3)-1)
        skeldraw(skel(:,:,[i i+1]),doIdraw,swoosh); % I perhaps should use the fast way, but I am lazy, so I may do this in the future
    end
    hold off
elseif size(skel,2) ==1 %% then it is thin
    tdskel = makefatskel(skel);
    A = drawcore(tdskel, doIdraw,swoosh);
end

end
function A = drawcore(tdskel, doIdraw,swoosh)
    %check size of tdskel
    % there are many different possibilities here, but the size might be enough
    % to tell what is happening
    %if > 50 then it has to have small paths. I will draw just the first
    %then...
    %if == 49 then it has velocities, I will also take those out
    
    if size(tdskel,1) > 25
        %have to remove all the n*25 parts from the end
        wheretoclip = mod(size(tdskel,1),25);
        if wheretoclip==0
            wheretoclip = 25;
        end
        tdskel = tdskel(1:wheretoclip,:);
    end
    
    if size(tdskel,1) == 24
        tdskel = [[0 0 0 ];tdskel]; % for the hips
        %tdskel = [tdskel(1:20,:);[0 0 0 ];tdskel(21:end,:)]; % for the thorax
    elseif size(tdskel,1) < 24
        error('Don''t know what to do weird size :-( ')
    end
    if size(tdskel,2) ==2&&swoosh
     moresticks = [];
    
    %moresticks = zeros(3,3*size(row));
    for i=1:size(tdskel,1)
        for j=1:2
            moresticks = cat(2,moresticks,[tdskel(i,:,j);tdskel(i,:,j); [NaN NaN NaN]]');
        end
    end
    
    SK = skeldraw(A(:,1),0);
    for i = 2:size(A,2)
       SK = [SK skeldraw(A(:,i),0)];      
    end
    T = [SK moresticks];
    
    % make A into a sequence of 3d points
    A = threedeeA(A);   
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
%a= [a draw_1_stick(tdskel, 5,9)]; %%%% just to draw the thorax thing 

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
