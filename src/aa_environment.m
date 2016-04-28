global homepath wheretosavestuff SLASH pathtodata logpath
try
    if ismac
		wheretosavestuff = '/remote/elements/fall_detection_datasets/var';
		homepath = '~/matlabprogs/';
		%disp('reached ismac')
	elseif isunix
		wheretosavestuff = '/home/fbklein/Dropbox/octave_progs';
		homepath = '/home/fbklein/Documents/classifier/';
		%disp('reached isunix')
	end
	%addpath(genpath(homepath)) 
catch
	disp('oh-oh')
	%open dialog box?
 	%have to see how to do it
end
logpath = strcat(homepath,'tst/var/log.txt');
[SLASH, pathtodata] = OS_VARS();