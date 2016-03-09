function matmat = genbestmmatrix(gwr_nodes, data, whichisit)
%%%% I have just changed this whole function. the likelyhood that it will
%%%% work is very very very low
matmat = zeros(size(gwr_nodes,1),size(data,2));    
for i = 1:size(data,2) 
        matmat(:,i) = bestmatchingunit(data(:,i),gwr_nodes,whichisit);
end
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
function s = bestmatchingunit(w,gas_nodes,whichisit)
%finds the best matching unit

wchop = chop_procedure(w, whichisit);

maxmax = size(gas_nodes,2);
a = zeros(maxmax,1);
for i = 1:maxmax
    a(i) = norm(wchop-gas_nodes(:,i));
end
[~, indexx] = min(a);
s = gas_nodes(:,indexx);
end
