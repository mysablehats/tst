global homepath pathtodropbox SLASH pathtodata logpath
try
    if ismac
		pathtodropbox = '~/Dropbox/octave_progs';
		homepath = '~/matlabprogs/';
		%disp('reached ismac')
	elseif isunix
		pathtodropbox = '/home/fbklein/Dropbox/octave_progs';
		homepath = '/home/fbklein/Documents/classifier/';
		%disp('reached isunix')
	end
	addpath(genpath(homepath)) 
catch
	disp('oh-oh')
	%open dialog box?
 	%have to see how to do it
end
logpath = strcat(homepath,'tst/var/log.txt');
[SLASH, pathtodata] = OS_VARS();