function savestructure = gas_method(savestructure, arq_connect, i,j, dimdim)
%% Gas Method
% This is a function to go over a gas of the classifier, populate it with the apropriate input and generate the best matching units for the next layer.  
%% Setting up some labels
        savestructure.gas(j).name = arq_connect.name;
        savestructure.gas(j).method = arq_connect.method;
      
%% Choosing the right input for this layer
% This calls the function set input that chooses what will be written on the .inputs variable. It also handles the sliding window concatenations and saves the .input_ends properties, so that this can be done recursevely. 
% After some consideration, I have decided that all of the long inputing
% will be done inside setinput, because it it would be easier. 

        [savestructure.train.gas(j).inputs.input, savestructure.train.gas(j).inputs.input_ends, savestructure.train.gas(j).y]  = setinput(arq_connect, savestructure, dimdim, savestructure.train); %%%%%%
  
%% 
% After setting the input, we can actually run the gas, either a GNG or the
% GWR function we wrote.
        %%%% PRE-MESSAGE
        dbgmsg('Working on gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with method: ',savestructure.gas(j).method ,' for process:',num2str(i),1)
        %DO GNG OR GWR
        if strcmp(arq_connect.method,'gng')
            %do gng
            [savestructure.gas(j).nodes, savestructure.gas(j).edges, ~, ~] = gng_lax(savestructure.train.gas(j).inputs.input,arq_connect.params); 
        elseif strcmp(arq_connect.method,'gwr')
            %do gwr
            [savestructure.gas(j).nodes, savestructure.gas(j).edges, ~, ~] = gwr(savestructure.train.gas(j).inputs.input,arq_connect.params); 
        else
            error('unknown method')
        end
        %%%% POS-MESSAGE
        dbgmsg('Finished working on gas: ''',savestructure.gas(j).name,''' (', num2str(j),') with method: ',savestructure.gas(j).method ,'.Num of nodes reached:',num2str(size(savestructure.gas(j).nodes,2)),' for process:',num2str(i),1)
        %%%% FIND BESTMATCHING UNITS
        
%% Best-matching units
% The last part is actually finding the best matching units for the gas.
% This is a simple procedure where we just find from the gas units (nodes
% or vectors, as you wish to call them), which one is more like our input.
% It is a filter of sorts, and the bestmatch matrix is highly repetitive. 

% I questioned if I actually need to compute this matrix here or maybe
% inside the setinput function. But I think this doesnt really matter.
% Well, for the last gas it does make a difference, since these units will
% not be used... Still I will  not fix it unless I have to.
        %PRE MESSAGE  
        dbgmsg('Finding best matching units for gas: ''',savestructure.gas(j).name,''' (', num2str(j),') for process:',num2str(i),1)
        [~, savestructure.train.gas(j).bestmatchbyindex] = genbestmmatrix(savestructure.gas(j).nodes, savestructure.train.gas(j).inputs.input, arq_connect.layertype, arq_connect.q); %assuming the best matching node always comes from initial dataset!
end