function [polidx, velidx] = generateidx(lllen)
%oh, this is not unique, probably should a varargin and check for both
%size and a label value

switch lllen
    case 75
        %%%%regular skeleton
        polidx = [1:75];
        velidx = [];
    case 150
        %%%%skeleton + velocities
        polidx = [1:25 51:75 101:125];
        velidx = [26:50 76:100 126:150];
    case 72
        %%%%skeleton - hips
        polidx = [1:72];
        velidx = [];
    case 147
        %%%%skeleton - hips + velocities
        polidx = [1:24 50:73 99:122];
        velidx = [25:49 74:98 123:147];
    otherwise
        error('Strange size!')
        %%%%regular skeleton
end

        