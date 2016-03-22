function [ matmat, matmat_byindex] = genbestmmatrix(gwr_nodes, data, whichisit,q)
matmat = zeros(size(gwr_nodes,1),size(data,2));
%matmat_byindex = zeros(1,size(data,2));
[~,matmat_byindex] = pdist2(gwr_nodes',data','euclidean','Smallest',1);
matmat = data(matmat_byindex);
% 
% for i = 1:size(data,2) 
%        [ matmat(:,i), matmat_byindex(i)] = bestmatchingunit(data(:,i),gwr_nodes,whichisit,q);
% end
end
% % old genbestmatch. I figured out it is the other way around, which makes
% more sense, so I should just filter spatially my data, so the
% bestmatching data should have the same dimension as the initial dataset,
% duh...
% matmat = zeros(size(data,1),size(gwr_nodes,2));    
% for i = 1:size(gwr_nodes,2) %%%%%%%%%% it is actually the other way around!!!!! 
%         matmat(:,i) = bestmatchingunit(gwr_nodes(:,i),data,whichisit);
% end
% end
function [s,indexx] = bestmatchingunit(w,gas_nodes,whichisit,q)
%finds the best matching unit

%the best thing here would be to compare sizes,1 of w and gasnodes and if
%they were different, chop it. But this would obfuscate the fact that if
%they are different, then we have a bit of of a problem, and chopping it is
%perhaps not the best way to go about solving it.
wchop = w; %chop_procedure(w, whichisit,q); %% this is being disabled like nature does it. implicitly. I think set input took on this role and I don't need this function anymore, but I might be wrong. see if it breaks like this...
%gas_nodes = gpuArray(gas_nodes);

maxmax = size(gas_nodes,2);
a = zeros(maxmax,1); %,'gpuArray');
for i = 1:maxmax
    a(i) = pdist2(wchop,gas_nodes(:,i));
end
[~, indexx] = min(a);
%indexx = gather(indexx);
%s = gather(gas_nodes(:,indexx));
s = gas_nodes(:,indexx);
end
