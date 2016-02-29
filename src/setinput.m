function extinput = setinput(arq_connect, savestruc,data_size) %needs to receive the correct data size so that generateidx may work well
extinput = [];
inputinput = cell(length(arq_connect.sourcelayer),1);
[posidx, velidx] = generateidx(data_size);
for j = 1:length(arq_connect.sourcelayer)
    for i = 1:length(savestruc.gas)
        if strcmp(arq_connect.sourcelayer, savestruc.gas(i).name)
            if isempty(savestruc.gas(i).bestmatch)
                error('wrong computation order. bestmatch field not yet defined.')
            end
            inputinput{j} = savestruc.gas(i).bestmatch;
        else
            if strcmp(arq_connect.layertype, 'pos')
                inputinput{j} = savestruc.train.data(posidx,:);
            elseif strcmp(arq_connect.layertype, 'vel')
                inputinput{j} = savestruc.train.data(velidx,:);
            end
        end
    end
end
if isempty(inputinput)
    error(strcat('Unknown layer type:', arq_connect.layertype,'or sourcelayer:',arq_connect.sourcelayer))
end
if length(inputinput)>1
    for i = 1:length(inputinput)
        extinput = cat(2,extinput,inputinput{i});
    end
else
    extinput = inputinput{:};
end
        
