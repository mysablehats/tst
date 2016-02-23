tic()

%generate_skel_data %% very time consuming -> also will generate a new
%validation and training set

clear all

load_skel_data
[data_train, data_val] = removehipbias(data_train, data_val);

NODES =  [10];

for num_of_nodes = NODES
    tic
    [nodes_gwr,edges_gwr, ~, ~] = gwr(data_train,num_of_nodes);
    toc
    tic
    [nodes_gng,edges_gng, ~, ~] = gng_lax(data_train,num_of_nodes);
    toc
    save(strcat('../share/gng_gwr',num2str(num_of_nodes),'.mat' ))
end
for num_of_nodes = NODES
    
    load(strcat('../share/gng_gwr',num2str(num_of_nodes),'.mat' ))
    
    figure
    
    [class_train_gwr, class_val_gwr] = untitled6(nodes_gwr, data_train,data_val, y_train, y_val,strcat('GWR Classifier ',num2str(num_of_nodes)));

    figure

    [class_train_gng, class_val_gng] = untitled6(nodes_gng, data_train, data_val, y_train, y_val,strcat('GNG Classifier ', num2str(num_of_nodes)));
end

toc()