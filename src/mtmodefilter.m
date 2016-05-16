function newmt = mtmodefilter(mt,numnum)
%%%

newmt(size(mt)) = struct();
for i = 1:size(newmt,1)
    for j = 1:size(newmt,2)
        newmt(i,j).conffig.val{1} = mt(i,j).conffig.val{1};
        newmt(i,j).conffig.val{2} = modefilter(mt(i,j).conffig.val{2},numnum);
        newmt(i,j).conffig.val{3} = strcat(mt(i,j).conffig.val{3},'m',num2str(numnum)); % so that I remember this is after the mode filter
        
        %%%% and same thing for training set
        newmt(i,j).conffig.train{1} = mt(i,j).conffig.train{1};
        newmt(i,j).conffig.train{2} = modefilter(mt(i,j).conffig.train{2},numnum);
        newmt(i,j).conffig.train{3} = strcat(mt(i,j).conffig.train{3},'m',num2str(numnum)); % so that I remember this is after the mode filter
        
    end
end