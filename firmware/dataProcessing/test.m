clc
clear all
close all
load('lk.mat')


mintsDefinitions  = ReadYaml('../mintsDefinitions.yaml')

dataFolder         = mintsDefinitions.dataFolder;
nodeIDs            = mintsDefinitions.nodeIDs;
timeSpan           = seconds(mintsDefinitions.timeSpan);
binsPerColumn      = mintsDefinitions.binsPerColumn;
numberPerBin       = mintsDefinitions.numberPerBin ;
pValid             = mintsDefinitions.pValid;
airmarID           = mintsDefinitions.airmarID;
% instruments        = mintsDefinitions.instruments;
% units               = mintsDefinitions.units;
poolWorkers         = mintsDefinitions.poolWorkers;

% poolobj = gcp('nocreate');
% delete(poolobj);

% parpool(poolWorkers)

mintsTargets      = mintsDefinitions.mintsTargets;
% mintsTargetLabels = mintsDefinitions.mintsTargetLabels;


rawFolder           =  dataFolder + "/raw";
rawMatsFolder       =  dataFolder + "/rawMats";
centralMatsFolder   =  rawMatsFolder  + "/CentralNodes";
referenceFolder     =  dataFolder + "/reference";
referenceMatsFolder =  dataFolder + "/referenceMats";


palasFolder         =  referenceFolder       + "/palasStream";
palasMatsFolder     =  referenceMatsFolder   + "/palas";
licorMatsFolder     =  referenceMatsFolder   + "/licor";
noxMatsFolder       =  referenceMatsFolder   + "/nox";


driveSyncFolder     =  strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    =  dataFolder + "/mergedMats/centralNodes";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/centralNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/centralNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/centralNodes";
resultsFolder       =  dataFolder + "/results/centralNodes";
updateFolder        =  dataFolder + "/lastUpdate/centralNodes";

target      = mintsTargets{targetIndex}.target;
targetLabel = mintsTargets{targetIndex}.targetLabel;
targetStack = mintsTargets{targetIndex}.targetStack;
instrument  = mintsTargets{targetIndex}.instrument;
unit        = mintsTargets{targetIndex}.unit;
limits      = mintsTargets{targetIndex}.limits;

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
    "Training Estimates","Testing Estimates ",instrument,...
    nodeID,"Date Time (UTC)",...
    targetLabel +" ("+ unit+ ")",...
    targetLabel + " Calibration ("+strrep(versionStrTrain,"_"," ")+")",...
    combinedFigTT)

graphTitle2 = strcat(" ");

drawScatterPlotMintsCombinedLimitsUTD(Out_Train,...
    outTrainEstimate,...
    Out_Validation,...
    outValidEstimate,...
    limits{1},...
    limits{2},...
    nodeID,...
    targetLabel,...
    instrument,...
    "Central Node",...
    unit,...
    combinedFigDaily,...
    graphTitle1,...
    graphTitle2);
%
resultsCurrent=drawScatterPlotMintsCombinedLimitsUTD(Out_Train,...
    outTrainEstimate,...
    Out_Validation,...
    outValidEstimate,...
    limits{1},...
    limits{2},...
    nodeID,...
    targetLabel,...
    instrument,...
    "Central Node",...
    unit,...
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
if(representativeSample)
    
    resultsCurrent.binsPerColumn      = binsPerColumn;
    resultsCurrent.numberPerBin       = numberPerBin;
else
    resultsCurrent.binsPerColumn      = 0;
    resultsCurrent.numberPerBin       = 0;
end

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
    nodeIDs nodeID centralWithTargets CentralMatsFolder...
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