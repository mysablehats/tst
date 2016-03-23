function PCA_hB(featureAllMean,featureAllStd,labelsFeatureAll,fig_id)
%visualization of data in PCA space, with visualization of the percentage
%of the variance captured by individual PCs and their std visualized as
%ellipses
%based on the function from Matej Hoffmann
%featureAllMean - data to visualize
%featureAllStd - standard deviation of the data %optional - if setted
%->visualization of circles
%labelsFeatureAll - labels of data %optional
%fig_id - id of the figure to be plot - default 1
labels_data=1;
circle_vis=1;
if nargin ==3
    fig_id=1;
elseif nargin==2
    labels_data =0;
    fig_id=1;
elseif nargin==1
    labels_data=0;
    circle_vis=0;
    fig_id=1;
end;
    
ARROW_LENGTH = 8;
TIP_ANGLE = 6;
BIPLOTS_ON = false; % these take a lot of time and with too many features are hard to visualize
featureAllMeanInv=featureAllMean;
if circle_vis
    featureAllStdInv=featureAllStd;
end
%% LABELS FOR VISUALIZATION

labels_cells = {};

[n_samples,n_all_features] = size(featureAllMeanInv);
% for i=1:n_samples
%    labels_cells(i).Marker = {'--rs','--bs','--ys','--gs','--cs','--ms','--ks','--ws','--rx'}
%   
%    labels_cells(i).colorVector = GROUND_COLOR_VECTORS(numeric_labels(i,2),:);
%    labels_cells(i).MarkerFaceColor = 'none';%GROUND_COLOR_VECTORS(numeric_labels(i,2),:); %GROUND_COLOR_CODES(numeric_labels(i,2));
%     
% end
% calc eigenvalues:
[V,D] = eig(featureAllMeanInv' * featureAllMeanInv);


% descending order:
V = fliplr(V);
D = rot90(D,2);

% variance captured by individual PC
D_trace = trace(D);
D_diagonal = diag(D);
D_diagonal_percent = (D_diagonal ./D_trace) * 100;

% get cumulative variance matrix
D_diagonal_percent_cumulative(1) = D_diagonal_percent(1);
for i=2:length(D_diagonal_percent)
    D_diagonal_percent_cumulative(i) =  D_diagonal_percent_cumulative(i-1) + D_diagonal_percent(i);
end
last_index_90 = find(D_diagonal_percent_cumulative>=90,1,'first');
last_index_95 =  find(D_diagonal_percent_cumulative>=95,1,'first');

 % we take only first 90% of variance for visualization
D_diagonal_percent_90 = D_diagonal_percent(1:last_index_90); 
D_diagonal_percent_cumulative_90 = D_diagonal_percent_cumulative(1:last_index_90);

f11 = figure(fig_id+1); clf;
set(f11,'position',[400 50 600 700])   
set(f11,'Name','PCA');
subplot(2,2,1)
    %title(gait_string);
    bar(D_diagonal_percent_90);
    xlabel('Principal component');
    ylabel('Percentage of variance explained');
subplot(2,2,2);
    %title(gait_string);
    bar(D_diagonal_percent_cumulative_90);
    xlabel('Principal component');
    ylabel('Cumulative variance explained');

    % data in PCA space:
    X = featureAllMeanInv*V;
    if circle_vis
    SD=featureAllStdInv*V;
    end

    unit_matrix = eye(n_all_features);


    %% PCA space and BIPLOTS
    subplot(2,2,[3 4])
    %f12 = figure(fig_id+2); clf;
    %set(f12,'Name','Data in PCA space - PC 1 and 2');
    title('Data in PCA space - PC 1 and 2');
   % if real_robot
     %   title(['Real robot - ',gait_string],'fontsize',LEGEND_FONTSIZE_BIG);
   % else
       % title(['Simulated robot - ',gait_string],'fontsize',LEGEND_FONTSIZE_BIG);
    %end
    hold on;
    for i=1:size(X,1)
          plot(X(i,1),X(i,2),'--rs','MarkerSize',5)%,'Marker',labels_cells(i).Marker,'MarkerEdgeColor',labels_cells(i).colorVector,'MarkerSize',labels_cells(i).MarkerSize,'MarkerFaceColor',labels_cells(i).MarkerFaceColor); 
          if circle_vis
              X(i,1)
              SD(i,1)
            circle (X(i,1),X(i,2),sqrt(SD(i,1)^2+SD(i,2)^2));
          end
          if labels_data
            text(X(i,1),X(i,2)+0.2,labelsFeatureAll{i});
          end;
    end
    xlabel('1st Principal Component','fontsize',12);
    ylabel('2nd Principal Component','fontsize',12);
    hold off;

    
  
% 
%     
% if BIPLOTS_ON    
%     %f121 = figure(121); clf;
%     %set(f121,'Name','Biplot - Data in PCA space + orig dims - matlab');
%     %biplot(V(:,1:2),'scores',X(:,1:2),'VarLabels',feature_and_sensor_labels_all);
% 
%     f122 = figure(122); clf;
%     set(f122,'Name','Biplot - Data in PCA space + orig dims - PC 1 & 2');
%     %title(gait_string);
%     hold on;
%     sum_of_norms = 0;
%     for i=1:size(X,1)
%           plot(X(i,1),X(i,2),'--rs','Size',5)%,'Marker',labels_cells(i).Marker,'MarkerEdgeColor',labels_cells(i).colorVector,'MarkerSize',labels_cells(i).MarkerSize,'MarkerFaceColor',labels_cells(i).MarkerFaceColor); 
%           sum_of_norms = sum_of_norms + norm([X(i,1),X(i,2)]);
%     end
%     avg_norm = sum_of_norms / size(X,1);
%     xlabel('1st Principal Component');
%     ylabel('2nd Principal Component');
% 
%     % add the arrows
%     SCALE_MULTIPLIER = 10;
%     for i=1:n_all_features
%         point_x = SCALE_MULTIPLIER*avg_norm*V(i,1);
%         point_y = SCALE_MULTIPLIER*avg_norm*V(i,2);
%         arrow([0,0],[point_x,point_y],'Length',ARROW_LENGTH,'TipAngle',TIP_ANGLE);
%         text(point_x,point_y,feature_and_sensor_labels_all(i));
%     end
%     hold off;
% 
%     f123 = figure(123); clf;
%     set(f123,'Name','Biplot - Data in PCA space + orig dims - PC 3 & 4');
%     title(gait_string);
% 
%     hold on;
%     sum_of_norms = 0;
%     for i=1:size(X,1)
%           plot(X(i,3),X(i,4),'--rs','Size',5)%,'Marker',labels_cells(i).Marker,'MarkerEdgeColor',labels_cells(i).colorVector,'MarkerSize',labels_cells(i).MarkerSize,'MarkerFaceColor',labels_cells(i).MarkerFaceColor); 
%           sum_of_norms = sum_of_norms + norm([X(i,3),X(i,4)]);
%     end
%     avg_norm = sum_of_norms / size(X,1);
%     xlabel('3rd Principal Component');
%     ylabel('4th Principal Component');
% 
%     % add the arrows
%     SCALE_MULTIPLIER = 10;
%     for i=1:n_all_features
%         point_x = SCALE_MULTIPLIER*avg_norm*V(i,3);
%         point_y = SCALE_MULTIPLIER*avg_norm*V(i,4);
%         arrow([0,0],[point_x,point_y],'Length',ARROW_LENGTH,'TipAngle',TIP_ANGLE);
%         text(point_x,point_y,feature_and_sensor_labels_all(i));
%     end
%     hold off;
% 
%     f124 = figure(124); clf;
%     set(f124,'Name','Biplot - Data in PCA space + orig dims - PC 5 & 6');
%     title(gait_string);
%     hold on;
%     sum_of_norms = 0;
%     for i=1:size(X,1)
%           plot(X(i,5),X(i,6),'--rs','Size',5)%,'Marker',labels_cells(i).Marker,'MarkerEdgeColor',labels_cells(i).colorVector,'MarkerSize',labels_cells(i).MarkerSize,'MarkerFaceColor',labels_cells(i).MarkerFaceColor); 
%           sum_of_norms = sum_of_norms + norm([X(i,5),X(i,6)]);
%     end
%     avg_norm = sum_of_norms / size(X,1);
%     xlabel('5th Principal Component');
%     ylabel('6th Principal Component');
% 
%     % add the arrows
%     SCALE_MULTIPLIER = 10;
%     for i=1:n_all_features
%         point_x = SCALE_MULTIPLIER*avg_norm*V(i,5);
%         point_y = SCALE_MULTIPLIER*avg_norm*V(i,6);
%         arrow([0,0],[point_x,point_y],'Length',ARROW_LENGTH,'TipAngle',TIP_ANGLE);
%         text(point_x,point_y,feature_and_sensor_labels_all(i));
%     end
%     hold off;
%end
end
