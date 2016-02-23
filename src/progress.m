function progress(i,maxi)
onepercent  = maxi/100;
if mod(i,onepercent)<.1
    %a = toc;
    percentage = i/onepercent;
%     eta = (100-percentage)*a;
%     hours = fix(eta/3600);
%     minutes = fix((eta-hours*3600)/60);
%     seconds = eta-hours*3600-minutes*60;
%     bbb = strcat('Progress: ',num2str(percentage),'%% Estimated remaining time: ', num2str(hours), ':',num2str(minutes),':',num2str(seconds), '\x8B');
    fprintf('#')
    tic
end
    
    
