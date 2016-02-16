function [n1 n2 ni1 ni2 distvector] = findnearest(p, data)
    maxindex = length(data);
    distvector = zeros(1,maxindex);
    for i = 1:maxindex
        distvector(i) = norm(data(:,i)- p);
    end
    [sorted_distances index] = sort(distvector);
    ni1 = index(1);
    ni2 = index(2);
    n1 = data(:,ni1);
    n2 = data(:,ni2);
    
    
    %index(1:10)
    %next closest