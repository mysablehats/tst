function progress(i,mini, maxi)
%%% 
%this was crashing and causing a lot of problems 
% if i==maxi
%     fprintf('\bDone!\r\n')
% elseif i==mini
%     fprintf(' ')
% else
% switch mod(i,4)
%     case 0
%     fprintf('\b\\')
%     case 1
%     fprintf('\b-')
%     case 2
%     fprintf('\b/')
%     case 3
%     fprintf('\b|')
% end
% end
% N = maxi - mini;
% partsize = fix(100/N*i);
% lastpartsize = fix(100/N*(i-1));
% if lastpartsize < 0
%     lastpartsize = 0;
% end
% if i == mini
%     fprintf('\r')
% end
% for j = 0:lastpartsize
%     fprintf('\b')
% end
% 
% for j = 1:partsize
%     fprintf('#')
% end
% if partsize == 100
%     fprintf('Done!\r')
   
end
    
    
