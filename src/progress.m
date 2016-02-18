function progress(i,maxi)
onepercent  = maxi/100;
if mod(i,onepercent)<.1
    disp(strcat('Progress: ',num2str(i/onepercent),'%'))
end
    
    
