function [gas]= gwr_core(eta,gas)

%A = gas.A;
%C = gas.C;
%C_age = gas.C_age;
%h = gas.h;
%r = gas.r;
%hizero = gas.hizero;
%hszero = gas.hszero;
%awk = gas.awk;
%params = gas.params;
%en = params.en;
%eb = params.eb;

%%%%%%%%%%%%%%%%%%% ATTENTION STILL MISSING FIRING RATE! will have problems
%%%%%%%%%%%%%%%%%%% when algorithm not static!!!!
%%%%%%%%%%%%%%%%%%%

%eta = data(:,k); % this the k-th data sample
[gas.gwr.ws, ~, gas.gwr.s, gas.gwr.t, ~] = findnearest(eta, gas.A); %step 2 and 3
if gas.C(gas.gwr.s,gas.gwr.t)==0 %step 4
    gas.C = spdi_bind(gas.C,gas.gwr.s,gas.gwr.t);
else
    gas.C_age = spdi_del(gas.C_age,gas.gwr.s,gas.gwr.t);
end
gas.a = exp(-norm((eta-gas.gwr.ws).*gas.awk)); %step 5

%algorithm has some issues, so here I will calculate the neighbours of
%s
[gas.gwr.neighbours] = findneighbours(gas.gwr.s, gas.C);
gas.gwr.num_of_neighbours = size(gas.gwr.neighbours,2);

if (gas.a < gas.params.at) && (gas.r <= gas.params.nodes) %step 6
    gas.gwr.wr = 0.5*(gas.gwr.ws+eta); %too low activity, needs to create new node r
    gas.A(:,gas.r) = gas.gwr.wr;
    gas.C = spdi_bind(gas.C,gas.gwr.t,gas.r);
    gas.C = spdi_bind(gas.C,gas.gwr.s,gas.r);
    gas.C = spdi_del(gas.C,gas.gwr.s,gas.gwr.t);
    gas.r = gas.r+1;
else %step 7
    %for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
 %       i = gas.gwr.neighbours(j);
        %size(A)
        gas.gwr.wi = gas.A(:,gas.gwr.neighbours);
        gas.A(:,gas.gwr.neighbours) = gas.gwr.wi + gas.params.en*(repmat(eta,1,gas.gwr.num_of_neighbours)-gas.gwr.wi).*repmat(gas.h(gas.gwr.neighbours),size(eta,1),1);
    %end
%     for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
%         i = gas.gwr.neighbours(j);
%         %size(A)
%         gas.gwr.wi = gas.A(:,i);
%         gas.A(:,i) = gas.gwr.wi + gas.params.en*gas.h(i)*(eta-gas.gwr.wi);
%     end
    gas.A(:,gas.gwr.s) = gas.gwr.ws + gas.params.eb*gas.h(gas.gwr.s)*(eta-gas.gwr.ws); %adjusts nearest point MORE;;; also, I need to adjust this after the for loop or the for loop would reset this!!!
end
%step 8 : age edges with end at s
%first we need to find if the edges connect to s

% for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
%     i = gas.gwr.neighbours(j);
    gas.C_age = spdi_add(gas.C_age,gas.gwr.s,gas.gwr.neighbours);
% end
% for j = 1:gas.gwr.num_of_neighbours % check this for possible indexing errors
%     i = gas.gwr.neighbours(j);
%     gas.C_age = spdi_add(gas.C_age,gas.gwr.s,i);
% end


%step 9: again we do it inverted, for loop first
%%%% this strange check is a speedup for the case when the algorithm is static
if gas.params.STATIC % skips this if algorithm is static
    gas.h = gas.hizero;
    gas.h(gas.gwr.s) = gas.hszero;
else
    for i = 1:gas.r %%% since this value is the same for all I can compute it once and then make all the array have the same value...
        gas.h(i) = gas.hi(gas.time,gas.params); %ok, is this sloppy or what? t for the second nearest point and t for time
    end
    gas.h(gas.gwr.s) = gas.hs(gas.time,gas.params);
    gas.time = (cputime - gas.t0)*1;
end

%step 10: check if a node has no edges and delete them
%[C, A, C_age, h, r ] = removenode(C, A, C_age, h, r);
%check for old edges

% makes the algorithm slightly faster when the matrices are not full
if gas.r > gas.params.nodes
    R = gas.params.nodes;
else
    R = gas.r;
end

if gas.r>2 % don't remove everything
    
    [gas.C(1:R,1:R), gas.C_age(1:R,1:R) ] = removeedge(gas.C(1:R,1:R), gas.C_age(1:R,1:R), gas.params.amax);
    [gas.C(1:R,1:R), gas.A(:,1:R), gas.C_age(1:R,1:R), gas.h, gas.r ] = removenode(gas.C(1:R,1:R), gas.A(:,1:R), gas.C_age(1:R,1:R), gas.h, gas.r);  %inverted order as it says on the algorithm to remove points faster
end

%gas.A = A;
%gas.C = C;
%gas.C_age = C_age;
%gas.h = h;
%gas.r = r;
%gas.a = a;
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

function [C, C_age ] = removeedge(C, C_age, amax) 
[row, col] = find(C_age > amax);
a = size(row,2);
if ~isempty(row)
    for i = 1:a
        C_age(row(i),col(i)) = 0;
        C_age(col(i),row(i)) = 0;
        C(row(i),col(i)) = 0;
        C(col(i),row(i)) = 0;
    end
end
end

function [C, A, C_age, h,r ] = removenode(C, A, C_age, h,r) %depends only on C operates on everything

[row,~] = find(C);
%a = [row;col];
maxa = max(row);
%ther = min([size(C,1) r maxa]); 
%pointstoremove = setdiff(1:ther,row);
%if isempty(pointstoremove)
% pointstoremove = [];
%end
%pointsIremoved = [];
% if 1 %gpuDeviceCount>10
    pointstoremove = find(any(bsxfun(@eq, row, 1:maxa))==0);
% else
% for i = 1:maxa% r pointstoremove
%     %%% the next lines were errorchecks, but since they are rarely called,
%     %%% I Will comment them out
% %     if max(row)<maxa %ok, lets try this, if the old maximum is not valid anymore stop the for loop.
% %         break % I am assuming that this also means that all of the remaining rows and columns are zeroed
% %     end
% %        shouldIremovetheithnode = find(row == i, 1);
%          oddmanout = (row == i);
%          shouldIremovetheithnode = ~any(oddmanout);
%         %shouldIremovetheithnode2 = sum(row == i);
%         %if isempty(shouldIremovetheithnode)~=shouldIremovetheithnode1||isempty(shouldIremovetheithnode2)~=shouldIremovetheithnode1
%         %    error('Karla this out!')
%         %end
%         if shouldIremovetheithnode
%             pointstoremove = [pointstoremove i];
%         end
% % end
% end
if ~isempty(pointstoremove)
    numnum = length(pointstoremove); %sloppy, I know...
    C = clipsimmat(C,pointstoremove,numnum);
    if any(pointstoremove>size(A,2))
        disp('wrong stuff going on')
    end
    A = clipA(A,pointstoremove,numnum);
    C_age = clipsimmat(C_age,pointstoremove,numnum);
    h = clipvect(h,pointstoremove,numnum);
    r = r-numnum;
    if r<1||r~=fix(r)
        error('something fishy happening. r is either zero or fractionary!')
    end
end

%%% old for loop to remove points
% for i = pointstoremove
%    % if isempty(shouldIremovetheithnode)
% %        pointsIremoved = [pointsIremoved i];
%         %has to do this to every matrix and vector
%         C = clipsimmat(C,i);
%         if i>size(A,2)
%             disp('wrong stuff going on')
%         end
%         A = clipA(A,i); 
%         C_age = clipsimmat(C_age,i);
%         h = clipvect(h,i);
%         r = r-1;
%         if r<1||r~=fix(r)
%             error('something fishy happening. r is either zero or fractionary!')
%         end
%         %[row,~] = find(C);
%    % end
%    
% end



% if any(size(pointsIremoved)~=size(pointstoremove))||~all(sort(pointsIremoved)==sort(pointstoremove))
%     error('Karla this out!!')
% end
end

function C = clipsimmat(C,i,n)
C(i,:) = [];
C(:,i) = [];
C = padarray(C,[n n],'post');
end

function V = clipvect(V, i, n)
V(i) = [];
V = [V zeros(1,n)];
end

function A = clipA(A, i,n)
A(:,i) = [];
ZERO = zeros(size(A,1),n);
A = [A ZERO];
end

%%%old functions from old for loop
% function C = clipsimmat(C,i)
% C(i,:) = [];
% C(:,i) = [];
% C = padarray(C,[1 1],'post');
% end
% 
% function V = clipvect(V, i)
% V(i) = [];
% V = [V 0];
% end
% 
% function A = clipA(A, i)
% A(:,i) = [];
% ZERO = zeros(size(A,1),1);
% A = [A ZERO];
% end

function neighbours = findneighbours_old_but_working(s,C)
[row, col] = find(C); % there will likely be infinite mistakes in indexing here...
neighbours = [];
for i = 1:length(row)
    if row(i) == s
        %s
        %i
        neighbours = [neighbours col(i)];
        %C_age = spdi_add(C_age,s,col(i)); %omg, the horror.... but s = row(i) already is this it? I have no idea...
        %cummax(cummax(C_age))
    end
end
%neighbours
end
function neighbours = findneighbours(s,C)
%%% assuming C is symmetric and I did everything right...
ne = find(C(s,:));
neighbours = ne(ne~=0);
% oldnig = findneighbours_old_but_working(s,C);
% if any(size(oldnig)~=size(neighbours))||any(oldnig~=neighbours) 
%     error('check this out')
% end

end

