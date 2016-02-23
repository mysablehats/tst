%generate_skel_data %% very time consuming -> also will generate a new
%%validation and training set

clear all

load_skel_data
[data_train, data_val] = removehipbias(data_train, data_val);
[data_train, y_train] = shuffledataftw(data_train, y_train);
NODES =  [300 300 300 300 1000 1000 1000 1000];
NODES = NODES/10;
savestructure = struct('nodes',0,'nodes_gwr',[],'edges_gng',[]);
parfor i = 1:length(NODES)
    num_of_nodes = NODES(i);
    tic
    [nodes_gwr,edges_gwr, ~, ~] = gwr(data_train,num_of_nodes);
    toc
%     tic
%     [nodes_gng,edges_gng, ~, ~] = gng_lax(data_train,num_of_nodes);
%     toc
    savestructure(i).nodes = num_of_nodes;
    savestructure(i).nodes_gwr = nodes_gwr;
    savestructure(i).edges_gwr = edges_gwr;
%    savestructure(i).nodes_gng = nodes_gng;
%    savestructure(i).edges_gng = edges_gng;
end
for i = 1:length(NODES)
    num_of_nodes = NODES(i);
    nodes_gwr = savestructure(i).nodes_gwr;
    edges_gwr = savestructure(i).edges_gwr;
%     nodes_gng = savestructure(i).nodes_gng;
%     edges_gng = savestructure(i).edges_gng;
    save(strcat('../share/gng_gwr',num2str(num_of_nodes),'_',num2str(i),'.mat' ))
end
for i = 1:length(NODES)
    num_of_nodes = NODES(i);
    load(strcat('../share/gng_gwr',num2str(num_of_nodes),'_',num2str(i),'.mat' ))
end
confusionstruc = struct('nodes',0,'class_train_gwr',[],'class_val_gwr',[]);
parfor i = 1:length(NODES)
    num_of_nodes = NODES(i);
    nodes_gwr = savestructure(i).nodes_gwr;
    [class_train_gwr, class_val_gwr] = untitled6(nodes_gwr, data_train,data_val, y_train);
    confusionstruc(i).class_train_gwr = class_train_gwr;
    confusionstruc(i).class_val_gwr = class_val_gwr;
%     figure
% 
%     [class_train_gng, class_val_gng] = untitled6(nodes_gng, data_train, data_val, y_train, y_val,strcat('GNG Classifier ', num2str(num_of_nodes)));
%     confusionstruc(i).class_train_gng = class_train_gng;
%     confusionstruc(i).class_val_gng = class_val_gng;
end
%figure
%plotconfusion(ones(size(y_val)),y_val, 'always a fall on Validation Set:',zeros(size(y_val)),y_val, 'never a fall on Validation Set:')
for i=1:length(confusionstruc)
    num_of_nodes = NODES(i);
    class_train = confusionstruc(i).class_train_gwr;
    class_val = confusionstruc(i).class_val_gwr;
    namename = strcat('GWR Classifier ',num2str(num_of_nodes));
    figure
    u = plotconfusion(y_val,class_val, 'Performed on Validation Set:',y_train,class_train,'Performed on the Training Set:'); % I am using the wrong names here. My Y is actually the T and the class_val is the y... I should change this everywhere, but for now
    u.Name = namename;    
end
clear i
