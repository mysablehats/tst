function bigx= modefilter(series,numnum)

%%%first we need to transfor the large matriz into a vector
num_classes = size(series,1);
serieslength = size(series,2);
diagmat = diag(1:num_classes);

newseries = sum(diagmat*series,1);

x = zeros(1,serieslength);

for ii = numnum:serieslength
     x((ii-numnum+1):ii) = mode(newseries((ii-numnum+1):ii));
end

if num_classes == 1 %%% if it is onedimensional thing, then it is done
    bigx = x;
else
    
    %%%Otherwise we need to go back to were came from
    bigx = zeros(num_classes,serieslength);
    
    for ii = 1:serieslength
        bigx(x(ii),ii) = 1;
    end

end