% create the matrix from the structure to access the database and run the
% classification....
function [Data, vectordata, Y, ends, lab] = extractdata(structure)
WANTVELOCITY = true;

%%%%%%%%Messages part. Feedback for the user about the algorithm
dbgmsg('Extracting data from skeleton structure')
if WANTVELOCITY
    dbgmsg('Constructing long vectors with velocity data as well')
end
%%%%%%%%
typetype= 'act_type';
%typetype= 'act';

Data = structure(1).skel;
ends = size(structure(1).skel,3);
% approach
if strcmp(typetype,'act')
    [labelZ,~] = alllabels(structure);
elseif strcmp(typetype,'act_type')
    [~, labelZ] = alllabels(structure);
else
    error('weird typetype!')
end
lab = sort(labelZ);

Y = repmat(whichlab(structure(1),lab,typetype),1,size(structure(1).skel,3));
for i = 2:length(structure) % I think each iteration is one action
    Data = cat(3, Data, structure(i).skel);
    Y = cat(2, Y, repmat(whichlab(structure(i),lab,typetype),1,size(structure(i).skel,3)));
    ends = cat(2, ends, size(structure(i).skel,3));
end
if WANTVELOCITY
    Data_vel = structure(1).vel;
    for i = 2:length(structure) % I think each iteration is one action
        Data_vel = cat(3, Data_vel, structure(i).vel);        
    end
    Data = cat(1,Data, Data_vel);
end
% It will also construct data for a clustering analysis, whatever the hell
% that might mean in this sense
vectordata = [Data(:,1,1); Data(:,2,1); Data(:,3,1)];
for i = 2:length(Data)
    vectordata = cat(2,vectordata, [Data(:,1,i); Data(:,2,i); Data(:,3,i)]);
end
%Y = Y';
end
function [lab, biglab] = alllabels(st)
lab = cell(0);
biglab = lab;

if isfield(st,'act')&&isfield(st,'act_type')
    for i = 1:length(st) % I think each iteration is one action
        cu = strfind(lab, st(i).act);
        if isempty(lab)||isempty(cell2mat(cu))
            lab = [{st(i).act}, lab];
            biglab = [{[st(i).act st(i).act_type]}, biglab];
        end
        bgilab = [st(i).act st(i).act_type];
        cu = strfind(biglab, bgilab);
        if isempty(biglab)||isempty(cell2mat(cu))
            biglab = [{bgilab}, biglab];
        end
    end
elseif isfield(st,'act')
    for i = 1:length(st) % I think each iteration is one action
        cu = strfind(lab, st(i).act);
        if isempty(lab)||isempty(cell2mat(cu))
            lab = [{st(i).act}, lab];
        end
    end
elseif isfield(st,'act_type')
    for i = 1:length(st) % I think each iteration is one action
        cu = strfind(lab, st(i).act);
        if isempty(lab)||isempty(cell2mat(cu))
            lab = [{st(i).act}, lab];
        end
         
    end
else
    error('No action fields in data structure.')
end

end
function outlab = whichlab(st,lb,tt)
numoflabels = size(lb,2);
switch tt
    case 'act_type'
        for i = 1:numoflabels
            if strcmp(lb{i},[st.act st.act_type])
                lab = i; %i-1;
            end
        end
    
    case 'act'
        for i = 1:numoflabels
            if strcmp(lb{i},st.act)
                lab = i;%i-1;
            end
        end    
    otherwise
        error('Unknown classification type!')
end
%I thought lab was a good choice, but matlab
outlab = zeros(numoflabels,1);
outlab(lab) = 1;
end
