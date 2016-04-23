function a = executioncore_in_starterscript(paramsZ,allconn, data)
n = randperm(size(data.train,2)-3,2); % -(q-1) necessary because concatenation reduces the data size!
paramsZ.startingpoint = [n(1) n(2)];
pallconn = allconn;
pallconn{1,1}{1,6} = paramsZ; % I only change the initial points of the position gas
%pallconn{1,3}{1,6} = paramsZ; %but I want the concatenation to reflect the same position that I randomized. actually this is not going to happen because of the sliding window scheme
%pallconn{1,4}{1,6} = pallconn{1,2}{1,6};

%[a.sv, a.mt] = starter_sc(data, pallconn, 1);
[~, a.mt] = starter_sc(data, pallconn, 1);

end