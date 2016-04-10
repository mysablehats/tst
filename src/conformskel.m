function [conform_train, conform_val, skelldef] = conformskel(varargin )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Applies normalizations of several sorts on both training and validation datasets')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test = false;

%%% Since some of the normalizations will change the size of the data-set
%%% it is sensible to put them all in the same place where this can be
%%% controlled.
skelldef = struct();

if isempty(varargin)||strcmp(varargin{1},'test')
    if length(varargin)>1
        [conform_train, conform_val] = conformskel_test(varargin{2:end}); %%% I've decided to put the testing procedure here to keep things cleaner
    else
        [conform_train, conform_val] = conformskel_test();
    end
else
    data_train = varargin{1};
    data_val = varargin{2};
    awk = varargin{3};
    skelldef.length = size(data_val,1);
    if size(data_train)~=skelldef.length
        error('data_train and data_val must have the same length!!!')
    end
    if any(size(awk).*[6 1]~= size(data_val(:,1)))
        error('wrong size for awk. It should be the same size of the input data. maybe you should transpose it?')
    end
    % creates the function handle cell array
    conformations = {};
    killdim = [];
    
    for i =4:length(varargin)
        switch varargin{i}
            case 'test'
                test = true;
            case 'nohips'
                conformations = [conformations, {@centerhips}];
                killdim = [killdim, 1];
            case 'normal'
                conformations = [conformations, {@normalize}];
                %dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'mirror'
                conformations = [conformations, {@mirror}];
            case 'mahal'
                %conformations = [conformations, {@mahal}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'norotate'
                conformations = [conformations, {@norotatehips}];
            case 'norotateshoulders'
                conformations = [conformations, {@norotateshoulders}];
                dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
            case 'notorax'
                conformations = [conformations, {@centertorax}];
                dbgmsg('WARNING, the normalization: ' , varargin{i},' is performing poorly, it should not be used.', true);
                killdim = [killdim, 21];
            case 'nofeet'
                conformations = [conformations, {@nofeet}]; %not sure i need this...
                killdim = [killdim, 19, 20, 15, 16];
            case 'nohands'
                 killdim = [killdim, 19, 20, 15, 16];
            case 'axial'
                %conformations = [conformations, {@centerhips}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'addnoise'
                conformations = [conformations, {@abnormalize}];
            otherwise
                dbgmsg('ATTENTION: Unimplemented normalization/ typo.',varargin{i},true);
        end
    end
    
    % execute them for training and validation sets
    for i = 1:length(conformations)
        func = conformations{i};
        dbgmsg('Applying normalization: ', varargin{i+2},false);
        for j = 1:size(data_train,2)
            data_train(:,j) = func(data_train(:,j));
        end
    end
    
    for i = 1:length(conformations)
        func = conformations{i};
        for j = 1:size(data_val,2)
            data_val(:,j) = func(data_val(:,j));
        end
    end
    skelldef.elementorder = 1:skelldef.length;
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
end
skelldef.realkilldim = realkilldim;
[skelldef.pos, skelldef.vel] = generateidx(skelldef.length, skelldef);
end
function newskel = centerhips(skel)

[tdskel,hh] = makefatskel(skel);

hips = [repmat(tdskel(1,:),25,1);zeros(hh-25,3)]; % this is so that we dont subtract the velocities

newskel = tdskel - hips;

%I need to shape it back into 75(-3 now) x 1
newskel = makethinskel(newskel);
end
function newskel = centertorax(skel)

[tdskel,hh] = makefatskel(skel);

torax = [repmat(tdskel(21,:),25,1);zeros(hh-25,3)]; 

newskel = tdskel - torax;

%I need to shape it back into 75(-3 now) x 1
newskel = makethinskel(newskel);
end
function newskel = norotatehips(skel)
[tdskel,hh] = makefatskel(skel);

%%%%some normalization procedure %%%%%
% I will consider the rotation of the hips because it is simpler to think
% about, since I have normalized the skeleton to a neutral position around
% the hips already
% according to my notes, they are the points 17(RHip) 13(LHip) around point
% 1
if hh == 25 || hh == 50
    rvec = tdskel(17,:)-tdskel(13,:);
elseif hh == 24 || hh == 49
    rvec = tdskel(16,:)-tdskel(12,:);
else
    rvec = [1 0 0];
    dbgmsg('Don''t know how to un-rotate this. Doing nothing')
end

   
   rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
   for i = 1:hh
       tdskel(i,:) = (rotmat*tdskel(i,:)')';
   end

newskel = makethinskel(tdskel);
end
function newskel = norotateshoulders(skel)
[tdskel,hh] = makefatskel(skel);

%%%%some normalization procedure %%%%%
% I will consider the rotation of the shoulders as the most important for a
% person, 
%according to my notes, they are the points 5(RS) 9(LS) and 21 Upper torax
if hh == 25 || hh == 50
    rvec = tdskel(5,:)-tdskel(9,:);
elseif hh == 24 || hh == 49
    rvec = tdskel(5,:)-tdskel(9,:); % dumbass
else
    rvec = [1 0 0];
    dbgmsg('Don''t know how to un-rotate this. Doing nothing')
end
   
   rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
   for i = 1:hh
       tdskel(i,:) = (rotmat*tdskel(i,:)')';
   end

newskel = makethinskel(tdskel);
end
function newskel = abnormalize(skel)
[tdskel,hh] = makefatskel(skel);

%%%%some conformation procedure %%%%%
if hh == 25
    tdskel = tdskel + rand(size(tdskel));
else
    dbgmsg('Don''t know how to un-abnormalize this. Doing nothing')
end

newskel = makethinskel(tdskel);
end
function newskel = nofeet(skel)
[tdskel,hh] = makefatskel(skel);

%%%%some conformation procedure %%%%%
if mod(hh,25) == 0 % I will remove this and make a smaller skeleton, but first I will zero-it
    tdskel(16,:) = zeros(1,size(tdskel,2));
    tdskel(20,:) = zeros(1,size(tdskel,2));
elseif mod(hh,25) == 24
    tdskel(15,:) = zeros(1,size(tdskel,2));
    tdskel(19,:) = zeros(1,size(tdskel,2));
else
    dbgmsg('Don''t know how to remove feet from this. Doing nothing')
end

newskel = makethinskel(tdskel);
end
function newskel = mirror(skel)
[tdskel,~] = makefatskel(skel);

%%%%some conformation procedure %%%%%
tdskel(:,1) = -tdskel(:,1);

newskel = makethinskel(tdskel);
end
function newskel = normalize(skel)
%%this function was developed by inspection. a random skeleton was used
%just to make sure that the variables are in similar orders of magnitude.
%The average std deviation from the skeletons computed as
%mean(mean(std(allskels(1:25,:,:)))) was 233.5180 for the whole tst dataset of skeletons whereas for
%the speeds computed as mean(mean(std(allskels(26:end,:,:)))) it was 5.5481e-05
%magic constants will be used in order to make both these numbers close to
%1 as possible

[tdskel,hh] = makefatskel(skel);
magicconstant1 = 2.951426379619558e+02;
magicconstant2 = 1.401162861741577e-04;
%%%%some conformation procedure %%%%%
if hh == 24
    tdskel = tdskel/magicconstant1;
elseif hh>=25
    for i = 1:25
        tdskel(i,:) = tdskel(i,:)/magicconstant1;
    end
else
    dbgmsg('Don''t know how to normalize this. Doing nothing')
end
if hh>=26 %then there is velocities, right?
    for i = 26:hh
        tdskel(i,:) = tdskel(i,:)/magicconstant2;
    end
end

newskel = makethinskel(tdskel);
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