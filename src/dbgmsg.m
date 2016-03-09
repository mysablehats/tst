function dbgmsg(varargin)
%%%% if this is run inside a parallel processing loop, then the message
%%%% should have a trailing ", true" option added to it, because parallel
%%%% pools don't receive global values
global logfile

logfile = fopen('../var/log.txt','at'); % global is not working and I don't want to figure out why
msg = varargin{1};
if nargin >2
    msg = strcat(varargin{1:end-1});
    VERBOSE = varargin{end};
end
if nargin >1
    VERBOSE = varargin{end};
else
    global VERBOSE
end
if VERBOSE
    doubleprint(logfile,'[%s %f] ',date,cputime);
    a = dbstack;
    doubleprint(logfile,a(end).name);
    if length(a)>1
        for i = (length(a)-1):-1:2
            doubleprint(logfile,': ');
            doubleprint(logfile,a(i).name);
        end
    end
    doubleprint(logfile,': ');
    doubleprint(logfile,msg);
    doubleprint(logfile,'\n');
end
end
function doubleprint(varargin)
global logfile
logfile = fopen('../var/log.txt','at'); % global is not working and I don't want to figure out why

fprintf(logfile,varargin{2:end});
fprintf(varargin{2:end});
end
