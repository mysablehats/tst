function a = executioncore_in_starterscript(paramsZ,allconn, data)
n = randperm(size(data.train,2)-3,2); % -(q-1) necessary because concatenation reduces the data size!
paramsZ.startingpoint = [n(1) n(2)];
pallconn = allconn;
pallconn{1}{1,6} = paramsZ; % I only change the initial points of the position gas
[~, a.mt] = starter_sc(data, pallconn, 1);
a.bestmtallconn.sensitivity = pallconn;
end