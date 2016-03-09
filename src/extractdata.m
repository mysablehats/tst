% create the matrix from the structure to access the database and run the
% classification....
function [Data, vectordata, Y, ends] = extractdata(structure)
WANTVELOCITY = true;

%%%%%%%%Messages part. Feedback for the user about the algorithm
dbgmsg('Extracting data from skeleton structure')
if WANTVELOCITY
    dbgmsg('Constructing long vectors with velocity data as well')
end
%%%%%%%%


Data = structure(1).skel;
ends = size(structure(1).skel,3);
% approach
Y = strcmp('Fall',structure(1).act)*ones(size(structure(1).skel,3),1);
for i = 2:length(structure) % I think each iteration is one action
    Data = cat(3, Data, structure(i).skel);
    Y = cat(1, Y, strcmp('Fall',structure(i).act)*ones(size(structure(i).skel,3),1));
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
Y = Y';
