% % Added the importanint Variable Graph

close all
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Node_All_EL_CO2_2021_03_05_16_53_40/Central_Node_All_EL_CO2_2021_03_05_16_53_40_001e06318c91_CO2.mat')
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2 PAPER_2021_03_06_17_35_03/CO2 PAPER_2021_03_06_17_35_03_001e06318c91_CO2.mat')
load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2_reduced_2_EL_2021_04_01_10_57_36/CO2_reduced_2_EL_2021_04_01_10_57_36_001e06318c91_CO2.mat')

versionStrPre = 'Central_Node_All_EL_1';
versionStrTrain = [versionStrPre '_' datestr(now,'yyyy_mm_dd_HH_MM_SS')];
versionStrMdl   = versionStrTrain;
disp(versionStrMdl)
display(newline)
dailyString        =versionStrPre+"_Daily";
disp(dailyString)
display(newline)
graphTitle1     = "Ensemble Learner";
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
bcMatsFolder        =  referenceMatsFolder      + "/bc";
o3MatsFolder        =  referenceMatsFolder    + "/o3";

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


outTrainEstimate= predict(Mdl,In_Train);
outValidEstimate= predict(Mdl,In_Validation);

combinedFig = "co2EN_Reduced.png"

graphTitle1     = "Ensemble Learner";
graphTitle2 = strcat(" ");
%    
% resultsCurrent=drawScatterPlotMintsCombinedLimitsUTD(...
%     Out_Train,...
%     outTrainEstimate,...
%     Out_Validation,...
%     outValidEstimate,...
%     limits{1},...
%     limits{2},...
%     nodeID,...
%     targetLabel,...
%     instrument,...
%     "Central Node",...
%     unit,...
%     combinedFig,...
%     graphTitle1,...
%     graphTitle2);


% Plotting QQ Plots for Testing and Validation
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
    combinedFigTQQ)
% % 
% % % % Plotting Predictor Importaince Plots
% % % 
combinedFigTPI        = strrep(combinedFig,".png",...
    "_PI.png")
% 
drawPredictorImportaince(Mdl,...
    targetLabel,...
    nodeID,...
    graphTitle1,...
    mintsInputLabels,...
    combinedFigTPI )
