function matmat = genbestmmatrix(gwr_nodes, data, whichisit,q)
%%%% I have just changed this whole function. the likelyhood that it will
%%%% work is very very very low
matmat = zeros(size(gwr_nodes,1),size(data,2));    
for i = 1:size(data,2) 
        matmat(:,i) = bestmatchingunit(data(:,i),gwr_nodes,whichisit,q);
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
function s = bestmatchingunit(w,gas_nodes,whichisit,q)
%finds the best matching unit

wchop = w; %chop_procedure(w, whichisit,q); %% this is being disabled like nature does it. implicitly. I think set input took on this role and I don't need this function anymore, but I might be wrong. see if it breaks like this...

maxmax = size(gas_nodes,2);
a = zeros(maxmax,1);
for i = 1:maxmax
    a(i) = norm(wchop-gas_nodes(:,i));
end
[~, indexx] = min(a);
s = gas_nodes(:,indexx);
end
