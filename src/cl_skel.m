%clustering versuch
function cl_skel(Data)
if Data > 3000
    samplesample = datasample(Data', 3000);
else
    samplesample = Data';
end
XX = pdist(samplesample);
sqXX = squareform(XX);
linkXX = linkage(sqXX);

dendrogram(linkXX,0,'ColorThreshold','default')

    