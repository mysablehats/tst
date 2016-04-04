function [extinput_clipped, extinput, inputends,y, removeremove, indexes] = setinput(arq_connect, savestruc,data_size, svst_t_v) %needs to receive the correct data size so that generateidx may work well
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
midremove = [];
inputinput = cell(length(arq_connect.sourcelayer),1);
removeremove = inputinput; %they are the same size
%if inputends dont coincide this function will give a strange error
inputends = [];
[posidx, velidx] = generateidx(data_size, arq_connect.params.skelldef);
for j = 1:length(arq_connect.sourcelayer)
    foundmysource = false;
    for i = 1:length(savestruc.gas)
        if strcmp(arq_connect.sourcelayer{j}, savestruc.gas(i).name)
            if isempty( svst_t_v.gas(i).bestmatchbyindex)
                error('wrong computation order. bestmatch field not yet defined.')
            end
            oldinputends = inputends;
            [inputinput{j},inputends,y, indexes] = longinput( savestruc.gas(i).nodes(:,svst_t_v.gas(i).bestmatchbyindex), arq_connect.q, svst_t_v.gas(i).inputs.input_ends, svst_t_v.gas(i).y,svst_t_v.gas(i).inputs.index);
            
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
            removeremove{1} = turtlesallthewaydown(svst_t_v.gas(i).whotokill);                     
            foundmysource = true;
        end
    end
    if ~foundmysource        
            if strcmp(arq_connect.layertype, 'pos')
                [inputinput{j},inputends,y, indexes] = longinput(svst_t_v.data(posidx,:), arq_connect.q, svst_t_v.ends, svst_t_v.y, num2cell(1:size(svst_t_v.data,2)));
                %inputinput{j} = svst_t_v.data(posidx,:); %
                %ends is savestructure.train.ends
            elseif strcmp(arq_connect.layertype, 'vel')
                [inputinput{j},inputends,y, indexes] = longinput(svst_t_v.data(velidx,:), arq_connect.q, svst_t_v.ends, svst_t_v.y, num2cell(1:size(svst_t_v.data,2)));
                %inputinput{j} = svst_t_v.data(velidx,:); %
                %ends is savestructure.train.ends
            elseif strcmp(arq_connect.layertype, 'all')
                [inputinput{j},inputends,y, indexes] = longinput(svst_t_v.data, arq_connect.q, svst_t_v.ends, svst_t_v.y, num2cell(1:size(svst_t_v.data,2)));
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
        midremove = cat(1,midremove,removeremove{i}); %{i}
    end
else
    extinput = inputinput{:};
    midremove = turtlesallthewaydown(removeremove); 
    %oh, it may be wrong,,, have
    %to check wrappung and unwrapping %%it was wrong, I will check
    %unwrapping inside removebaddata
    %[extinput_clipped, inputends_clipped, y_clipped]= removebaddata(extinput, inputends, y, removeremove); % this wrong, since I will only avoid putting bad sets into the gas. so it is fortunately simpler than I thought!
    
end
extinput_clipped= removebaddata(extinput, indexes, midremove, arq_connect.q); 
end
function icli = removebaddata(inp, idxx,rev, qp) % inpe, y,
if ~isempty(rev)
    q = qp(1);
    switch length(qp)
        case 1
            p = 0;
            r = 1;
        case 2
            p = qp(2);
            r = 1;
        case 3
            p = qp(2);
            r = qp(3);
    end
    dbgmsg('OMG, I am removing some points!!!!!!!!!!!!!!!!!!!!')
    
    % I will make this a basic implementation. The cells should have
    % appropriate multi-layer data points to remove, so it will likely not be
    % that hard to debug once the error occurs when there are different
    % concatenation levels to remove here in this place.
    
    %[idxx{1}{1}{:}] is the first element of 3 that makes the my 9 element
    %supervector
    
    %[rev{1,1}{:}] is the first element I want to check it against. if they are
    %the same, then it is out
    
    allitems = 1:size(inp,2);
    eliminate = [];
    imax = size(rev,2);
    jmax = size(idxx,2);
    for i = 1:imax
        currrev = [rev{1,i}{:}];
        jlower = max([1 fix((currrev(1)*.9)/(q*(p+1)*r))-1 ]); % I think indexes will be always ordered, so I THINK this will always work...
        jhigher = min([jmax ceil((currrev(end))/(q*(p+1)*r))+1]); % multiply by 10 if it doesnt work %%% there is some irregularity here because of actions that dont end where they should, so each ending action can cause you to drift additionally q*(p+1)*r-1 data samples      
        for j = jlower:jhigher         %1:jmax %%% I will try to improve this by limiting the data that I look up based on q!
            kmax = size(idxx{j},2);
            for k = 1:kmax                
                curridxx = [idxx{j}{k}{:}];
                if all(currrev==curridxx) %maybe I can try this, if it fails do a catch opening it once more. it will be the world's slowest function, but...
                    eliminate = cat(2, eliminate, j);
                elseif j==jlower&&currrev(1)<curridxx(3)
                    %dbgmsg('Out of bounds with current indexing scheme!',1)
                    error('Out of bounds with current indexing scheme!')
                end
            end
        end
    end
    whattoget = setdiff(allitems, eliminate);
    icli = inp(:,whattoget);
    dbgmsg('I removed', num2str(size(unique(eliminate),2)), ' out of ', num2str(size(inp,2)), ' points!',1)
else
    icli = inp;
end

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
