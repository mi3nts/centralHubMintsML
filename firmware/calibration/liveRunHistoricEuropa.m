function [] = liveRunHistoric(nodeIndex)

    display(newline)
    display("---------------------MINTS---------------------")
    display(datestr(datetime('now')))
    addpath("../../functions/")

    addpath("YAMLMatlab_0.4.3")
 
    display("---------------------MINTS---------------------")
%    nodeIndex = round(str2double(nodeIndex))
    startDate = datetime(2018,1,1,'timezone','utc');
    endDate = datetime('now','timezone','utc') -days(1);
    yamlFile =  '../mintsDefinitions.yaml'

	    
%     dateIn    = round(str2double(dateIn))
%     monthIn   = round(str2double(monthIn))
%     yearIn    = round(str2double(yearIn))

    display(newline)
    display("---------------------MINTS---------------------")

    mintsDefinitions   = ReadYaml(yamlFile);

    nodeIDs            = mintsDefinitions.nodeIDs;
    dataFolder         = mintsDefinitions.dataFolder;
    mintsTargets       = mintsDefinitions.mintsTargets;

    rawFolder          =  dataFolder + "/raw";
    rawMatsFolder      =  dataFolder + "/rawMats";
    updateFolder       =  dataFolder + "/liveUpdate/UTDNodes";
    modelsFolder       =  dataFolder + "/modelsMats/UTDNodes/";

    timeSpan           =  seconds(mintsDefinitions.timeSpan);
    nodeID             =  nodeIDs{nodeIndex}.nodeID;
    resultsFile        = modelsFolder+ "resultsNowXT.csv";

    display(newline);
    display("Data Folder Located      @ :"+ dataFolder);
    display("Raw Data Located         @ :"+ rawFolder );
    display("Raw DotMat Data Located  @ :"+ rawMatsFolder);
    display("Update Data Located      @ :"+ updateFolder);
    stringIn = "Daily";
    
    %% Loading from previiously Saved Data files 
    loadName = strcat(rawMatsFolder,"/UTDNodes/UTDNodesMints_",nodeID,".mat");
    load(loadName)

    %% Choosing Input Stack
    eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("inputStack       = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"));
    eval(strcat("latestStack      = mintsDefinitions.latestStack",string(nodeIDs{nodeIndex}.inputStack),";"));
   
    InPre  =  table2array(mintsDataAll(:,mintsInputs));

    [rows, columns] = find(isnan(InPre));
    
    InPre(unique(rows),:) = [];
    mintsDataAll(unique(rows),:) = [];
    
    %% Loading the appropriate models 

    display("Loading Best Models")
    [bestModels,bestModelsLabels] = readResultsNow(resultsFile,nodeID,mintsTargets,modelsFolder); 
    
    % Looping through the dates begining from the latest date 
    
    datesIn = endDate: -days(1): startDate ;
    
    display("Going through each date")

    for dateIndex  = 1:length(datesIn)
       
        currentDate = datesIn(dateIndex);
        printName=getPrintName(updateFolder,nodeID,currentDate,'calibrated');
    
        yearIn      = year(currentDate);
        monthIn     = month(currentDate);
        dateIn       = day(currentDate);
        
   

        validDaysInd= (day(mintsDataAll.dateTime)==dateIn)&...
                        ((month(mintsDataAll.dateTime)==monthIn)&...
                            (year(mintsDataAll.dateTime)==yearIn));

        In = InPre(validDaysInd,:);
        mintsData = mintsDataAll(validDaysInd,:) ;


        
        if (height(mintsData)>0)
            tic
        %% Loading the appropriate models 

            display("Gaining Predictions for Node:" + nodeID + " for the date of " + ...
                       yearIn +" " + monthIn+ " " + dateIn )
                   
            for n = 1: length(bestModels)
               display("Predicting " + mintsTargets{n})
               eval(strcat(mintsTargets{n},"_predicted= " , "predictrsuper(bestModels{n},In);"));
            end


            predictedTablePre2 = mintsData(:,contains(mintsData.Properties.VariableNames,"GPSGPGGA2"));

            predictedTablePre = mintsData(:,contains(mintsData.Properties.VariableNames,"binCount"));


            strCombine = "predictedTablePost = timetable(mintsData.dateTime";

            for n = 1: length(bestModels)
               strCombine = strcat(strCombine,",",mintsTargets{n},"_predicted");
            end

            eval(strcat(strCombine,");"));

            predictedTablePost.Properties.VariableNames =  strrep(strrep(mintsTargets+"_Predicted","_palas",""),"_Airmar","");



            predictedTable = [predictedTablePre2,predictedTablePre,predictedTablePost];

            varNames = predictedTable.Properties.VariableNames;

            for n = 1 :length(varNames) 
                varNames{n} =   strrep(varNames{n},'latitudeCoordinate','Latitude');      
                varNames{n} =   strrep(varNames{n},'longitudeCoordinate','Longitude');      
                varNames{n} =   strrep(varNames{n},'altitude','Altitude');      
            end



            display("Gaining Prediction")
            predictedTablePre  = predictedTable;
            predictionCorrection = zeros(height(predictedTable),1);

            %% Zero Correction 
            %sum(predictedTable.pm1_Predicted<0)
            predictionCorrection = predictionCorrection |(predictedTable.pm1_Predicted<0);
            predictedTable.pm1_Predicted((predictedTable.pm1_Predicted<0),:)=0;

            %sum(predictedTable.pm2_5_Predicted<0)
            predictionCorrection = predictionCorrection | (predictedTable.pm2_5_Predicted<0);
            predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted<0),:)=0;

            %sum(predictedTable.pm4_Predicted<0)
            predictionCorrection = predictionCorrection | (predictedTable.pm4_Predicted<0);
            predictedTable.pm4_Predicted((predictedTable.pm4_Predicted<0),:)=0;

            %sum(predictedTable.pm10_Predicted<0)
            predictionCorrection = predictionCorrection | (predictedTable.pm10_Predicted<0);
            predictedTable.pm10_Predicted((predictedTable.pm10_Predicted<0),:)=0;

            predictionCorrection = predictionCorrection | (predictedTable.pmTotal_Predicted<0);
            predictedTable.pmTotal_Predicted((predictedTable.pmTotal_Predicted<0),:)=0;

            %% PM Corrections 

            %sum((predictedTable.pm2_5_Predicted>predictedTable.pm10_Predicted))
            predictionCorrection = predictionCorrection | (predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted);
            predictedTable.pm4_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) =...
                                       predictedTable.pm2_5_Predicted((predictedTable.pm2_5_Predicted>predictedTable.pm4_Predicted),:) ;  

            %sum((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted))                       
            predictionCorrection = predictionCorrection | (predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted);                       
            predictedTable.pm1_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) =...
                                        predictedTable.pm2_5_Predicted((predictedTable.pm1_Predicted>predictedTable.pm2_5_Predicted),:) ;

            %sum((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted))                          
            predictionCorrection = predictionCorrection | (predictedTable.pm4_Predicted>predictedTable.pm10_Predicted);  
            predictedTable.pm10_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) =...
                                        predictedTable.pm4_Predicted((predictedTable.pm4_Predicted>predictedTable.pm10_Predicted),:) ;

            %sum((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted))                          
            predictionCorrection = predictionCorrection | (predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted);  
            predictedTable.pmTotal_Predicted((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted),:) =...
                                        predictedTable.pm10_Predicted((predictedTable.pm10_Predicted>predictedTable.pmTotal_Predicted),:) ;

            %% Checks                      



                close all
                figure_1= figure('Tag','SCATTER_PLOT',...
                    'NumberTitle','off',...
                    'units','pixels','OuterPosition',[0 0 900 675],...
                    'Name','TimeSeries',...
                    'Visible','off'...
                );

                plot(predictedTable.dateTime,predictedTable.pm10_Predicted,'k-')
                hold on 
                plot(predictedTable.dateTime,predictedTable.pm4_Predicted,'b-')
                plot(predictedTable.dateTime,predictedTable.pm2_5_Predicted,'g-')
                plot(predictedTable.dateTime,predictedTable.pm1_Predicted,'r-')



                legend('on')

                legend('PM_{10}','PM_{4}','PM_{2.5}','PM_{1}')


                ylabel(strcat("PM Levels (\mug/m^{3})"),'FontWeight','bold','FontSize',10);

                % Create xlabel
                xlabel('Date Time','FontWeight','bold','FontSize',10);

            %     % Create title
                Top_Title=strcat("PM Levels");

                Bottom_Title = strcat("Node " +string(nodeID));

                title({" ";Top_Title;Bottom_Title},'FontWeight','bold');


                outFigNamePre    = strcat(updateFolder,"/",nodeID,"/",...
                                                                 num2str(yearIn,'%04d'),"/",...
                                                                 num2str(monthIn,'%02d'),"/",...
                                                                 num2str(dateIn,'%02d'),"/",...
                                                                 "MINTS_",...
                                                                 nodeID,...
                                                                 "_",stringIn,"_",...
                                                                 num2str(yearIn,'%02d'),"_",...
                                                                 num2str(monthIn,'%02d'),"_",...
                                                                 num2str(dateIn,'%02d')...
                                                                 );  




                Fig_name = strcat(outFigNamePre,'.png');
                folderCheck(Fig_name);
                saveas(figure_1,char(Fig_name));

                varNames = predictedTable.Properties.VariableNames;


                for n = 1 :length(varNames)
                    varNames{n} =   strrep(varNames{n},'binCount','Bin');
                    varNames{n} =   strrep(varNames{n},'_Predicted','');
                    varNames{n} =   strrep(varNames{n},'Airmar','');
                    varNames{n} =   strrep(varNames{n},'pm','PM');
                    varNames{n} =   strrep(varNames{n},'temperature','Temperature');
                    varNames{n} =   strrep(varNames{n},'humidity','Humidity');
                    varNames{n} =   strrep(varNames{n},'pressure','Pressure');
                    varNames{n} =   strrep(varNames{n},'dewPoint','DewPoint');
                    varNames{n} =   strrep(varNames{n},'dCn','ParticleConcentration');
                    varNames{n} =   strrep(varNames{n},'pressure','Pressure');      
                    varNames{n} =   strrep(varNames{n},'latitudeCoordinate','Latitude');      
                    varNames{n} =   strrep(varNames{n},'longitudeCoordinate','Longitude');      
                    varNames{n} =   strrep(varNames{n},'altitude','Altitude');      
                end

                predictedTable.Properties.VariableNames = varNames;
                writetimetable(predictedTable,printName)
                toc
            else
                display("No Data For " +  nodeID +" (Year: "+ string(yearIn)+" Month:"+ string(monthIn) +")");
            end % Enough Mints Data 

            clearvars -except bestModels bestModelsLabels columns currentDate dataFolder dateIndex ...
                datesIn dayIn dCn_palas_predicted dewPointAirmar_predicted endDate humidityAirmar_predicted InPre ...
                inputStack latestStack loadName mintsDataAll mintsDefinitions mintsInputLabels mintsInputs ...
                mintsTargets modelsFolder monthIn n nodeID nodeIDs nodeIndex pm10_palas_predicted...
                pm1_palas_predicted pm2_5_palas_predicted pm4_palas_predicted pmTotal_palas_predicted ...
                pressureAirmar_predicted rawFolder rawMatsFolder resultsFile rows startDate stringIn ...
                temperatureAirmar_predicted timeSpan updateFolder validDaysInd yamlFile yearIn 
        
    end % Ending Current Date 
 
 end
 
 %% 5a61 : Aug 2021, Oct 10 - Now 
 %% 5a12 : Sep - Oct 10 @ Joppa 
 
