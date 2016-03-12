%removehipbias
%have to initiate a newer array with one dimension less...
function [conform_train, conform_val] = conformskel(varargin )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%MESSAGES PART
dbgmsg('Applies normalizations of several sorts on both training and validation datasets',1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Since some of the normalizations will change the size of the data-set
%%% it is sensible to put them all in the same place where this can be
%%% controlled.

if strcmp(varargin{1},'test')
    if length(varargin)>1
        conformskel_test(varargin{2}) %%% I've decided to put the testing procedure here to keep things cleaner
    else
        conformskel_test()
    end
else
    data_train = varargin{1};
    data_val = varargin{2};
    
    % creates the function handle cell array
    conformations = {};
    killdim = [];
    
    for i =3:length(varargin)
        switch varargin{i}
            case 'nohips'
                conformations = [conformations, {@centerhips}];
                killdim = [killdim, 1];
            case 'normal'
                %conformations = [conformations, {@centerhips}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'mahal'
                %conformations = [conformations, {@centerhips}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'norotate'
                conformations = [conformations, {@norotatehips}];
            case 'norotateshoulders'
                conformations = [conformations, {@norotateshoulders}];
            case 'nofeet'
                %conformations = [conformations, {@nofeet}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'axial'
                %conformations = [conformations, {@centerhips}];
                dbgmsg('Unimplemented normalization: ', varargin{i} ,true);
            case 'addnoise'
                conformations = [conformations, {@abnormalize}];
            otherwise
                dbgmsg('Unimplemented normalization/ typo.',true);
        end
    end
    %%%%only true for the hips!
    %conform_train = zeros(size(data_train)-[3 0]);
    %conform_val = zeros(size(data_val)-[3 0]);
    
    
    % execute them for training and validation sets
    for i = 1:length(conformations)
        func = conformations{i};
        dbgmsg('Applying normalization: ', varargin{i+2} ,true);
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
    
    % squeeze them accordingly?
    whattokill = reshape(1:size(data_train,1),size(data_train,1)/3,3);
    realkilldim = whattokill(killdim,:);
    conform_train = data_train(setdiff(1:size(data_train,1),realkilldim),:); %sorry for the in-liners..
    conform_val = data_val(setdiff(1:size(data_val,1),realkilldim),:);
    
end
end
function newskel = centerhips(skel)
%%%%%%%%%MESSAGES PART
%%%%%%%%ATTENTION: this function is executed in loops, so running it will
%%%%%%%%messages on will cause unpredictable behaviour
%dbgmsg('Removing displacement based on hip coordinates (1st point on 25x3 skeleton matrix) from every other')
%dbgmsg('This makes the dataset translation invariant')
%%%%%%%%%%%%%%%%%%%%%
[tdskel,hh] = makefatskel(skel);

hips = [repmat(tdskel(1,:),25,1);zeros(hh-25,3)]; 

newskel = tdskel - hips;
%newskel(1,:) = []; %this is done at the end of the function...
% newskel = zeros(size(tdskel)-[1 0]);
% for i = 2:hh
%     newskel(i-1,:) = tdskel(i,:)- 1*hips;
% end

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
   rotmat = vecRotMat(rvec/norm(rvec),[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
   for i = 1:hh
       tdskel(i,:) = (rotmat*tdskel(i,:)')';
   end
else
    dbgmsg('Don''t know how to un-rotate this. Doing nothing')
end

newskel = makethinskel(tdskel);
end
function newskel = norotateshoulders(skel)
[tdskel,hh] = makefatskel(skel);

%%%%some normalization procedure %%%%%
% I will consider the rotation of the shoulders as the most important for a
% person, 
%according to my notes, they are the points 5(RS) 9(LS) and 21 Upper torax
if hh == 25
   rvec = tdskel(5,:)-tdskel(9,:); %uhmm, I think having some displacement with the upper torax here doesnt change anything, but I am not sure...
   rotmat = vecRotMat(rvec,[1 0 0 ]); % arbitrary direction. hope I am not doing anything too stupid
   for i = 1:hh
       tdskel(i,:) = rotmat*tdskel(i,:);
   end
else
    dbgmsg('Don''t know how to un-rotate this. Doing nothing')
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
function conformskel_test(varargin)

wholelist  = {'nohips' 'normal' 'mahal' 'norotate' 'norotateshoulders' 'nofeet' 'axial'};

%error('not implemented yet')

a =    1.0e+03 *[

   -0.1152
   -0.1219
   -0.1277
   -0.1249
   -0.2852
   -0.3292
   -0.3311
   -0.3305
    0.0384
    0.1044
    0.1462
    0.1330
   -0.1866
   -0.2042
   -0.1819
   -0.1879
   -0.0406
   -0.0109
   -0.0286
   -0.0068
   -0.1264
   -0.3244
   -0.3495
    0.1288
    0.1558
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
   -0.1315
    0.1860
    0.4940
    0.6515
    0.3708
    0.0990
   -0.1280
   -0.1305
    0.3716
    0.1135
   -0.1096
   -0.1339
   -0.1317
   -0.4933
   -0.8153
   -0.8977
   -0.1274
   -0.4837
   -0.8158
   -0.8917
    0.4184
   -0.2071
   -0.1426
   -0.2030
   -0.1436
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
    2.5466
    2.5062
    2.4519
    2.4364
    2.4513
    2.4692
    2.4202
    2.4226
    2.4626
    2.5007
    2.4515
    2.4438
    2.5065
    2.5864
    2.6430
    2.5850
    2.5109
    2.5795
    2.6455
    2.5973
    2.4678
    2.4077
    2.3806
    2.4388
    2.4113
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0
         0];
b = 1.0e+03 *[

   -0.0424
   -0.0414
   -0.0406
   -0.0237
   -0.1978
   -0.2440
   -0.2287
   -0.2155
    0.1214
    0.1724
    0.2066
    0.1991
   -0.1101
   -0.1521
   -0.1472
   -0.1355
    0.0268
    0.0571
    0.0410
    0.0592
   -0.0408
   -0.2043
   -0.2519
    0.2087
    0.2140
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
   -0.0000
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
   -0.0000
    0.0000
    0.0000
   -0.0000
   -0.0000
    0.0000
   -0.0000
    0.0000
    0.0000
    0.0000
   -0.2329
    0.0912
    0.4033
    0.5643
    0.2750
    0.0060
   -0.2187
   -0.2670
    0.2608
   -0.0035
   -0.2244
   -0.2780
   -0.2315
   -0.5341
   -0.8009
   -0.8339
   -0.2256
   -0.5814
   -0.9418
   -0.9996
    0.3270
   -0.3230
   -0.2695
   -0.3253
   -0.2787
    0.0000
    0.0000
    0.0000
    0.0000
    0.0000
   -0.0000
   -0.0000
   -0.0000
    0.0000
   -0.0000
   -0.0000
    0.0000
    0.0000
   -0.0000
    0.0000
    0.0000
    0.0000
    0.0000
   -0.0000
   -0.0000
    0.0000
   -0.0000
   -0.0000
    0.0000
   -0.0000
    1.9621
    1.9325
    1.8907
    1.8845
    1.8594
    1.8622
    1.8271
    1.8139
    1.8958
    1.9260
    1.8811
    1.8726
    1.9206
    1.9732
    2.2738
    2.1669
    1.9304
    1.8632
    1.8870
    1.7914
    1.9035
    1.8203
    1.8102
    1.8618
    1.8375
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
    0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000
   -0.0000];
figure
        skeldraw(a,true)
        figure
        skeldraw(b,true)
if isempty(varargin)
    %go through all
    for i = wholelist 
        try
            [ans1, ans2]  = conformskel(a,b,i{:})
            size(ans1)
            size(ans2)
        catch
            disp(strcat('Method ',i,' not successful'))
        end
    end
end
for i = 1:length(varargin)
    try
               
        [ans1, ans2]  = conformskel(a,b,varargin{i})
        figure
        skeldraw(ans1,true)
        figure
        skeldraw(ans2,true)
        
        size(ans1)
        size(ans2)
    catch
        disp(strcat('Method ',varargin{i},' not successful'))
    end
end
end