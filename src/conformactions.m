function [allskel1, allskel2] = conformactions(allskel1,allskel2, whichfilter)
%%%disp('hello')
%whichfilter = 'median';

switch whichfilter
    case 'filter'
        %%% this filter is likely bad because it introduces phase shift!!
        windowSize = 5;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        filterfun = @(x)filter(b,a,x);
    case 'median'
        medianmedian = 5;
        filterfun = @(x)medfilt1(x,medianmedian);
    case 'none'
        return
    otherwise
        error('Unknown filter.')
end

for i = 1:size(allskel1,2)
    for j = 1:size(allskel1(i).vel,1)
        for k = 1:size(allskel1(i).vel,2)
            allskel1(i).vel(j,k,:) = filterfun(allskel1(i).vel(j,k,:));
        end
    end
end

for i = 1:size(allskel2,2)
    for j = 1:size(allskel2(i).vel,1)
        for k = 1:size(allskel2(i).vel,2)
            allskel2(i).vel(j,k,:) = filterfun(allskel2(i).vel(j,k,:));
        end
    end
end

end
