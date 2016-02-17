function A = gwr(data)

%cf parisi, 2015 and cf marsland, 2002

% some differences:
% in the 2002 paper, they want to show the learning of topologies ability
% of the GWR algorithm, which is not our main goal. In this sense they have
% a function that can generate new points as pleased p(eta). This is not
% our case, we will just go through our data sequentially

% I am not taking time into account. the h(time) function is therefore
% something that yields a constant value

%the initial parameters for the algorithm:
global maxnodes at en eb h0 ab an tb tn amax
maxnodes = 20; %maximum number of nodes/neurons in the gas
at = 0.75; %activity threshold
en = 0.006; %epsilon subscript n
eb = 0.2; %epsilon subscript b
h0 = 1;
ab = 0.95;
an = 0.95;
tb = 3.33;
tn = 3.33;
amax = 50; %greatest allowed age
t0 = cputime; % my algorithm is not static!

time = 0;


%test some algorithm conditions:
if ~(0 < en || en < eb || eb < 1)
    error('en and/or eb definitions are wrong. They are as: 0<en<eb<1.')
end
% (1)
% pick n1 and n2 from data
n = datasample(data,2,2);
n1 = n(:,1); n2 = n(:,2);

A = [n1, n2];
% (2)
% initialize empty set C

C = sparse(maxnodes,maxnodes); % this is the connection matrix.
C_age = C;

r = 3; %the first point to be added is the point 3 because we already have n1 and n2
h = zeros(1,maxnodes);%firing counter matrix

% crazy idea: go through the dataset twice
for aaaaaaaaa = 1:2

% start of the loop
for k = 1:size(data,2) %step 1
    %time = (cputime - t0)/1; 
    eta = data(:,k); % this the k-th data sample
    [ws wt s t distance] = findnearest(eta, A); %step 2 and 3
    % I have no idea what the weight vector is I will use 1
    if C(s,t)==0 %step 4
        C = spdi_bind(C,s,t);
    else
        C_age = spdi_del(C_age,s,t);
    end
    a = exp(-norm(eta-ws)); %step 5
    
    %algorithm has some issues, so here I will calculate the neighbours of
    %s
        [neighbours] = findneighbours(s, C);
    
    if a < at && r < maxnodes %step 6
        wr = 0.5*(ws+eta); %too low activity, needs to create new node r
        A = [A wr];
        C = spdi_bind(C,t,r);
        C = spdi_bind(C,s,r);
        C = spdi_del(C,s,t);
        r = r+1;
    else %step 7
        for j = 1:size(neighbours,2) % check this for possible indexing errors
            i = neighbours(j);
            %size(A)
            wi = A(:,i);
            A(:,i) = wi + en*h(i)*(eta-wi);
        end
        A(:,s) = ws + eb*h(s)*(eta-ws); %adjusts nearest point MORE;;; also, I need to adjust this after the for loop or the for loop would reset this!!!
    end
    %step 8 : age edges with end at s
    %first we need to find if the edges connect to s
    
    for j = 1:size(neighbours,2) % check this for possible indexing errors
            i = neighbours(j);
            C_age = spdi_add(C_age,s,i);
    end
          
    %step 9: again we do it inverted, for loop first
    for i = 1:size(A,2)
        h(i) = hi(time); %ok, is this sloppy or what? t for the second nearest point and t for time??? should I respect these people?
    end
    h(s) = hs(time);
    %step 10: check if a node has no edges and delete them
    [C, A, C_age, h, r ] = removenode(C, A, C_age, h, r); 
    %check for old edges (maybe we can move it the following line to be
    %before the previous line it would save one computation....
    [C, C_age ] = removeedge(C, C_age);  
    %[C, A, C_age, h, r ] = removenode(C, A, C_age, h, r);  %inverted order as it says on the algorithm to remove points faster
    
    plotgng(A, C,'n')
    axis([0 10 0 10])
    drawnow
end
end
end
function sparsemat = spdi_add(sparsemat, a, b) %increases the number so that I don't have to type this all the time and forget it...
sparsemat(a,b) = sparsemat(a,b) + 1; 
sparsemat(b,a) = sparsemat(a,b) + 1;

end
function sparsemat = spdi_bind(sparsemat, a, b) % adds a 2 way connection, so that I don't have to type this all the time and forget it...
sparsemat(a,b) = 1; 
sparsemat(b,a) = 1;

end

function sparsemat = spdi_del(sparsemat, a, b) % removes a 2 way connection, so that I don't have to type this all the time and forget it...
sparsemat(a,b) = 0;
sparsemat(b,a) = 0;

end
%some of the functions definitions used to say this is biologically
%plausible...
function X = S(t)
    X = 1;
end
function X = hs(t)
global h0 ab tb 
X = h0 - S(t)/ab*(1-exp(-ab*t/tb));
end
function X = hi(t)
global h0 an tn 
X = h0 - S(t)/an*(1-exp(-an*t/tn));
end

    
    
    
    