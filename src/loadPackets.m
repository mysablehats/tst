function PckVal = loadPackets(device,path)
[SLASH, pathtodata] = OS_VARS();
n = 22; % No. of columns of T
fid = fopen(strcat(path,SLASH,'Shimmer',SLASH,'Packets',device,'.bin'));    
B = fread(fid,'uint8');
fclose(fid);
BB = reshape(B, n,[]);
PckVal = permute(BB,[2,1]); 