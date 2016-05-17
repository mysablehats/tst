function [conformstruc, skelldef] = conformskel(varargin )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Applies normalizations of several sorts on both training and validation datasets',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test = false;

%%% Since some of the normalizations will change the size of the data-set
%%% it is sensible to put them all in the same place where this can be
%%% controlled.
skelldef = struct();

if isempty(varargin)||strcmp(varargin{1},'test')
    if length(varargin)>1
        conformstruc = conformskel_test(varargin{2:end}); %%% I've decided to put the testing procedure here to keep things cleaner
    else
        conformstruc = conformskel_test();
    end
else
    
    if isstruct(varargin{1})
        conformstruc = varargin{1};
        data_train = conformstruc.train.data;
        data_val = conformstruc.val.data;
        data_ytrain = conformstruc.train.y ;
        data_yval = conformstruc.val.y;
        
        if isfield(conformstruc,'awk')
            awk = conformstruc.awk;
        else
            awk = ones(size(data_val,1)/6,1);
            dbgmsg('awk not defined. considering all joints as having equal importance.',1)
        end
        lindx = 2;
    else    
    data_train = varargin{1};
    data_val = varargin{2};
    %awk = generate_awk;
    if isnumeric(varargin{3})
        awk = varargin{3};
        lindx = 4;
    elseif ischar(varargin{3})
        awk = ones(size(data_val,1)/6,1);
        lindx = 3;
        dbgmsg('awk not defined. considering all joints as having equal importance.',1)
    else
        error('Strange input. I don''t know what to do with it. ')
    end
    end
    %%% initiallize variables to make skelldef
    killdim = [];
    skelldef.length = size(data_val,1);
    skelldef.realkilldim = [];
    skelldef.elementorder = 1:skelldef.length;
    skelldef.awk.pos = repmat(awk(setdiff(1:skelldef.length/6,killdim)),3,1);
    skelldef.awk.vel = repmat(awk(setdiff(1:skelldef.length/6,killdim)),3,1);
    
    %%%
    skelldef.bodyparts = genbodyparts(skelldef.length);
    
    %%%errorkarling
    if size(data_train)~=skelldef.length
        error('data_train and data_val must have the same length!!!')
    end
    if any(size(awk).*[6 1]~= size(data_val(:,1)))
        warning('wrong size for awk. It should be the same size of the input data. maybe you should transpose it?')
    end
    
    %%%further checks?
    
    %     if size(data_val,1)==90&&~(nargin==4&&strcmp(varargin{4},'mirror'))
    %     dbgmsg('The skeleton transformations are defined with a specific order and that only works for a skeleton with 25 points. Anything different crashes, so I will do nothing.',1)
    %     %%% but I still need to exit the variables and create the skeleton
    %     %%% definition...
    %     [skelldef.pos, skelldef.vel] = generateidx(skelldef.length, skelldef);
    %     conform_train = data_train;
    %     conform_val = data_val;
    %     return
    %     end
    
    % creates the function handle cell array
    conformations = {};
    killdim = [];
    
    for i =lindx:length(varargin)
        switch varargin{i}
            case 'test'
                test = true;
            case 'highhips'
                conformations = [conformations, {@highhips}];
            case 'nohips'
                conformations = [conformations, {@centerhips}];
                killdim = [killdim, skelldef.bodyparts.hip_center];
            case 'normal'
                conformations = [conformations, {@normalize}];
                
                %dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'mirrorx'
                conformations = [conformations, {@mirrorx}];
            case 'mirrory'
                conformations = [conformations, {@mirrory}];
            case 'mirrorz'
                conformations = [conformations, {@mirrorz}];
            case 'mahal'
                %conformations = [conformations, {@mahal}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'norotate'
                conformations = [conformations, {@norotatehips}];
                dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
            case 'norotateshoulders'
                conformations = [conformations, {@norotateshoulders}];
                dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
            case 'notorax'
                conformations = [conformations, {@centertorax}];
                dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                killdim = [killdim, skelldef.bodyparts.TORSO];
            case 'nofeet'
                conformations = [conformations, {@nofeet}]; %not sure i need this...
                killdim = [killdim, skelldef.bodyparts.RIGHT_FOOT, skelldef.bodyparts.LEFT_FOOT];
            case 'nohands'
                dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                killdim = [killdim, skelldef.bodyparts.RIGHT_HAND, skelldef.bodyparts.LEFT_HAND];
            case 'axial'
                %conformations = [conformations, {@axial}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'addnoise'
                conformations = [conformations, {@abnormalize}];
            case 'spherical'
                conformations = [conformations, {@to_spherical}];
            case 'intostick'
                conformations = [conformations, {@intostick}];
                killdim = [4:(skelldef.length/6) (skelldef.length/6+4):(skelldef.length/3) ];
            case 'intostick2'
                conformations = [conformations, {@intostick2}];
                killdim = [4:(skelldef.length/6) (skelldef.length/6+4):(skelldef.length/3) ];
            otherwise
                dbgmsg('ATTENTION: Unimplemented normalization/ typo.',varargin{i},true);
        end
    end
    
    % execute them for training and validation sets
    if ~isempty(skelldef.bodyparts)
        for i = 1:length(conformations)
            func = conformations{i};
            dbgmsg('Applying normalization: ', varargin{i+lindx-1},true);
            if isequal(func, @mirrorx)||isequal(func,@mirrory)||isequal(func, @mirrorz)
                data_trainmirror = data_train;
                data_valmirror = data_val;
                data_ytrainmirror = data_ytrain;
                data_yvalmirror = data_yval;
            else
                data_trainmirror = [];
                data_valmirror = [];
                data_ytrainmirror = [];
                data_yvalmirror = [];
            end
            
            if isequal(func,@normalize)
                    %%% must go through whole dataset!
                    %%% if there is ever another function that requires this,
                    %%% then I should probably use a switch - if that works...
                    allskels = makefatskel(data_train);
                    %%% calculating the magic constants for our data
                    vectdata_pos = reshape(allskels(1:skelldef.length/6,:,:),1,[]);
                    skelldef.pos_std = std(vectdata_pos);
                    skelldef.pos_mean=mean(vectdata_pos);
                    vectdata_vel = reshape(allskels((skelldef.length/6+1):end,:,:),1,[]);
                    skelldef.vel_std = std(vectdata_vel);
                    skelldef.vel_mean=mean(vectdata_vel);
                    %                 case {@mirrorx,@mirrory,@mirrorz}
                    %                     data_trainmirror = data_train;
                    %                     data_valmirror = data_val;
            end
            for j = 1:size(data_train,2)
                data_train(:,j) = func(data_train(:,j), skelldef);
            end
            for j = 1:size(data_val,2)
                data_val(:,j) = func(data_val(:,j), skelldef);
            end
            data_train = [data_train data_trainmirror];
            data_val = [data_val data_valmirror];
            data_ytrain = [data_ytrain data_ytrainmirror];
            data_yval = [data_yval data_yvalmirror];
        end
    end
    % squeeze them accordingly?
    if ~test
        whattokill = reshape(1:skelldef.length,skelldef.length/3,3);
        realkilldim = whattokill(killdim,:);
        conform_train = data_train(setdiff(1:skelldef.length,realkilldim),:); %sorry for the in-liners..
        conform_val = data_val(setdiff(1:skelldef.length,realkilldim),:);
        skelldef.elementorder = skelldef.elementorder(setdiff(1:skelldef.length,realkilldim));
        %%% awk
        skelldef.awk.pos = repmat(awk(setdiff(1:skelldef.length/6,killdim)),3,1);
        skelldef.awk.vel = repmat(awk(setdiff(1:skelldef.length/6,killdim)),3,1);
    else
        conform_train = data_train;
        conform_val = data_val;
    end

%conform_train, conform_val
conformstruc.train.data = conform_train;
conformstruc.val.data = conform_val;    
    
end
skelldef.realkilldim = realkilldim;
[skelldef.pos, skelldef.vel] = generateidx(skelldef.length, skelldef);

end
function newskel = centerhips(skel, skelldef)

bod = skelldef.bodyparts;

[tdskel,hh] = makefatskel(skel);

if isempty(bod.hip_center)&&hh==30
    %%% then this possibly it is the 15 joint skeleton
    hip = (tdskel(bod.LEFT_HIP,:) + tdskel(bod.RIGHT_HIP,:))/2;
else
    hip = tdskel(bod.hip_center,:);
    
end

hips = [repmat(hip,hh/2,1);zeros(hh/2,3)]; % this is so that we dont subtract the velocities

newskel = tdskel - hips;

%I need to shape it back into 75(-3 now) x 1
newskel = makethinskel(newskel);
end
function newskel = highhips(skel, skelldef)

bod = skelldef.bodyparts;

[tdskel,hh] = makefatskel(skel);

if isempty(bod.hip_center)&&hh==30
    %%% then this possibly it is the 15 joint skeleton
    hip = (tdskel(bod.LEFT_HIP,:) + tdskel(bod.RIGHT_HIP,:))/2;
else
    hip = tdskel(bod.hip_center,:);
    
end
hip(1,2) = 0; %%

hips = [repmat(hip,hh/2,1);zeros(hh/2,3)]; % this is so that we dont subtract the velocities

newskel = tdskel - hips;

%I need to shape it back into 75(-3 now) x 1
newskel = makethinskel(newskel);
end
function newskel = centertorax(skel, skelldef)

bod = skelldef.bodyparts;

[tdskel,hh] = makefatskel(skel);

torax = [repmat(tdskel(bod.TORSO,:),hh/2,1);zeros(hh/2,3)];

newskel = tdskel - torax;

newskel = makethinskel(newskel);
end
function newskel = norotatehips(skel, skelldef)

bod = skelldef.bodyparts;
[tdskel,hh] = makefatskel(skel);

%%%%some normalization procedure %%%%%
% I will consider the rotation of the hips because it is simpler to think
% about, since I have normalized the skeleton to a neutral position around
% the hips already
% according to my notes, they are the points 17(RHip) 13(LHip) around point
% 1
% if hh == 25 || hh == 50
rvec = tdskel(bod.RIGHT_HIP,:)-tdskel(bod.LEFT_HIP,:);
% elseif hh == 24 || hh == 49
%     rvec = tdskel(16,:)-tdskel(12,:);
% else
%     rvec = [1 0 0];
%     dbgmsg('Don''t know how to un-rotate this. Doing nothing')
% end


rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
for i = 1:hh
    tdskel(i,:) = (rotmat*tdskel(i,:)')';
end

newskel = makethinskel(tdskel);
end
function newskel = norotateshoulders(skel, skelldef)

bod = skelldef.bodyparts;
[tdskel,hh] = makefatskel(skel);

%%%%some normalization procedure %%%%%
% I will consider the rotation of the shoulders as the most important for a
% person,
%according to my notes, they are the points 5(RS) 9(LS) and 21 Upper torax
% if hh == 25 || hh == 50
rvec = tdskel(bod.LEFT_SHOULDER,:)-tdskel(bod.LEFT_SHOULDER,:);
% elseif hh == 24 || hh == 49
%     rvec = tdskel(5,:)-tdskel(9,:); % dumbass
% else
%     rvec = [1 0 0];
%     dbgmsg('Don''t know how to un-rotate this. Doing nothing')
% end

rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
for i = 1:hh
    tdskel(i,:) = (rotmat*tdskel(i,:)')';
end

newskel = makethinskel(tdskel);
end
function newskel = abnormalize(skel, ~)
% [tdskel,hh] = makefatskel(skel);

%%%%some conformation procedure %%%%%
% if hh == 25
newskel = skel + rand(size(skel));

%    tdskel = tdskel + rand(size(tdskel));
% else
%     dbgmsg('Don''t know how to un-abnormalize this. Doing nothing')
% end

%newskel = makethinskel(tdskel);
end
function newskel = nofeet(skel, skelldef)

bod = skelldef.bodyparts;
[tdskel,hh] = makefatskel(skel);

%%%%some conformation procedure %%%%%
% if mod(hh,25) == 0 % I will remove this and make a smaller skeleton, but first I will zero-it
%     tdskel(16,:) = zeros(1,size(tdskel,2));
%     tdskel(20,:) = zeros(1,size(tdskel,2));
% elseif mod(hh,25) == 24
%     tdskel(15,:) = zeros(1,size(tdskel,2));
%     tdskel(19,:) = zeros(1,size(tdskel,2));
% else
%     dbgmsg('Don''t know how to remove feet from this. Doing nothing')
% end
%%% following my older-self's advice I will also invalidate what I remove, but with NaNs
sizeofnans = size(tdskel([bod.RIGHT_FOOT, bod.LEFT_FOOT],:));

tdskel([bod.RIGHT_FOOT, bod.LEFT_FOOT],:) = NaN(sizeofnans);

newskel = makethinskel(tdskel);
end
function newskel = mirrorx(skel, ~)
[tdskel,~] = makefatskel(skel);

%%%%some conformation procedure %%%%%
tdskel(:,1) = -tdskel(:,1);

newskel = makethinskel(tdskel);
end
function newskel = mirrory(skel, ~)
[tdskel,~] = makefatskel(skel);

%%%%some conformation procedure %%%%%
tdskel(:,2) = -tdskel(:,2);

newskel = makethinskel(tdskel);
end
function newskel = mirrorz(skel, ~)
[tdskel,~] = makefatskel(skel);

%%%%some conformation procedure %%%%%
tdskel(:,3) = -tdskel(:,3);

newskel = makethinskel(tdskel);
end
function newskel = normalize(skel, skelldef)
%%this function was developed by inspection. a random skeleton was used
%just to make sure that the variables are in similar orders of magnitude.
%The average std deviation from the skeletons computed as
%mean(mean(std(allskels(1:25,:,:)))) was 233.5180 for the whole tst dataset of skeletons whereas for
%the speeds computed as mean(mean(std(allskels(26:end,:,:)))) it was 5.5481e-05
%magic constants will be used in order to make both these numbers close to
%1 as possible

[tdskel,hh] = makefatskel(skel);

for i = 1:hh/2
    tdskel(i,:) = (tdskel(i,:) - skelldef.pos_mean)/skelldef.pos_std; %- skelldef.pos_mean
end
for i = (hh/2+1):hh
    tdskel(i,:) = (tdskel(i,:) - skelldef.vel_mean)/skelldef.vel_std;%- skelldef.vel_mean
end
% %%%% this can actually deal with datasets without velocities. I am leaving
% %%%% this here in case I ever want to reference it...
% magicconstant1 = 2.951426379619558e+02;
% magicconstant2 = 1.401162861741577e-04;
% %%%%some conformation procedure %%%%%
% if hh == 24
%     tdskel = tdskel/magicconstant1;
% elseif hh>=25
%     for i = 1:25
%         tdskel(i,:) = tdskel(i,:)/magicconstant1;
%     end
% else
%     dbgmsg('Don''t know how to normalize this. Doing nothing')
% end
% if hh>=26 %then there is velocities, right?
%     for i = 26:hh
%         tdskel(i,:) = tdskel(i,:)/magicconstant2;
%     end
% end

newskel = makethinskel(tdskel);
end
function newskel = to_spherical(skel, ~)

[tdskel,~] = makefatskel(skel);

newskel = zeros(size(tdskel));

[newskel(:,1),newskel(:,2),newskel(:,3)] = cart2sph(tdskel(:,1),tdskel(:,2),tdskel(:,3));

newskel = makethinskel(newskel);
end
function newskel = intostick(skel, skelldef)

bod = skelldef.bodyparts;

[tdskel,hh] = makefatskel(skel);

%disp('ok')
UCI = [bod.HEAD bod.NECK bod.LEFT_SHOULDER  bod.RIGHT_SHOULDER bod.LEFT_ELBOW bod.RIGHT_ELBOW bod.LEFT_HAND bod.RIGHT_HAND  ];

uppercentroid = mean(tdskel(UCI ,:));

uppercentroidvel  = mean(tdskel(UCI+hh/2,:));

middlecentroid = tdskel(bod.TORSO,:);

middlecentroidvel = tdskel(bod.TORSO+hh/2,:);

LCI = [bod.LEFT_FOOT bod.RIGHT_FOOT bod.LEFT_KNEE bod.RIGHT_KNEE bod.LEFT_HIP bod.RIGHT_HIP];

lowercentroid =mean(tdskel(LCI,:));

lowercentroidvel =mean(tdskel(LCI+hh/2,:));

zeroskel = zeros(size(tdskel));

zeroskel(1:3,:) = [uppercentroid;middlecentroid;lowercentroid];
zeroskel((hh/2+1):(hh/2+3),:) = [uppercentroidvel;middlecentroidvel;lowercentroidvel];

newskel = makethinskel(zeroskel);
end
function newskel = intostick2(skel, skelldef)

bod = skelldef.bodyparts;

[tdskel,hh] = makefatskel(skel);

%disp('ok')
UCI = [bod.HEAD bod.NECK bod.LEFT_SHOULDER  bod.RIGHT_SHOULDER bod.LEFT_ELBOW bod.RIGHT_ELBOW  ];

uppercentroid = mean(tdskel(UCI ,:));

uppercentroidvel  = mean(tdskel(UCI+hh/2,:));

middlecentroid = tdskel(bod.TORSO,:);

middlecentroidvel = tdskel(bod.TORSO+hh/2,:);

LCI = [ bod.LEFT_KNEE bod.RIGHT_KNEE bod.LEFT_HIP bod.RIGHT_HIP];

lowercentroid =mean(tdskel(LCI,:));

lowercentroidvel =mean(tdskel(LCI+hh/2,:));

zeroskel = zeros(size(tdskel));

zeroskel(1:3,:) = [uppercentroid;middlecentroid;lowercentroid];
zeroskel((hh/2+1):(hh/2+3),:) = [uppercentroidvel;middlecentroidvel;lowercentroidvel];

newskel = makethinskel(zeroskel);
end
function [a,b] = conformskel_test(varargin)
load_test_skel

wholelist  = {'nohips' 'normal' 'mahal' 'norotate' 'norotateshoulders' 'nofeet' 'axial'};

%error('not implemented yet')

b = a(:,1);
a = a(:,:);


sameplace = false;

if isempty(varargin)
    iterateover = wholelist;
else
    iterateover = varargin;
end

if sameplace
    figure(1)
    hold on
    skeldraw(a,true);
    skeldraw(b,true);
    
    for i = 1:length(iterateover)
        try
            [a, b] = conformskel(a,b,iterateover{i},'test');
            figure(i)
            skeldraw(a,true);
            skeldraw(b,true);
            
            figure(i+1)
            hold on
            skeldraw(a,true);
            skeldraw(b,true);
            
            %size(a)
            %size(b)
        catch ME
            disp(strcat('Method ',iterateover{i},' not successful'))
        end
    end
else
    figure(1)
    skeldraw(a,true);
    figure(2)
    skeldraw(b,true);
    for i = 1:length(iterateover)
        try
            
            [a, b] = conformskel(a,b,iterateover{i},'test');
            figure(i*2-1)
            hold on
            skeldraw(a,true);
            figure(i*2)
            hold on
            skeldraw(b,true);
            
            figure(i*2+1)
            hold on
            skeldraw(a,true);
            figure(i*2+2)
            hold on
            skeldraw(b,true);
            
            %size(a)
            %size(b)
        catch ME
            disp(strcat('Method ',iterateover{i},' not successful'))
        end
    end
end
end
function bodyparts = genbodyparts(lenlen)
bodyparts = struct();
switch lenlen
    case 150
        bodyparts.hip_center = 1;
        bodyparts.abdomen = 2;
        bodyparts.neck_or_something = 3;
        bodyparts.tip_of_the_head = 4;
        bodyparts.right_shoulder = 5;
        bodyparts.right_also_shoulder_or_elbow = 6;
        bodyparts.right_elbow_maybe = 7;
        bodyparts.right_hand = 8;
        bodyparts.left_shoulder = 9;
        bodyparts.left_something_maybe_elbow = 10;
        bodyparts.left_maybe_elbow = 11;
        bodyparts.left_hand = 12;
        bodyparts.left_hip = 13;
        bodyparts.left_knee = 14;
        bodyparts.left_part_of_foot = 15;
        bodyparts.left_tip_of_foot = 16;
        bodyparts.right_hip_important_because_hips_dont_lie = 17;
        bodyparts.right_knee = 18;
        bodyparts.right_part_of_foot = 19;
        bodyparts.right_tip_of_foot = 20;
        bodyparts.middle_of_upper_torax = 21;
        bodyparts.right_some_part_of_the_hand = 22;
        bodyparts.right_some_other_part_of_the_hand = 23;
        bodyparts.left_some_part_of_the_hand = 24;
        bodyparts.left_some_other_part_of_the_hand = 25;
        %%% synonyms
        bodyparts.NECK = bodyparts.neck_or_something;
        bodyparts.RIGHT_HIP = bodyparts.right_hip_important_because_hips_dont_lie;
        bodyparts.LEFT_HIP = bodyparts.left_hip;
        
        bodyparts.LEFT_SHOULDER = bodyparts.left_shoulder;
        bodyparts.RIGHT_SHOULDER = bodyparts.right_shoulder;
        
        bodyparts.LEFT_ELBOW = bodyparts.left_maybe_elbow;
        bodyparts.RIGHT_ELBOW = bodyparts.right_elbow_maybe;
        bodyparts.LEFT_KNEE =  bodyparts.left_knee;
        bodyparts.RIGHT_KNEE = bodyparts.right_knee;
        
        bodyparts.RIGHT_FOOT =  [bodyparts.right_part_of_foot,	 bodyparts.right_tip_of_foot];
        bodyparts.LEFT_FOOT =  [bodyparts.left_part_of_foot,	 bodyparts.left_tip_of_foot];
        bodyparts.HEAD	=	 bodyparts.tip_of_the_head;
        bodyparts.TORSO = bodyparts.middle_of_upper_torax;
        bodyparts.LEFT_HAND = [bodyparts.left_some_part_of_the_hand bodyparts.left_some_other_part_of_the_hand];
        bodyparts.RIGHT_HAND = [bodyparts.right_some_part_of_the_hand bodyparts.right_some_other_part_of_the_hand];
        
    case 120
        bodyparts.hip_center = 1;
        bodyparts.spine = 2;
        bodyparts.shoulder_center = 3;
        bodyparts.head = 4;
        bodyparts.shoulder_left = 5;
        bodyparts.elbow_left = 6;
        bodyparts.wrist_left = 7;
        bodyparts.hand_left = 8;
        bodyparts.shoulder_right = 9;
        bodyparts.elbow_right = 10;
        bodyparts.wrist_right = 11;
        bodyparts.hand_right = 12;
        bodyparts.hip_left = 13;
        bodyparts.knee_left = 14;
        bodyparts.ankle_left = 15;
        bodyparts.foot_left = 16;
        bodyparts.hip_right = 17;
        bodyparts.knee_right = 18;
        bodyparts.ankle_right = 19;
        bodyparts.foot_right = 20;
        %%% synonyms
        bodyparts.RIGHT_HIP = bodyparts.hip_right;
        bodyparts.LEFT_HIP = bodyparts.hip_left;
        
        bodyparts.LEFT_SHOULDER = bodyparts.shoulder_left;
        bodyparts.RIGHT_SHOULDER = bodyparts.shoulder_right;
        
        bodyparts.RIGHT_FOOT =  [bodyparts.ankle_right,	 bodyparts.foot_right];
        bodyparts.LEFT_FOOT =  [bodyparts.ankle_left,	 bodyparts.foot_left];
        bodyparts.HEAD	=	 bodyparts.head;
        bodyparts.TORSO = bodyparts.shoulder_center;
        bodyparts.LEFT_HAND = [bodyparts.wrist_left, bodyparts.hand_left];
        bodyparts.RIGHT_HAND = [bodyparts.wrist_right, bodyparts.hand_right];
        
    case 90
        bodyparts.HEAD = 1;
        bodyparts.NECK = 2;
        bodyparts.TORSO = 3;
        bodyparts.LEFT_SHOULDER = 4;
        bodyparts.LEFT_ELBOW = 5;
        bodyparts.RIGHT_SHOULDER = 6;
        bodyparts.RIGHT_ELBOW = 7;
        bodyparts.LEFT_HIP = 8;
        bodyparts.LEFT_KNEE = 9;
        bodyparts.RIGHT_HIP = 10;
        bodyparts.RIGHT_KNEE = 11;
        bodyparts.LEFT_HAND = 12;
        bodyparts.RIGHT_HAND = 13;
        bodyparts.LEFT_FOOT = 14;
        bodyparts.RIGHT_FOOT = 15;
        %%%
        bodyparts.hip_center = [];
        
    otherwise
        dbgmsg('No idea from this size from what type of skeleton this is. I will assume it is a randomstick.')
        return
end

end
function awk = generate_awk
%% Awk definition:
important = 1;%0.1;
relevant = 1;%0.03;
minor = 1;%0.005;

awk = [...
    important;...   %1    hips
    important;...   %2    abdomen
    important;...   %3    neck or something
    relevant;...    %4    tip of the head
    important;...   %5    right shoulder
    relevant;...    %6    right also shoulder or elbow
    relevant;...    %7    right elbow maybe
    relevant;...    %8    right hand
    important;...   %9    left part of shoulder
    relevant;...    %10   left something maybe elbow
    relevant;...    %11   left maybe elbow
    relevant;...    %12   left hand
    important;...   %13   left hip
    relevant;...    %14   left knee
    minor;...       %15   left part of foot
    minor;...       %16   left tip of foot
    important;...   %17   right hip %important because hips dont lie
    relevant;...    %18   right knee
    minor;...       %19   right part of foot
    minor;...       %20   right tip of foot
    important;...   %21   middle of upper torax
    minor;...       %22   right some part of the hand
    minor;...       %23   right some other part of the hand
    minor;...       %24   left some part of the hand
    minor];         %25   left some other part of the hand

% if size(awk,1)*6~=size(data_val,1)
%     awk = ones(size(data_val,1)/6,1);
%     dbgmsg('Must update awk for this a skeleton this size.',1)
% end


end