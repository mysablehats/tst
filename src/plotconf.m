function plotconf(mt)
al = length(mt);

figset = cell(6*al,1);
for i = 1:al
    figset((i*6-5):i*6) = {mt(i).conffig.val{:} mt(i).conffig.train{:} };
end
plotconfusion(figset{:})

end