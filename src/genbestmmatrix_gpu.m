function [ matmat, matmat_byindex] = genbestmmatrix_gpu(gwr_nodes, data, whichisit,q)
%%%% I have just changed this whole function. the likelyhood that it will
%%%% work is very very very low

matmat = zeros(size(gwr_nodes,1),size(data,2),'gpuArray');
matmat_byindex = zeros(1,size(data,2),'gpuArray');

ggwr_nodes = gpuArray(gwr_nodes);
gdata = gpuArray(data);

%[matmat,matmat_byindex] = pagefun( @bmu,gdata,ggwr_nodes);

 for i = 1:size(data,2) 
        [ matmat(:,i), matmat_byindex(i)] = bmu(gdata(:,i),ggwr_nodes);%bestmatchingunit(data(:,i),gwr_nodes,whichisit,q);
 end

 matmat = gather(matmat);
 matmat_byindex = gather(matmat_byindex);
 
end
function [s, indexx] = bmu(w, gasnodes)

maxmax = size(gasnodes,2);
a = zeros(maxmax,1,'gpuArray');
for i = 1:maxmax
    a(i) = pdist2(w,gasnodes(:,i));
end
%a = norm(gasnodes-repmat(w,1,size(gasnodes,2))); %bsxfun(@hypot,gasnodes,w);

[~, indexx] = min(a);
s = gasnodes(:,indexx);

end