function [] = drawQQPlotMints(dataX,...
                              dataY,...
                              limitLow,...                              
                              limitHigh,...
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
            'Visible','on'...
        );
        %% Plot 1 qq Plot 
        plot1 = qqplot(dataX,dataY);
        set(plot1,'DisplayName','QQ Data');
        hold on;

        % find the 0, 25, 50, 75, 100 percentiles
        cp=[0 25 50 75 100];
        p_Valid=prctile(dataX,cp);
        p_Estimate=prctile(dataY,cp);

        hold on
        %% Plot 2: Scatter 
        plot2 = scatter(p_Valid,p_Estimate,'dr','filled');
        gapsX= [-2.5 -4 -4 -4 -4];
        gapsY= [3.5 3.5 3.5 3.5 4];
        for i=1:length(p_Valid)
           text(...
               p_Valid(i)+gapsX(i),...
               p_Estimate(i)+gapsY(i),...
               num2str(cp(i)),...
               'Color','red',...
               'FontSize',20,...
               'HorizontalAlignment','center'...
               )
        end
        hold off
        % Uncomment the following line to preserve the X-limits of the axes
        xlim([limitLow  limitHigh]);
        % Uncomment the following line to preserve the Y-limits of the axes
        ylim([limitLow  limitHigh]);
        box('on');
        axis('square');
        % add graph paper
        grid on
                     

    ylabel(strcat(yInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
%     Top_Title=strcat(estimator," - " +summary);
%     Top_Title=strcat(estimator," - Node " +string(nodeID)," - " ,summary);
    Top_Title=strcat(estimator," ",summary);
    Middle_Title = strcat("Quantile Quantile Plot");
    Bottom_Title = strcat("Validating: N = ",string(length(dataX)));
    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Create legend
    legend1 = legend([plot1(1),plot1(3),plot2(1)],{'Data','Reference Line','Quantiles'});
 
    set(legend1,'Location','northwest');
    
    set(gca,'XScale','log');set(gca,'YScale','log');

    Fig_name = strcat(saveNameFig);
    saveas(figure_1,char(Fig_name));
%     Fig_name = strcat(saveNameFig);
%     saveas(figure_1,char(Fig_name));


end
