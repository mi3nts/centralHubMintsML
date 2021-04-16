
function [] = utdNodesCal_RS_ONN_01(nodeIndex)

%% Testing - TEST2
% Updates for  2021 - 02 - 19
% Kept the Original Cap For PM 1
% Have 10 graphs  for the training testing data
% Basically time series plots
% New CSV Global For Testing
% Added TEST0 for Label String and Label String Daily
% Meant for Optimised Neural Network
% Has a simplified Representative sampling

clc
clearvars -except nodeIndex
close all

versionStrPre = 'CN_Ronn_All_RS_ONN_1';
versionStrTrain = [versionStrPre '_' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
versionStrMdl   = versionStrTrain;
disp(versionStrMdl)
display(newline)
dailyString        =versionStrPre+"_Daily";
disp(dailyString)
display(newline)
graphTitle1     = "Optimzed NN All Inputs";
disp(graphTitle1)
display(newline)
globalCSVLabel = "WS_CN_Pre"


poolobj = gcp('nocreate');
delete(poolobj);


display(newline)
display("---------------------MINTS---------------------")
display(datestr(datetime('now')))
addpath("../../functions/")

addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml('../mintsDefinitions_CN.yaml')

dataFolder         = mintsDefinitions.dataFolder;
nodeIDs            = mintsDefinitions.nodeIDs;
timeSpan           = seconds(mintsDefinitions.timeSpan);
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
centralMatsFolder       =  rawMatsFolder  + "/centralNodes";
referenceFolder     =  dataFolder + "/reference";
referenceMatsFolder =  dataFolder + "/referenceMats";
palasFolder         =  referenceFolder       + "/palasStream";
palasMatsFolder     =  referenceMatsFolder   + "/palas";
driveSyncFolder     =  strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    =  dataFolder + "/mergedMats/centralNodes";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/centralNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/centralNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/centralNodes";
resultsFolder       =  dataFolder + "/results/centralNodes";
updateFolder       =  dataFolder + "/lastUpdate/centralNodes";

% for graphing
limitsLow  ={ 0,  0,  0,  0,  0  , 0  ,0,  20, 10, .98};
limitsHigh= {20, 40, 50, 60,  100, 500, 45,  75, 25,  .995};


display(newline)
folderCheck(dataFolder)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawMatsFolder)
display("CN DotMat Data Located @ :"+ centralMatsFolder)
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
nodeID      = nodeIDs{nodeIndex}.nodeIDXu4;

% Defining the Input Stack
eval(strcat("mintsInputs       = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"))
eval(strcat("mintsInputLabels = mintsDefinitions.inputLabelStack",string(nodeIDs{nodeIndex}.inputStack),";"))
eval(strcat("sensorStack      = mintsDefinitions.sensorStack",string(nodeIDs{nodeIndex}.inputStack),";"))

%eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"))
%eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"))

% if file Exists was recorded
fileName  = strcat(rawMatsFolder,'/centralNodes/centralNodesAnalysis_01_Mints_',nodeID,'.mat');;

if isfile(fileName)
    load(fileName);
else
    display(strcat("No Data Exists for Node: ",nodeID));
    return
end

% Correct This on Original Code 
centralMintsAll = mintsData_001e06318c91_Analysis;

%% Cropping GPS Coordinates
%centralMintsAll = GPSCropCoordinatesUTD(mintsDataAll,32.992179, -96.757777,0.0015,0.0015);

%% Gaining Only input Variables for training

centralMintsTraining  = rmmissing(centralMintsAll(:,mintsInputs));

% if enough data was recorded
if (height(centralMintsTraining)<100)
    display(strcat("Not enough Data points for Node: ",nodeID));
    return
end


centralWithTargets =  rmmissing(synchronize(centralMintsTraining,palasWithAirmar,'intersection'));

% Keeping the Original Cap
if (nodeID ~= "001e06318c28")
   centralWithTargets(centralWithTargets.pm1>500,:) = [];
end 

display("Save merged data for calibration: "+nodeID )
fileNameStr = strcat(mergedMatsFolder,"/centralWithTargets_", nodeID,".mat");
folderCheck(fileNameStr)
save(fileNameStr,...
    'centralWithTargets')

%% Creating Training Data for calibration
display(newline)
display("Creating Training Data Sets for Node: "+ nodeID )

for targetIndex = 1: length(mintsTargets)
    try
        
        target = mintsTargets{targetIndex};
        targetLabel = mintsTargetLabels{targetIndex};
        display(newline)
        display("Gainin Data set for Node "+ nodeID + " with target output " + target +" @ "+ datestr(datetime('now')) )
        [In_Train,Out_Train,...
            In_Validation,Out_Validation,...
            trainingTT, validatingTT,...
            trainingT, validatingT ] ...
                = representativeSampleTT(centralWithTargets,mintsInputs,target,pValid,binsPerColumn,numberPerBin);
        
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
        Mdl = fitrnn(In_Train,Out_Train);
        toc
        
        %--------------------------------------------------------------------------
        
        %% Estimating Statistics
        
        outTrainEstimate= predictrnn(Mdl,In_Train);
        outValidEstimate= predictrnn(Mdl,In_Validation);
        
        %% Get Statistics
        display(newline);
        combinedFigDaily   = getFileNameFigure(plotsFolder,nodeID,target,dailyString)
        folderCheck(combinedFigDaily)
        
        combinedFig        = strrep(combinedFigDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain));
        folderCheck(combinedFig)
        
        % Adding a Time Series Plot (02,21,2021)
        combinedFigTT        = strrep(combinedFig,".png",...
            "_TT.png")
        
        
        drawTimeSeries3x(trainingTT.dateTime,outTrainEstimate,...
            validatingTT.dateTime,outValidEstimate,...
            [trainingTT.dateTime;validatingTT.dateTime],...
            [Out_Train;Out_Validation],...
            "Training Estimates","Testing Estimates ",instruments{targetIndex},...
            nodeID,"Date Time (UTC)",...
            targetLabel +" ("+ units{targetIndex}+ ")",...
            targetLabel + " Calibration ("+strrep(versionStrTrain,"_"," ")+")",...
            combinedFigTT)
          
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
        resultsSaveName     = strrep(modelsSaveNameDaily,".mat",".csv")
        
        
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
        
        %% Additional parametors to keep
        
        resultsCurrent.pValid             = pValid;
        resultsCurrent.nodeID             = nodeID;
        resultsCurrent.target             = target;
        resultsCurrent.binsPerColumn      = binsPerColumn;
        resultsCurrent.numberPerBin       = numberPerBin;
        resultsCurrent.trainRows          = height(trainingTT);
        resultsCurrent.validRows          = height(validatingTT);
        
        
        resultsCurrent.versionStrMdl = versionStrMdl;
        
        resultsT =  struct2table(resultsCurrent)   ;
        
        if isfile(resultsSaveName)
            % File exists.
            writetable(resultsT,resultsSaveName,"WriteMode","append");
        else
            % File does not exist.
            writetable(resultsT,resultsSaveName);
        end
        
        % Global CSV  Changed to test CSV
        globalCSV   = modelsMatsFolder +"/"+globalCSVLabel + ...
            ".csv";
        
        if isfile(globalCSV)
            % File exists.
            writetable(resultsT,globalCSV,"WriteMode","append");
        else
            % File does not exist.
            writetable(resultsT,globalCSV);
        end
        
        
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
        
        
        %% Saving the Structure File
        clearvars -except...
            graphTitle1...
            versionStrTrain versionStrMdl dailyString dailyStringImp ...
            plotsFolder limitsLow limitsHigh units instruments....
            palasWithAirmar deployments ...
            nodeIDs nodeID centralWithTargets centralMatsFolder...
            versionStrTrain versionStrMdl ...
            rawMatsFolder mergedMatsFolder ...
            trainingMatsFolder modelsMatsFolder...
            nodeIDs nodeIndex nodeID ...
            mintsInputs mintsInputLabels ...
            mintsTargets mintsTargetLabels targetIndex ...
            binsPerColumn numberPerBin pValid  ...
            mintsDefinitions results resultsFolder ...
            resultsGlobal resultsCurrent globalCSVLabel
        
        close all
        
        
    catch e
        close all
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
    end
    
    
    
end %Targets
display(newline);





end
%% End of code

