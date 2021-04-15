
clc
clear all
close all
load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2 PAPER_2021_03_07_17_02_57/CO2 PAPER_2021_03_07_17_02_57_001e06318c91_CO2.mat')

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
mintsDefinitions  = ReadYaml('mintsDefinitions.yaml')

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

combinedFig = "co2EN_3.png"

graphTitle1     = "Ensemble Learner";
graphTitle2 = strcat(" ");
%    


outTrainEstimate= predict(Mdl,In_Train);
outValidEstimate= predict(Mdl,In_Validation);
dataX1 = [trainingTT.dateTime;validatingTT.dateTime];
dataY1 = [trainingTT.CO2;validatingTT.CO2];

dataX2 = [trainingTT.dateTime;validatingTT.dateTime];
dataY2 = [outTrainEstimate;outValidEstimate];
dl1    = instrument ;
dl2    = "Ensemble Learner";

% nodeID
xLabel   = "Date Time"
yLabel   = "CO_{2} (ppm)"
titleIn  = "CO_{2} Ensemble Learner"
fileName = "test.png"


%     print(titleIn)
figure_1= figure('Tag','SCATTER_PLOT',...
    'NumberTitle','off',...
    'units','pixels','OuterPosition',[0 0 900 675],...
    'Name','TimeSeries',...
    'Visible','on'...
    );

% Create plot
plot1 = plot(...
    dataX1,...
    dataY1,'bx');

set(plot1,'DisplayName',dl1);

hold on

% Create plot
plot2 = plot(...
    dataX2,...
    dataY2,'ro');

set(plot2,'DisplayName',dl2);


legend(dl1,dl2)

ylabel(yLabel,'FontWeight','bold','FontSize',10);

% Create xlabel
xlabel(xLabel,'FontWeight','bold','FontSize',10);

% Create title
Top_Title=strcat(titleIn);

% Bottom_Title = strcat("Node " +string(nodeID));

title({" ";Top_Title},'FontWeight','bold');

grid on

xlim([datetime(2020,11,8,0,0,0,'timezone','utc') ...
                datetime(2020,12,6,9,30,0,'timezone','utc')]);


if ~exist(fileparts(fileName), 'dir')
    mkdir(fileparts(fileName));
end

saveas(figure_1,char(fileName));
