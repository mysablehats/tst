function [extinput_clipped, inputends,y, removeremove] = setinput(arq_connect, savestruc,data_size, svst_t_v) %needs to receive the correct data size so that generateidx may work well
%%%%%% this is the place to get long inputs actually.
%arqconnect has only the current layer, so it is flat
%inputends need to be the same for everything to work out fine
%theoretically it makes sense that they are not the same size and then the
%smallest should be used and the end bits of each action set, discarded and
%then rematched to fit the real correspondent. I don't really know how to
%do that, maybe I need to match each action with some extra indexing, or
%make a clever indexing function that will discard the right amount of end
%bits at the right part
% Or I perhaps should carry each action separatelly, because it would make
% things easier, but this would require a major rewrite of everything I did
% so far. So in short: same "ends" for every component.
extinput = [];
inputinput = cell(length(arq_connect.sourcelayer),1);
removeremove = inputinput; %they are the same size
%if inputends dont coincide this function will give a strange error
inputends = [];
[posidx, velidx] = generateidx(data_size);
for j = 1:length(arq_connect.sourcelayer)
    foundmysource = false;
    for i = 1:length(savestruc.gas)
        if strcmp(arq_connect.sourcelayer{j}, savestruc.gas(i).name)
            if isempty( svst_t_v.gas(i).bestmatchbyindex)
                error('wrong computation order. bestmatch field not yet defined.')
            end
            oldinputends = inputends;
            [inputinput{j},inputends,y] = longinput( savestruc.gas(i).nodes(:,svst_t_v.gas(i).bestmatchbyindex), arq_connect.q, svst_t_v.gas(i).inputs.input_ends, svst_t_v.gas(i).y);
            
            %%%check for misalignments of inputends
            if ~isempty(oldinputends)
                if ~all(oldinputends==inputends)
                    error('Misaligned layers! Alignment not yet implemented.')
                end
            end
            %%% old  longinput call. I will no longer create .bestmatch, so
            %%% I need to create it on the fly from gasnodes
            %            [inputinput{j},inputends,y] = longinput( svst_t_v.gas(i).bestmatch, arq_connect.q, svst_t_v.gas(i).inputs.input_ends, svst_t_v.gas(i).y);

            %inputinput{j} = longinput(savestruc.gas(i).bestmatch; %
            removeremove{j} = svst_t_v.gas(i).whotokill;                     
            foundmysource = true;
        end
    end
    if ~foundmysource        
            if strcmp(arq_connect.layertype, 'pos')
                [inputinput{j},inputends,y] = longinput(svst_t_v.data(posidx,:), arq_connect.q, svst_t_v.ends, svst_t_v.y);
                %inputinput{j} = svst_t_v.data(posidx,:); %
                %ends is savestructure.train.ends
            elseif strcmp(arq_connect.layertype, 'vel')
                [inputinput{j},inputends,y] = longinput(svst_t_v.data(velidx,:), arq_connect.q, svst_t_v.ends, svst_t_v.y);
                %inputinput{j} = svst_t_v.data(velidx,:); %
                %ends is savestructure.train.ends
            elseif strcmp(arq_connect.layertype, 'all')
                [inputinput{j},inputends,y] = longinput(svst_t_v.data, arq_connect.q, svst_t_v.ends, svst_t_v.y);
                %inputinput{j} = svst_t_v.data; %
                %ends is savestructure.train.ends
            end
    end
    if isempty(inputinput)
        error(strcat('Unknown layer type:', arq_connect.layertype,'or sourcelayer:',arq_connect.sourcelayer))
    end
end
if length(inputinput)>1
    for i = 1:length(inputinput)
        extinput = cat(1,extinput,inputinput{i}); % this part should check for the right ends, ends should also be a cell array, and they should be concatenated properly
        removeremove = cat(2,removeremove,removeremove{i});
    end
else
    extinput = inputinput{:};
    removeremove = unique(removeremove{:}); %oh, it may be wrong,,, have to check wrappung and unwrapping
    %[extinput_clipped, inputends_clipped, y_clipped]= removebaddata(extinput, inputends, y, removeremove); % this wrong, since I will only avoid putting bad sets into the gas. so it is fortunately simpler than I thought!
    extinput_clipped= removebaddata(extinput, removeremove); 
end
end
function icli = removebaddata(inp, rev) % inpe, y,

allitems = 1:size(inp,2);
whattoget = setdiff(allitems, rev);
icli = inp(:,whattoget);


%ok, inputends is a problem!!!
% ecli = inpe;
% if ~isempty(rev)
%     absolends = cumsum(inpe);
%     for i =1:size(rev,2)
%         
%         if rev(i)<absolends(1)
%             ecli(1) = ecli(1)-1;
%         else
%             for j =2:size(inpe,2)
%                 if (absolends(j)>=rev(i))&&(rev(i)>absolends(j-1))
%                     ecli(j) = ecli(j)-1;
%                 end
%             end
%         end
%     end
% end
% ycli = y(:,whattoget);

end
