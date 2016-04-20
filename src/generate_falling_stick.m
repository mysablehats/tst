function allskel = generate_falling_stick(numsticks)

for kk = 1:numsticks
    num_of_points_in_stick = 25;
    
    %%% random size
    %%% random start location
    %%% random initial velocity for falling stick
    
    
    l = (1.6+rand()*.3)*100;
    
    for akk = [0,1]
        startlocation = 150*[rand(), rand(), rand()];
        phi = 2*pi*rand();
        initial_velocity = -1*rand();
        if akk
            act = 'Fall';
            % from http://www.chem.mtu.edu/~tbco/cm416/MatlabTutorialPart2.pdf and
            % from http://ocw.mit.edu/courses/mechanical-engineering/2-003j-dynamics-and-control-i-spring-2007/lecture-notes/lec10.pdf
            % the equation from the falling stick is
            %
            % -m*g*l/2*cos(t) = (Ic+m*l^2/4*cos(t)^2)*tdd - m*l^2/4*cos(t)*sin(t*td^2)
            %
            % tdd = diff(td)
            % td = diff(t)
            
            testOptions = odeset('RelTol',1e-3,'AbsTol', [1e-4; 1e-2]);
            [t,x] =     ode45(@stickfall, [0 2], [pi/2;initial_velocity], testOptions);
            
            %%% resample to kinect average sample rate, i.e. 15 or 30 hz
            x = resample(x,t,30);
            
            [skel, vel] = construct_skel(x,l,num_of_points_in_stick ,startlocation, phi);
            
        else
            act = 'Stand';
            %%% non falling activity
            x = ones(100,2)*[[pi/2 0];[0 0]]; % does it even make sense if the velocity changes and the position does not?
            [skel, vel] = construct_skel(x, l, num_of_points_in_stick, startlocation, phi);
            
        end
        %for i = 1:s
        construct_sk_struct = struct('x',x,'l',l,'num_points', num_of_points_in_stick,'startlocation',startlocation,'phi',phi);
        jskelstruc = struct('skel',skel,'act_type', act, 'index', kk, 'subject', kk,'time',[],'vel', vel, 'construct_sk_struct', construct_sk_struct);
        
        %plot(stickstick(:,1), stickstick(:,2), '*')
        if exist('allskel','var') % initialize my big matrix of skeletons
            allskel = cat(2,allskel,jskelstruc);
        else
            allskel = jskelstruc;
        end
    end
end
end
function dx = stickfall(t,x)

m = 1;
g = 9.8;
l = 1.6;
t = 0;

Ic = 1/3*m*l^2;%% for a slender rod rotating on one end

x1 = x(1);
x2 = x(2);

% state equations
% I can put any nonlinearilty I want, so I will make so that when  x1 == 0
% or x1 = pi, then the velocity changes sign, i.e. it bounces

if ((x1 < 0)&&x2<0)||((x1> pi)&&x2>0)
    dx1 = -0.5*x2; %so that it dampens as well
else
    dx1 = x2;
end

dx2 = (m*l^2/4*cos(x1*x2^2) -m*g*l/2*cos(x1))/(Ic+m*l^2/4*cos(x1)^2);

dx = [dx1;dx2];

end
function [stickstick,stickvel] = construct_skel(thetha, l, num_of_points_in_stick, displacement, phi)

bn = [rand(), rand(), rand()]/1000; %% I need a bit of noise or the classifier gets insane

simdim = size(thetha(:,1),1);

stickstick = zeros(num_of_points_in_stick,3,simdim);
stickvel = stickstick; %%%

for i=1:simdim
    stickstick(1,:,i) = displacement;
    for j = 2:num_of_points_in_stick
        stickstick(j,:,i) = ([cos(thetha(i,1))*cos(phi), sin(thetha(i,1)), cos(thetha(i,1))*sin(phi)]+bn)*l*j/num_of_points_in_stick+ displacement;
    end
end
%%% the initial velocities are not zero; so lets set the right results

%stickvel(1,:,1) = [0,0,0];
for j = 1:num_of_points_in_stick
    stickvel(j,:,1) = [cos(thetha(1,2))*cos(phi), sin(thetha(1,2)), cos(thetha(1,2))*sin(phi)]*l*j/num_of_points_in_stick;
end

%%% for the next ones I will calculate the points
for i = 2:simdim
    stickvel(:,:,i-1) = stickstick(:,:,i)-stickstick(:,:,i-1);
end

%stickstick; % ok, I forgot that the reshape happens latter %reshape(stickstick,[],simdim);


end