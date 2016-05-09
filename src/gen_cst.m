%creates a structure with the results of different trials
if ~exist('b','var')
    error('b not defined')
end

if ~exist('cst','var')
    cst = struct(); 
else
    cst(end+1) = cst(1);
end

cst(end).nodes = NODES;
cst(end).labels = labels_names;
cst(end).datasettype = datasettype;
cst(end).activity_type = activity_type;
cst(end).sampling_type = sampling_type;
cst(end).datainputvectorsize = size(data.train,1);
cst(end).trainsubjectindexes = allskeli1;
cst(end).valsubjectindexes = allskeli2;
if exist('prefilter','var')
    cst(end).prefilter = prefilter;
else
    dbgmsg('Oh, this was done using an older version of starter_script. Preconformation parameters are unknown. Please change this into appropriate cell of conformaction params used',1)
    cst(end).prefilter = '.prefilter is unknown. Please change into appropriate str of >>>conformaction<<< params used';
end

if exist('preconditions','var')
    cst(end).preconditions = preconditions;
else
    dbgmsg('Oh, this was done using an older version of conformskel. Preconditioning parameters are unknown. Please change this into appropriate cell of conformskel params used',1)
    cst(end).preconditions = '.preconditions is unknown. Please change into appropriate cell of >>>conformskel<<< params used';
end
cst(end).allconn = allconn;

cst(end).params = params;
%%%% if I was more careful, I wouldnt need to save paramsZ variable - I
%%%% think allconn should have it, maybe I should change the point in which
%%%% I update it so that it makes more sense and I don't have repetitive
%%%% information that is never read. Anyway, doing this is much simpler,
%%%% although very ugly...
%%%% If I ever have the time, this should be fixed!
cst(end).paramsZ = paramsZ;
cst(end).metrics(length(b),length(b(1).mt)) = struct; %,2,size(b(1).mt(1).confusions.val,1),size(b(1).mt(1).confusions.val,2));

for ii = 1:length(b)
    for jj= 1:length(b(ii).mt)
        cst(end).metrics(ii,jj).val = b(ii).mt(jj).confusions.val;
        cst(end).metrics(ii,jj).train = b(ii).mt(jj).confusions.train;
        if ~isfield(b(ii).mt(jj).outparams, 'accumulatedepochs')
            cst(end).metrics(ii,jj).accumulatedepochs = paramsZ(ii).MAX_EPOCHS;
        else
            cst(end).metrics(ii,jj).accumulatedepochs = b(ii).mt(jj).outparams.accumulatedepochs;
        end
    end
end
cst
