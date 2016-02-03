% create the structure to access the database and run the classification?
function [Data, vectordata] = extractdata(structure)
Data = structure.skel;
for i = 2:length(structure)
    Data = cat(3, Data, structure.skel);
end
% It will also construct data for a clustering analysis, whatever the hell
% that might be in this sense
vectordata = [structure.skel(:,1,1); structure.skel(:,2,1); structure.skel(:,3,1)];
for i = 2:length(Data)
    vectordata = cat(2,vectordata, [structure.skel(:,1,i); structure.skel(:,2,i); structure.skel(:,3,i)]);
end
