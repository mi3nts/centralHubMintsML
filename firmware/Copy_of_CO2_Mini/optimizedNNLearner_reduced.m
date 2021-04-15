
function [] = optimizedNNLearner_reduced(nodeIndex)

%% Testing - TEST2
% Updates for  2021 - 02 - 19
% Kept the Original Cap For PM 1
% Have 10 graphs for the training testing data
% Basically time series plots
% New CSV Global For Testing
% Added TEST0 for Label String and Label String Daily
% Meant for Optimised Neural Network
% Has a simplified Representative sampling

clc
clearvars -except nodeIndex
close all

versionStrPre = 'Central_Ronn_All_ONN_1_CO2';
versionStrTrain = [versionStrPre '_' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
versionStrMdl   = versionStrTrain;
disp(versionStrMdl)
display(newline)
dailyString        =versionStrPre+"_Daily";
disp(dailyString)
display(newline)
graphTitle1     = "Optimized NN";
disp(graphTitle1)
display(newline)
globalCSVLabel = "resultsNowXT_CN_ONN_1"

representativeSample = false;


display(newline)
display("---------------------MINTS---------------------")
display(datestr(datetime('now')))
addpath("../../functions/")
addpath("../functions/")
addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml('../mintsDefinitions.yaml')

dataFolder         = mintsDefinitions.dataFolder;
nodeIDs            = mintsDefinitions.nodeIDs;
timeSpan           = seconds(mintsDefinitions.timeSpan);
% binsPerColumn      = mintsDefinitions.binsPerColumn;
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
bcMatsFolder        =  referenceMatsFolder   + "/bc";
o3MatsFolder        =  referenceMatsFolder   + "/o3";


driveSyncFolder     =  strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    =  dataFolder + "/mergedMats/centralNodes";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/centralNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/centralNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/centralNodes";
resultsFolder       =  dataFolder + "/results/centralNodes";
updateFolder        =  dataFolder + "/lastUpdate/centralNodes";

%% for graphing
limitsLow  ={ 0,  0,  0,  0,  0  , 0  ,0,  20, 10, .98};
limitsHigh= {20, 40, 50, 60,  100, 500, 45,  75, 25,  .995};


display(newline)
folderCheck(dataFolder)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawMatsFolder)
display("Central Nodes DotMat Data Located @ :"+ centralMatsFolder)
display("Reference Data Located @: "+ referenceFolder )
display("Reference DotMat Data Located @ :"+ referenceMatsFolder)
display("Palas Raw Data Located @ :"+ palasFolder)
display("Palas DotMat Data Located @ :"+ palasMatsFolder)
display("Car GPS Files Located @ :"+ GPSFolder)


for targetIndex = 1: 1
    %     try
    target      = mintsTargets{targetIndex}.target;
    targetLabel = mintsTargets{targetIndex}.targetLabel;
    targetStack = mintsTargets{targetIndex}.targetStack;
    instrument  = mintsTargets{targetIndex}.instrument;
    unit        = mintsTargets{targetIndex}.unit;
    limits      = mintsTargets{targetIndex}.limits;
    load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2_reduced_2_EL_2021_04_01_10_57_36/CO2_reduced_2_EL_2021_04_01_10_57_36_001e06318c91_CO2.mat')
    versionStrPre = 'CO2_reduced_2_ONN';
    versionStrTrain = [versionStrPre '_' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
    versionStrMdl   = versionStrTrain;

    display("Running Regression")
    
    tic
    Mdl = fitrnn(In_Train,Out_Train);
    toc
    
    %--------------------------------------------------------------------------
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
     
     % Plotting QQ Plots for Testing and Validation 
     combinedFigTQQ        = strrep(combinedFig,".png",...
      "_QQ.png")
      drawQQPlotMints(Out_Validation,...
                      outValidEstimate,...
                      limits{1},...
                      limits{2},...
                      nodeID,...
                      targetLabel,...
                      "QQ Plot",...
                      instrument,...
                      "Central Node",...
                      unit,...
                      combinedFigTQQ   )
    
    %% Saving Model Files
%     display(strcat("Saving Model Files for Node: ",string(nodeID), " & target :" ,targetLabel));
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
        binsPerColumn = 0; 
        numberPerBin = 0;
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
%     
    trainingSaveNameDaily = getMintsNameGeneral(trainingMatsFolder,nodeID,...
        target,dailyString)
%     folderCheck(trainingSaveNameDaily)
    
    trainingSaveName      = strrep(trainingSaveNameDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain))
    folderCheck(trainingSaveName)
    
    
%     save(trainingSaveNameDaily,...
%         'Mdl',...
%         'In_Train',...
%         'Out_Train',...
%         'In_Validation',...
%         'Out_Validation',...
%         'trainingTT',...
%         'validatingTT',...
%         'trainingT',...
%         'validatingT',...
%         'mintsInputs',...
%         'mintsInputLabels',...
%         'target',...
%         'targetLabel',...
%         'nodeID',...
%         'mintsInputs',...
%         'mintsInputLabels',...
%         'binsPerColumn',...
%         'numberPerBin',...
%         'pValid', ...
%         'resultsCurrent'...
%         )
    
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
        plotsFolder  ...
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
        resultsGlobal resultsCurrent globalCSVLabel...
        nodeStack targetStack representativeSample ...
        timeSpan
    close all
    
    
    %     catch e
    %         close all
    %         fprintf(1,'The identifier was:\n%s',e.identifier);
    %         fprintf(1,'There was an error! The message was:\n%s',e.message);
    %     end
    %
    
    
end %Targets
display(newline);

end
%% End of code
