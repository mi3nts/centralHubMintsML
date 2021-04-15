
% % Added the importanint Variable Graph
% clc
% clearvars -except nodeIndex
% close all

close all

% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_05_13_26_22/Central_Ronn_All_ONN_3_2021_03_05_13_26_22_001e06318c91_CO2.mat')
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_06_12_26_15/Central_Ronn_All_ONN_3_2021_03_06_12_26_15_001e06318c91_CO2.mat')
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2_reduced_2_ONN_2021_04_01_11_32_07/CO2_reduced_2_ONN_2021_04_01_11_32_07_001e06318c91_CO2.mat')


load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2_mini_ONN_2021_04_05_17_14_37/CO2_mini_ONN_2021_04_05_17_14_37_001e06318c91_CO2.mat')
  

versionStrPre = 'Central_Node_All_EL_1';
versionStrTrain = [versionStrPre '_' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
versionStrMdl   = versionStrTrain;
disp(versionStrMdl)
display(newline)
dailyString        =versionStrPre+"_Daily";
disp(dailyString)
display(newline)
graphTitle1     = "Optimized Neural Network";
disp(graphTitle1)
display(newline)
globalCSVLabel = "resultsNowXT_CN_EL_1"

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

mintsTargets      = mintsDefinitions.mintsTargets;

rawFolder           =  dataFolder + "/raw";
rawMatsFolder       =  dataFolder + "/rawMats";
centralMatsFolder   =  rawMatsFolder  + "/CentralNodes";
referenceFolder     =  dataFolder + "/reference";
referenceMatsFolder =  dataFolder + "/referenceMats";

palasFolder         =  referenceFolder       + "/palasStream";
palasMatsFolder     =  referenceMatsFolder   + "/palas";
licorMatsFolder     =  referenceMatsFolder   + "/licor";
noxMatsFolder       =  referenceMatsFolder   + "/nox";
bcMatsFolder     =  referenceMatsFolder      + "/bc";
o3MatsFolder       =  referenceMatsFolder    + "/o3";

driveSyncFolder     =  strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    =  dataFolder + "/mergedMats/centralNodes";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/centralNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/centralNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/centralNodes";
resultsFolder       =  dataFolder + "/results/centralNodes";
updateFolder        =  dataFolder + "/lastUpdate/centralNodes";

targetIndex  = 1;
target      = mintsTargets{targetIndex}.target;
targetLabel = mintsTargets{targetIndex}.targetLabel;
targetStack = mintsTargets{targetIndex}.targetStack;
instrument  = mintsTargets{targetIndex}.instrument;
unit        = mintsTargets{targetIndex}.unit;
limits      = mintsTargets{targetIndex}.limits;


outTrainEstimate= predictrnn(Mdl,In_Train);
outValidEstimate= predictrnn(Mdl,In_Validation);

combinedFig = "co2NN_Mini_2.png"

graphTitle1     = "Optimized Neural Network";
graphTitle2 = strcat(" ");
% % %     
resultsCurrent=drawScatterPlotMini(...
    Out_Train,...
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



% % % Plotting QQ Plots for Testing and Validation
combinedFigTQQ        = strrep(combinedFig,".png",...
    "_QQ.png")


drawQQPlotMints(Out_Validation,...
    outValidEstimate,...
    limits{1},...
    limits{2},...
    nodeID,...
    targetLabel,...
    graphTitle1,...
    instrument,...
    "Central Node",...
    unit,...
    combinedFigTQQ   )

% % Plotting Predictor Importaince Plots
% 
% combinedFigTPI        = strrep(combinedFig,".png",...
%     "_PI.png")
% 
% % drawPredictorImportaince(Mdl,...
% %     targetLabel,...
% %     nodeID,...
% %     "Predictor Importaince",...
% %     mintsInputLabels,...
% %     combinedFigTPI )
