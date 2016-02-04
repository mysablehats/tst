%clustering versuch
function cl_skel(Data)
    samplesample = datasample(Data', 3000);
    XX = pdist(samplesample);
    sqXX = squareform(XX);
    linkXX = linkage(sqXX);
    
    dendrogram(linkXX,100)
    
    