
clc
clear all 
close all 

poolobj = gcp('nocreate');
delete(poolobj);


display(newline)
display("---------------------MINTS---------------------")

addpath("../../functions/")

addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml('../mintsDefinitions.yaml')

dataFolder         = mintsDefinitions.dataFolder;
nodeIDs     = mintsDefinitions.nodeIDs;
timeSpan    = seconds(mintsDefinitions.timeSpan);
binsPerColumn      = mintsDefinitions.binsPerColumn;
numberPerBin       = mintsDefinitions.numberPerBin ;
pValid             = mintsDefinitions.pValid;
airmarID           = mintsDefinitions.airmarID;
instruments        = mintsDefinitions.instruments;
units               = mintsDefinitions.units;
poolWorkers         = mintsDefinitions.poolWorkers;

parpool(poolWorkers)

mintsTargets      = mintsDefinitions.mintsTargets;
mintsTargetLabels = mintsDefinitions.mintsTargetLabels;


rawFolder           =  dataFolder + "/raw";
rawMatsFolder       =  dataFolder + "/rawMats";
UTDMatsFolder       =  rawMatsFolder  + "/UTDNodes";
referenceFolder     =  dataFolder + "/reference";
referenceMatsFolder =  dataFolder + "/referenceMats";
palasFolder         =  referenceFolder       + "/palasStream";
palasMatsFolder     =  referenceMatsFolder   + "/palas";
driveSyncFolder     =  strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    =  dataFolder + "/mergedMats/UTD";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/UTDNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/UTDNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/UTDNodes";
resultsFolder       =  dataFolder + "/results/UTDNodes";

% for graphing 
limitsLow  ={ 0,  0,  0,  0,  0  , 0  ,0,  20, 10, .98};
limitsHigh= {20, 40, 50, 60,  100, 500, 45,  75, 25,  .995};

versionStrTrain = ['UTD_Rsl_All_' datestr(today,'yyyy_mm_dd')];
versionStrMdl   = versionStrTrain;
disp(versionStrMdl)
display(newline)
dailyString        = "UTD_Rsl_All_Daily";
dailyStringImp     = "UTD_Rsl_All_Daily_Imp";
disp(dailyString)
display(newline)          
graphTitle1     = "Super Learner All Inputs";
disp(graphTitle1)
display(newline)           
                        
display(newline)
folderCheck(dataFolder)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawMatsFolder)
display("UTD Nodes DotMat Data Located @ :"+ UTDMatsFolder)
display("Reference Data Located @: "+ referenceFolder )
display("Reference DotMat Data Located @ :"+ referenceMatsFolder)
display("Palas Raw Data Located @ :"+ palasFolder)
display("Palas DotMat Data Located @ :"+ palasMatsFolder)
display("Car GPS Files Located @ :"+ GPSFolder)

%% Loading Files 
display("Loading Palas Files")
load(strcat(palasMatsFolder,"/palas.mat"));
palasData = palas;

display("Loading GPS Files");
load(strcat(GPSFolder,"/carMintsGPSCoords.mat"));
carGpsData = mintsData;

display("Loading Airmar Files");
load(strcat(airmarFolder,"/airMar_",airmarID,".mat"));
airmarData = mintsDataAll;
% The airmar was always at the cage, but just incase I am only taking
% inputs that has GPS. 

airmarData = removevars( airmarData, {...
                        'courseOGTrue'                           ,...
                        'courseOGMagnetic'                       ,...
                        'speedOverGroundKnots'                   ,...
                        'speedOverGroundKMPH'                    ,...
                        'heading'                                ,...
                        'barrometricPressureMercury'             ,...
                        'barrometricPressureBars_mintsDataWimda' ,...
                        'windDirectionTrue'                      ,...
                        'windDirectionMagnetic'                  ,...
                        'windSpeedKnots'                         ,...
                        'windSpeedMetersPerSecond'               ,...
                        'windAngle'                              ,...
                        'windSpeed'                              ...
                        });


airmarDataWSTC     = gpsCropCoord(airmarData,32.992179, -96.757777,0.0015,0.0015);

airmarDataWSTC     = removevars( airmarDataWSTC, {...    
                                'latitudeCoordinate'  ,...
                                'longitudeCoordinate'  });      
                            
airmarDataWSTC.Properties.VariableNames =    {'temperatureAirmar'    ,...                    
                                            'humidityAirmar'            ,...          
                                            'dewPointAirmar'                ,...              
                                            'pressureAirmar'};
                                        
%% Syncing Data 
display("Aligning GPS data with Palas Data")
palasWithGPS  =  rmmissing(synchronize(palasData,carGpsData,'intersection'));

display("WSTC Palas Data")
palasWSTC = gpsCropCoord(palasWithGPS,32.992179, -96.757777,0.0015,0.0015);
palasWSTC = removevars( palasWSTC, {...    
                                'latitudeCoordinate'  ,...
                                'longitudeCoordinate'  });

display("Palas With Airmar")
palasWithAirmar  =  rmmissing(synchronize(palasWSTC,airmarDataWSTC,'intersection'));

%% Loading UTD Data and merging them with Palas Data 
display("Analysis")

% Check if availble for UTD Nodes 


% 

results=  struct;

for nodeIndex = 1:length(nodeIDs)
    nodeResults=  struct;
    
    nodeID = nodeIDs{nodeIndex}.nodeID;
    
    % Defining the Input Stack
    eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"))
    eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"))
    
    
    % if file Exists was recorded 
    fileName  = strcat(rawMatsFolder,'/UTDNodes/UTDNodesMints_',nodeID,'.mat');;

    if isfile(fileName)
        load(fileName);
    else
       display(strcat("No Data Exists for Node: ",nodeID)); 
       continue;
    end
    
    %% Cropping GPS Coordinates 
    utdMintsAll = GPSCropCoordinatesUTD(mintsDataAll,32.992179, -96.757777,0.0015,0.0015);
    
    %% Gaining Only input Variables for training 
    
    utdMintsTraining  = rmmissing(utdMintsAll(:,mintsInputs));
    
    % if enough data was recorded 
    if (height(utdMintsTraining)<100)
       display(strcat("Not enough Data points for Node: ",nodeID));
       continue 
    end    
    
    
    utdWithTargets =  rmmissing(synchronize(utdMintsTraining,palasWithAirmar,'intersection'));
                                                                  
    display("Save merged data for calibration: "+nodeID )
    fileNameStr = strcat(mergedMatsFolder,"/utdWithTargets_", nodeID,".mat");
    folderCheck(fileNameStr)
    save(fileNameStr,...
            'utdWithTargets')                 
    
    %% Creating Training Data for calibration
    display(newline)
    display("Creating Training Data Sets for Node: "+ nodeID )  
    
<<<<<<< HEAD
    for targetIndex = 1: length(mintsTargets)              
	try
        target = mintsTargets{targetIndex};
        targetLabel = mintsTargetLabels{targetIndex};

        display(newline)
        display("Gainin Data set for Node "+ nodeID + " with target output " + target)  
        [In_Train,Out_Train,...
            In_Validation,Out_Validation,...
                trainingTT, validatingTT,...
                    trainingT, validatingT ] ...
                                    = representativeSampleTT(utdWithTargets,mintsInputs,target,pValid,binsPerColumn,numberPerBin);    

        if(target == "dCn_palas" )
            trainingT(trainingT.dCn_palas == Inf,:) = [];
            In_Train(trainingT.dCn_palas == Inf,:) = [];
            Out_Train(trainingT.dCn_palas == Inf,:) = [];
            In_Validation(validatingT.dCn_palas == Inf,:) = [];
            Out_Validation(validatingT.dCn_palas == Inf,:) = [];
            trainingTT(trainingT.dCn_palas == Inf,:) = [];
            validatingTT(validatingT.dCn_palas == Inf,:) = [];
            trainingT(trainingT.dCn_palas == Inf,:) = [];
            validatingT(validatingT.dCn_palas == Inf,:) = [];
        end                        
                                
        display("Running Regression")
  
        tic     
        
        OutDescription='UTD Calibration';
        Mdl = fitrsuper(In_Train,Out_Train,In_Validation,Out_Validation,OutDescription);
        toc

%--------------------------------------------------------------------------

        
        %% Saving Model Files 
        display(strcat("Saving Model Files for Node: ",string(nodeID), " & target :" ,targetLabel));
        modelsSaveNameDaily = getMintsNameGeneral(modelsMatsFolder,nodeID,...
                                    target,"daily_Mdl")
        folderCheck(modelsSaveNameDaily)
        
        modelsSaveName      = strrep(modelsSaveNameDaily,"daily_Mdl",strcat(versionStrMdl,"/",versionStrMdl))                                                
        folderCheck(modelsSaveName)
        
        save(modelsSaveName,'Mdl',...
                            'mintsInputs',...
                            'mintsInputLabels',...
                            'target',...
                            'targetLabel'...
                             )    
                         
        save(modelsSaveNameDaily,'Mdl',...
                            'mintsInputs',...
                            'mintsInputLabels',...
                            'target',...
                            'targetLabel'...
                             )                     
        
             
        trainingSaveNameDaily = getMintsNameGeneral(trainingMatsFolder,nodeID,...
                                    target,dailyString)
        folderCheck(trainingSaveNameDaily)                        
        
        trainingSaveName      = strrep(trainingSaveNameDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain))                        
        folderCheck(trainingSaveName) 
        
        save(trainingSaveNameDaily,...
                 'Mdl',...
                 'In_Train',...
                 'Out_Train',...
                 'In_Validation',...
                 'Out_Validation',...
                 'trainingTT',...
                 'validatingTT',...
                 'trainingT',...
                 'validatingT',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'target',...
                 'targetLabel',...
                 'nodeID',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'binsPerColumn',...
                 'numberPerBin',...
                 'pValid' ...
             )                        
                                
        save(trainingSaveName,...
                 'Mdl',...
                 'In_Train',...
                 'Out_Train',...
                 'In_Validation',...
                 'Out_Validation',...
                 'trainingTT',...
                 'validatingTT',...
                 'trainingT',...
                 'validatingT',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'target',...
                 'targetLabel',...
                 'nodeID',...
                 'mintsInputs',...
                 'mintsInputLabels',...
                 'binsPerColumn',...
                 'numberPerBin',...
                 'pValid' ...
             )
               
        %% Estimating Statistics 
       
        outTrainEstimate= predictrsuper(Mdl,In_Train);
        outValidEstimate= predictrsuper(Mdl,In_Validation);
       
                               
%         %% Visual Analysis
        display(newline);
        combinedFigDaily   = getFileNameFigure(plotsFolder,nodeID,target,dailyString)
        folderCheck(combinedFigDaily) 
=======
    for targetIndex = 1: length(mintsTargets)   
        try
>>>>>>> ec433a924b48fb31dde01c02bb96f0866550ead1
        
            target = mintsTargets{targetIndex};
            targetLabel = mintsTargetLabels{targetIndex};

            display(newline)
            display("Gainin Data set for Node "+ nodeID + " with target output " + target)  
            [In_Train,Out_Train,...
                In_Validation,Out_Validation,...
                    trainingTT, validatingTT,...
                        trainingT, validatingT ] ...
                                        = representativeSampleTT(utdWithTargets,mintsInputs,target,pValid,binsPerColumn,numberPerBin);    

            if(target == "dCn_palas" )
                trainingT(trainingT.dCn_palas == Inf,:) = [];
                In_Train(trainingT.dCn_palas == Inf,:) = [];
                Out_Train(trainingT.dCn_palas == Inf,:) = [];
                In_Validation(validatingT.dCn_palas == Inf,:) = [];
                Out_Validation(validatingT.dCn_palas == Inf,:) = [];
                trainingTT(trainingT.dCn_palas == Inf,:) = [];
                validatingTT(validatingT.dCn_palas == Inf,:) = [];
                trainingT(trainingT.dCn_palas == Inf,:) = [];
                validatingT(validatingT.dCn_palas == Inf,:) = [];
            end                        

            display("Running Regression")

            tic     

            OutDescription='UTD Calibration';
            Mdl = fitrsuper(In_Train,Out_Train,In_Validation,Out_Validation,OutDescription);
            toc

    %--------------------------------------------------------------------------
            % Stat NAN 
            eval(strcat("resultsGlobal.x",nodeID,".",versionStrTrain,".",target,"= NaN;"))
            eval(strcat("results.x",nodeID,".",versionStrTrain,".",target,"= NaN;"))
            
            
            %% Estimating Statistics 

            outTrainEstimate= predictrsuper(Mdl,In_Train);
            outValidEstimate= predictrsuper(Mdl,In_Validation);

    %% Get Statistics 
    
            display(newline);
            combinedFigDaily   = getFileNameFigure(plotsFolder,nodeID,target,dailyString)
            folderCheck(combinedFigDaily) 

            combinedFig        = strrep(combinedFigDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain)) 
            folderCheck(combinedFig) 

            graphTitle2 = strcat(" ");

            drawScatterPlotMintsCombinedLimitsUTD(Out_Train,...
                                             outTrainEstimate,...
                                             Out_Validation,...
                                             outValidEstimate,...
                                             limitsLow{targetIndex},...
                                             limitsHigh{targetIndex},...
                                             nodeID,...
                                             targetLabel,...
                                             instruments{targetIndex},...
                                             "UTD Node",...
                                             units{targetIndex},...
                                             combinedFigDaily,...
                                             graphTitle1,...
                                             graphTitle2); 
    %         
          resultsCurrent=drawScatterPlotMintsCombinedLimitsUTD(Out_Train,...
                                             outTrainEstimate,...
                                             Out_Validation,...
                                             outValidEstimate,...
                                             limitsLow{targetIndex},...
                                             limitsHigh{targetIndex},...
                                             nodeID,...
                                             targetLabel,...
                                             instruments{targetIndex},...
                                             "UTD Node",...
                                             units{targetIndex},...
                                             combinedFig,...
                                             graphTitle1,...
                                             graphTitle2); 

            %% Saving Model Files 
            display(strcat("Saving Model Files for Node: ",string(nodeID), " & target :" ,targetLabel));
            modelsSaveNameDaily = getMintsNameGeneral(modelsMatsFolder,nodeID,...
                                        target,"daily_Mdl")
            folderCheck(modelsSaveNameDaily)

            modelsSaveName      = strrep(modelsSaveNameDaily,"daily_Mdl",strcat(versionStrMdl,"/",versionStrMdl))                                                
            folderCheck(modelsSaveName)
            
            
            save(modelsSaveName,'Mdl',...
                                'mintsInputs',...
                                'mintsInputLabels',...
                                'target',...
                                'targetLabel',...
                                'resultsCurrent'...
                                )    

            save(modelsSaveNameDaily,'Mdl',...
                                'mintsInputs',...
                                'mintsInputLabels',...
                                'target',...
                                'targetLabel',...
                                'resultsCurrent'...
                                 )                  

           display(newline);
           
           %% Saving Training Data 
           
           trainingSaveNameDaily = getMintsNameGeneral(trainingMatsFolder,nodeID,...
                                        target,dailyString)
           folderCheck(trainingSaveNameDaily)                        

           trainingSaveName      = strrep(trainingSaveNameDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain))                        
           folderCheck(trainingSaveName) 
                             
                             
    
            save(trainingSaveNameDaily,...
                     'Mdl',...
                     'In_Train',...
                     'Out_Train',...
                     'In_Validation',...
                     'Out_Validation',...
                     'trainingTT',...
                     'validatingTT',...
                     'trainingT',...
                     'validatingT',...
                     'mintsInputs',...
                     'mintsInputLabels',...
                     'target',...
                     'targetLabel',...
                     'nodeID',...
                     'mintsInputs',...
                     'mintsInputLabels',...
                     'binsPerColumn',...
                     'numberPerBin',...
                     'pValid', ...
                     'resultsCurrent'...
                 )                        

            save(trainingSaveName,...
                     'Mdl',...
                     'In_Train',...
                     'Out_Train',...
                     'In_Validation',...
                     'Out_Validation',...
                     'trainingTT',...
                     'validatingTT',...
                     'trainingT',...
                     'validatingT',...
                     'mintsInputs',...
                     'mintsInputLabels',...
                     'target',...
                     'targetLabel',...
                     'nodeID',...
                     'mintsInputs',...
                     'mintsInputLabels',...
                     'binsPerColumn',...
                     'numberPerBin',...
                     'pValid' ,...
                     'resultsCurrent'...
                 )


           

           %% Keeping CUrrent Statistics
           eval(strcat("resultsGlobal.x",nodeID,".",versionStrTrain,".",target,"=resultsCurrent;"))                                                        
           eval(strcat("results.x",nodeID,".",versionStrTrain,".",target,"=resultsCurrent;"))                                                        

           %% Saving the Structure File 
           clearvars -except...
                       graphTitle1...
                       versionStrTrain versionStrMdl dailyString dailyStringImp ...
                       plotsFolder limitsLow limitsHigh units instruments....
                       palasWithAirmar deployments ...  
                       nodeIDs nodeID utdWithTargets UTDMatsFolder...
                       versionStrTrain versionStrMdl ...
                       rawMatsFolder mergedMatsFolder ...
                       trainingMatsFolder modelsMatsFolder...
                       nodeIDs nodeIndex nodeID ...
                       mintsInputs mintsInputLabels ...
                       mintsTargets mintsTargetLabels targetIndex ...
                       binsPerColumn numberPerBin pValid  ...
                       mintsDefinitions results resultsFolder ...
                       resultsGlobal resultsCurrent

            close all
<<<<<<< HEAD
	catch e
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
        end   
	close all 
    end %Targets 
    
end   

poolobj = gcp('nocreate');
delete(poolobj);

function [In_Train,Out_Train,...
            In_Validation,Out_Validation,...
               trainingTT, validatingTT,...
                trainingT, validatingT ] ...
                            = representativeSampleSimpleTT(timeTableIn,inputVariables,target,pvalid)

    [trainInd,valInd,testInd] = dividerand(height(timeTableIn),1-pvalid,0,pvalid);

    tableIn  =  timetable2table(timeTableIn);            
    In       =  table2array(tableIn(:,inputVariables));
    Out      =  table2array(tableIn(:,target)); 

    In_Train       = In(trainInd,:);
    In_Validation  = In(testInd,:);

    Out_Train      = Out(trainInd);
    Out_Validation = Out(testInd);           

    trainingTT     = timeTableIn(trainInd ,[{inputVariables{:},target}]);
    validatingTT   = timeTableIn(testInd  ,[{inputVariables{:},target}]);

    trainingT          = timetable2table(trainingTT);
    validatingT        = timetable2table(validatingTT);

    trainingT.dateTime   = [];
    validatingT.dateTime = [];   
    
end


function currentFileName = getMintsFileNameTraining(folder,nodeIDs,nodeIndex,...
                                                            target,stringIn)
        nodeDataFolder      = folder+ "/"+nodeIDs(nodeIndex);
        currentFileName     = nodeDataFolder+"/"+stringIn + "_" +...
                                    nodeIDs(nodeIndex)+ "_" + ...
                                          target +"_"+...
                                              ".mat";
                                          
    if ~exist(fileparts(currentFileName), 'dir')
       mkdir(fileparts(currentFileName));
    end
end


function TT = gpsCropCoord(TT,latitude,longitude,latRange,longRange)
    
    TT= TT(TT.latitudeCoordinate>latitude-abs(latRange),:);
    TT= TT(TT.latitudeCoordinate<latitude+abs(latRange),:);
    TT= TT(TT.longitudeCoordinate>longitude-abs(longRange),:);
    TT= TT(TT.longitudeCoordinate<longitude+abs(longRange),:);
end




function [] = drawScatterPlotMintsCombinedLimits(...
                                    dataXTrain,...
                                    dataYTrain,...
                                    dataXValid,...
                                    dataYValid,...
                                    limitLow,...
                                    limitHigh,...
                                    nodeID,...
                                    estimator,...
                                    summary,...
                                    xInstrument,...
                                    yInstrument,...
                                    units,...
                                    saveNameFig)
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );

    %% Plot 1 : 1:1
    plot1=plot([limitLow: limitHigh],[limitLow: limitHigh]);
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);
    hold on 

    %% Plot 2 : Training Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXTrain,...
       dataYTrain,...
       ft);
   
    rmseTrain     = rms(dataXTrain-dataYTrain);
    r = corrcoef(dataXTrain,dataYTrain);
    rSquaredTrain=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult);
    set(plot2,'DisplayName','Training Fit','LineWidth',2,'Color',[0 0 .7]);  
    
    %% Plot 3 Traning Data 
    % Create plot
    plot3 = plot(...
         dataXTrain,...
         dataYTrain)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 1]);
    
    %% Plot 4 : Testing Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXValid,...
       dataYValid,...
       ft);
   
    rmseValid     = rms(dataXValid-dataYValid);
    r = corrcoef(dataXValid,dataYValid);
    rSquaredValid=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot4 = plot(fitresult)
    set(plot4,'DisplayName','Testing Fit','LineWidth',2,'Color',[1 0 0]);  
    
    %% Plot 5 Validating Data 
    % Create plot
    plot5 = plot(...
         dataXValid,...
         dataYValid);
    set(plot5,'DisplayName','Testing Data','Marker','o',...
        'LineStyle','none','Color',[1 0 0]);
    
     %% Plot 6 : Combined Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
    dataXAll = [dataXTrain;dataXValid];
    dataYAll = [dataYTrain;dataYValid];
    
    [fitresult, gof] = fit(...
       dataXAll,...
       dataYAll,...
       ft);
   
    rmse     = rms(dataXAll-dataYAll);
    r = corrcoef(dataXAll,dataYAll);
    rSquared=r(1,2)^2;

    plot6 = plot(fitresult)
    set(plot6,'DisplayName','Combined Fit','LineWidth',2,'Color',[0 0 0]);  
    
   
    %% Labels 
   
    yl=strcat(yInstrument,'~=',string(fitresult.p1),'*',xInstrument,'+',string(fitresult.p2)," (",units,")");
    ylabel(yl,'FontWeight','bold','FontSize',10);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title= strcat("R^2 = ", string(rSquared),...
                        ", RMSE = ",string(rmse),...
                         ", N = ",string(length(dataXAll)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Uncomment the following line to preserve the X-limits of the axes
    xlim([limitLow, limitHigh]);
    % Uncomment the following line to preserve the Y-limits of the axes
    ylim([limitLow, limitHigh]);
    box('on');
    axis('square');

    % Create legend
    legend1 = legend('show');
    set(legend1,'Location','northwest');
   
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
   
    Fig_name =strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end


function [] = drawScatterPlotMintsLimits(dataX,...
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
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );


    plot1=plot([limitLow: limitHigh],[limitLow: limitHigh])
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);

    hold on 

    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];

    

     
    [fitresult, gof] = fit(...
       dataX,...
       dataY,...
       ft);
   
    rmse     = rms(dataX-dataY);
    r = corrcoef(dataX,dataY);
    rSquared=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult)
    set(plot2,'DisplayName','Fit','LineWidth',2,'Color',[0 0 1]);

    
    
    
    % Create plot
    plot3 = plot(...
         dataX,...
         dataY)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 0]);
    
    
    
    
    yl=strcat(yInstrument,'~=',string(fitresult.p1),'*',xInstrument,'+',string(fitresult.p2)," (",units,")");
    ylabel(yl,'FontWeight','bold','FontSize',10);

    % Create xlabel
    xlabel(strcat(xInstrument,' (',units,')'),'FontWeight','bold','FontSize',12);

    % Create title
    Top_Title=strcat(estimator," - " +summary);

    Middle_Title = strcat("Node " +string(nodeID));

    Bottom_Title= strcat("R^2 = ", string(rSquared),...
                        ", RMSE = ",string(rmse),...
                         ", N = ",string(length(dataX)));

    title({Top_Title;Middle_Title;Bottom_Title},'FontWeight','bold');

    % Uncomment the following line to preserve the X-limits of the axes
    xlim([limitLow, limitHigh]);
    % Uncomment the following line to preserve the Y-limits of the axes
    ylim([limitLow, limitHigh]);
    box('on');
    axis('square');
    % Create legend
    legend1 = legend('show');
    set(legend1,'Location','northwest');


    
    Fig_name = strcat(saveNameFig,'.png');
    saveas(figure_1,char(Fig_name));
   
    Fig_name =strcat(saveNameFig,'.fig');
    saveas(figure_1,char(Fig_name));

end

function [] = drawPredictorImportaince(regressionTree,yLimit,...
                                        estimator,variableNames,nodeID,...
                                         figNamePre)
%GETPREDICTORIMPORTAINCE Summary of this function goes here
%   Detailed explanation goes here

imp = 100*(regressionTree.predictorImportance/sum(regressionTree.predictorImportance));

xLimit = max(imp)+5;

[sortedImp,isortedImp] = sort(imp,'descend');

   figure_1= figure('Tag','PREDICTOR_IMPORTAINCE_PLOT',...
        'NumberTitle','off',...
        'units','pixels',...   
        'OuterPosition',[0 0 2000 1300],...
        'Name','predictorImportance',...
        'Visible','off'...
    )



barh(imp(isortedImp));hold on ; grid on ;
set(gca,'ydir','reverse');
xlabel('Scaled Importance(%)','FontSize',20);
ylabel('Predictor Rank','FontSize',20);
   % Create title
    Top_Title=strcat(estimator," - Predictor Importaince Estimates")
    Middle_Title = strcat("Node " +string(nodeID))
    title({Top_Title;Middle_Title},'FontSize',21);

% title('Predictor Importaince Estimates')
ylim([.5 (yLimit+.5)]);
yticks([1:1:yLimit])
xlim([0 (xLimit)]);
xticks([0:1:xLimit])

% sortedPredictorLabels= regressionTree.PredictorNames(isortedImp);

sortedPredictorLabels= variableNames(isortedImp);

    for n = 1:yLimit
        text(...
            imp(isortedImp(n))+ 0.05,n,...
            sortedPredictorLabels(n),...
            'FontSize',15 , 'Interpreter', 'tex'...
            )
    end
%     
    Fig_name = strcat(figNamePre,'.png');
    saveas(figure_1,char(Fig_name));
    Fig_name = strcat(figNamePre,'.fig');
    saveas(figure_1,char(Fig_name));

    
end




function [] = drawScatterPlotMintsCombined(...
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
%GETMINTSDATAFILES Summary of this function goes here
%   Detailed explanation goes here
% As Is Graphs 

    % Initially draw y=t plot

    
    figure_1= figure('Tag','SCATTER_PLOT',...
        'NumberTitle','off',...
        'units','pixels','OuterPosition',[0 0 900 675],...
        'Name','Regression',...
        'Visible','off'...
    );

    %% Plot 1 : 1:1
    plot1=plot([1: limit],[1: limit]);
    set(plot1,'DisplayName','Y = T','LineStyle',':','Color',[0 0 0]);
    hold on 

    %% Plot 2 : Training Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXTrain,...
       dataYTrain,...
       ft);
   
    rmseTrain     = rms(dataXTrain-dataYTrain);
    r = corrcoef(dataXTrain,dataYTrain);
    rSquaredTrain=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot2 = plot(fitresult);
    set(plot2,'DisplayName','Training Fit','LineWidth',2,'Color',[0 0 .7]);  
    
    %% Plot 3 Traning Data 
    % Create plot
    plot3 = plot(...
         dataXTrain,...
         dataYTrain)
    set(plot3,'DisplayName','Data','Marker','o',...
        'LineStyle','none','Color',[0 0 1]);
    
    %% Plot 4 : Testing Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
   
    [fitresult, gof] = fit(...
       dataXValid,...
       dataYValid,...
       ft);
   
    rmseValid     = rms(dataXValid-dataYValid);
    r = corrcoef(dataXValid,dataYValid);
    rSquaredValid=r(1,2)^2;
%     rSquared = gof.rsquare;

    % %The_Fit_Equation_Training(runs,ts)=fitresult
    % p1_Training_and_Validation_f=fitresult.p1;
    % p2_Training_and_Validation_f=fitresult.p2;

    plot4 = plot(fitresult)
    set(plot4,'DisplayName','Testing Fit','LineWidth',2,'Color',[1 0 0]);  
    
    %% Plot 5 Validating Data 
    % Create plot
    plot5 = plot(...
         dataXValid,...
         dataYValid);
    set(plot5,'DisplayName','Testing Data','Marker','o',...
        'LineStyle','none','Color',[1 0 0]);
    
     %% Plot 6 : Combined Fit 
    % Fit model to data.
    % Set up fittype and options. 
    ft = fittype( 'poly1' ); 
    opts = fitoptions( 'Method', 'LinearLeastSquares' ); 
    opts.Lower = [0.6 -Inf];
    opts.Upper = [1.4 Inf];
    dataXAll = [dataXTrain;dataXValid];
    dataYAll = [dataYTrain;dataYValid];
    
    [fitresult, gof] = fit(...
       dataXAll,...
       dataYAll,...
       ft);
   
    rmse     = rms(dataXAll-dataYAll);
    r = corrcoef(dataXAll,dataYAll);
    rSquared=r(1,2)^2;

    plot6 = plot(fitresult)
    set(plot6,'DisplayName','Combined Fit','LineWidth',2,'Color',[0 0 0]);  
=======

            
        catch e
            close all
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
        end
        
    end %Targets
    display(newline);
>>>>>>> ec433a924b48fb31dde01c02bb96f0866550ead1
    
    resultsDailyFN   = getFileNameStat(resultsFolder,nodeID,dailyString)
    folderCheck(resultsDailyFN) 
    save(resultsDailyFN,'resultsCurrent') 
    
    resultsFN        = strrep(resultsDailyFN,dailyString,strcat(versionStrTrain,"/",versionStrTrain)) 
    folderCheck(resultsFN) 
    save(resultsFN,'resultsCurrent')
    
    display("NEXT NODE")
    
end % Nodes   

resultsDailyGlobalFN   = getFileNameStatGlobal(resultsFolder,dailyString)
folderCheck(resultsDailyGlobalFN) 
save(resultsDailyGlobalFN,'resultsGlobal')

resultsGlobalFN        = strrep(resultsDailyGlobalFN,dailyString,strcat(versionStrTrain,"/",versionStrTrain)) 
folderCheck(resultsDailyGlobalFN) 
save(resultsDailyFN,'resultsGlobal') 

%% Deleting the parrelel pool 

poolobj = gcp('nocreate');
delete(poolobj);

%% End of code 





