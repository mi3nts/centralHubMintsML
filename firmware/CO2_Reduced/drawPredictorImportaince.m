function [] = drawPredictorImportaince(regressionTree,...
                                        estimator,...
                                        nodeID,...
                                         summary,...
                                         inputLabels,...
                                        saveNameFig)
%GETPREDICTORIMPORTAINCE Summary of this function goes here
%   Detailed explanation goes here

imp = 100*(regressionTree.predictorImportance/sum(regressionTree.predictorImportance));

% imp = regressionTree.predictorImportance;


limit = max(imp)+3
[sortedImp,isortedImp] = sort(imp,'descend');

   figure_1= figure('Tag','PREDICTOR_IMPORTAINCE_PLOT',...
        'NumberTitle','off',...
        'units','pixels',...   
        'OuterPosition',[0 0 2000 1300],...
        'Name','predictorImportance',...
        'Visible','on'...
    )



barh(imp(isortedImp));hold on ; grid on ;
set(gca,'ydir','reverse');
xlabel('Scaled Importance(%)','FontSize',20);
ylabel('Predictor Rank','FontSize',20);
   % Create title
    % Create title
    Top_Title=strcat(estimator," " +summary);
%     Top_Title=strcat(estimator," - Node " +string(nodeID)," - " ,summary);
    Middle_Title = strcat("Predictor Importance");
    title({Top_Title;Middle_Title},'FontWeight','bold','FontSize',25);
    
    
% title('Predictor Importaince Estimates')
ylim([.5 (20+.5)]);
yticks([1:1:20])
xlim([0 (limit)]);
xticks([0:1:limit])

sortedPredictorLabels= inputLabels(isortedImp);

for n = 1:20
         text(...
            imp(isortedImp(n))+ 0.05,n,...
            sortedPredictorLabels(n),...
            'FontSize',15 ...
           )
end
%     set(gca,'XScale','log')
    
    Fig_name = strcat(saveNameFig);
    saveas(figure_1,char(Fig_name));
%     Fig_name = strcat(saveNameFig,'.fig');
%     saveas(figure_1,char(Fig_name));

%     
%     print('ScreenSizeFigure','-dpng','-r100')
    
end
