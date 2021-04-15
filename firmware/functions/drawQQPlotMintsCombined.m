
function [] = drawQQPlotMintsCombined(...
                              dataXTrain,...
                              dataYTrain,...
                              dataXValid,...
                              dataYValid,...
                              limit,...
                              nodeID,...
                              estimator,...
                              summary,...
                              xInstrument,...
                              yInstrument,...
                              units,...
                              saveNameFig)


  %% Create a quantile quantile plot diagram
        figure_1= figure('Tag','SCATTER_PLOT',...
            'NumberTitle','off',...
            'units','pixels','OuterPosition',[0 0 900 675],...
            'Name','Regression',...
            'Visible','off'...
        );
    
        combinedX = [dataXTrain;dataXValid];
        combinedY = [dataYTrain;dataYValid];
    
        %% Plot 0 qq Plot Train
        plot0 = qqplot(combinedX,combinedY);
        set(plot0(3),'Color','black');
        set(plot0(1) ,'MarkerEdgeColor','black');
        hold on      
     
        %% Plot 1 qq Plot Train
        plot1 = qqplot(dataXTrain,dataYTrain);
        set(plot1(3),'Color','blue');
        set(plot1(1) ,'MarkerEdgeColor','blue');

        %% Plot 2 qq Plot Test;
        plot2 = qqplot(dataXValid,dataYValid);
        set(plot2(3),'Color','red');
        set(plot2(1) ,'MarkerEdgeColor','red');
        
        
     %% Plot 3: Scatter Combined
        % find the 0, 25, 50, 75, 100 percentiles
        
        cp=[0 25 50 75 100];
        
        p_Combined=prctile(combinedX,cp);
        p_Estimate_Combined=prctile(combinedY,cp);
        plot3 = scatter(p_Combined,p_Estimate_Combined,'dc','filled');

        gapsX= [.1 -.6 -.8 -1.3 -5.5];
        gapsY= [.2 .6 .8 1.3 0];
        
        for i=1:length(p_Combined)
           text(...
               p_Combined(i)+gapsX(i),...
               p_Estimate_Combined(i)+gapsY(i),...
               num2str(cp(i)),...
               'Color','black',...
               'FontSize',20,...
               'HorizontalAlignment','center'...
               )
        end       

        p_Train=prctile(dataXTrain,cp);
        p_Estimate_Train=prctile(dataYTrain,cp);
        plot4 = scatter(p_Train,p_Estimate_Train,'sg','filled');
        
        p_Valid=prctile(dataXValid,cp);
        p_Estimate_Valid=prctile(dataYValid,cp);
        plot5 = scatter(p_Valid,p_Estimate_Valid,'oy','filled');
        
        


   
        hold off
        % Uncomment the following line to preserve the X-limits of the axes
        xlim([0  limit]);
        % Uncomment the following line to preserve the Y-limits of the axes
        ylim([0  limit]);
        box('on');
        axis('square');
        % add graph paper
        grid on
                     

    ylabel(strcat(yInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title = strcat("N = ",string(length(combinedX)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Create legend
    legend1 = legend([...
                        plot0(3),plot1(3),plot2(3),...
                        plot0(1),plot1(1),plot2(1),...
                        plot4(1),plot5(1),plot3(1)],{...
                        'Combined Reference','Training Reference','Testing Reference',...
                        'Combined Data','Training Data','Testing Data',...
                        'Training Quantiles','Testing Quantiles','Combined Quantiles'})
% 
    set(legend1,'Location','northwest');
    
    set(gca,'XScale','log');set(gca,'YScale','log');

%     
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
    Fig_name = strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end
