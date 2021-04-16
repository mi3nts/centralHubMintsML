clc
clear all
close all

%% The current code is meant for the calibration of CN01
% Minimalistic Effort for Calibration

display(newline)
display("---------------------MINTS---------------------")

addpath("YAMLMatlab_0.4.3")
addpath("../functions/")
mintsDefinitions  = ReadYaml('../mintsDefinitions_CN.yaml')

nodeIDs        = mintsDefinitions.nodeIDs;
timeSpan       = seconds(mintsDefinitions.timeSpan);

dataFolder     =  mintsDefinitions.dataFolder;
rawFolder      =  dataFolder + "/raw";
rawMatsFolder  =  dataFolder + "/rawMats";
matsFolder     =  dataFolder + "/mats";

display(newline)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawMatsFolder)

display(newline)

% syncFromCloudCN_from_LT(nodeIDs,dataFolder,true,false,false);
% 
% % Getting Raw Data
 for nodeIndex = 1:3
     
     nodeIDXu4      = nodeIDs{nodeIndex}.nodeIDXu4;
     mintsDataBME280     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'BME280',timeSpan);
     mintsDataOPCN3      =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'OPCN3',timeSpan);
     mintsDataGPSGPGGA2  =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'GPSGPGGA2',timeSpan);
     display("Data Files Recorded")
     
     %% Choosing Input Stack
     eval(strcat("inputStack = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"))
     eval(strcat("sensorStack = mintsDefinitions.sensorStack",string(nodeIDs{nodeIndex}.inputStack),";"))
     
     display("Saving Central Node Data");
     
     concatStr  =  "mintsDataPMAll   = synchronize(";
     for stackIndex = 1: length(sensorStack)
         if(height(eval(strcat("mintsData",sensorStack{stackIndex})))>2)
             concatStr = strcat(concatStr,"mintsData",sensorStack{stackIndex},",");
         end
     end
     concatStr  = strcat(concatStr,"'union');");
     display(concatStr)
     eval(concatStr)
     
     if(height(mintsDataPMAll) >0)
         display(strcat("Saving Central Hub Data for Node: ", nodeIDXu4));
         saveName  = strcat(matsFolder,'/centralHubs/centralHubPMAll_',...
             sprintf('%02d',nodeIndex ),'_Mints_',nodeIDXu4,'.mat');
         folderCheck(saveName);
         save(saveName,'mintsDataPMAll');
     else
         display(strcat("No Data for UTD Nodes  Node: ", nodeID ))
     end
     
     clearvars -except dataFolder matsFolder rawMatsFolder ...
         nodeIDs timeSpan ...
         nodeIndex mintsDefinitions
     
 end



%% Multiple Nodes for the analisis
% To get the maximum result of the current data set available

for nodeIndex = 1:3
    nodeIDXu4      = nodeIDs{nodeIndex}.nodeIDXu4;
    loadName  = strcat(matsFolder,'/centralHubs/centralHubPMAll_',...
        sprintf('%02d',nodeIndex ),'_Mints_',nodeIDXu4,'.mat');
    load(loadName)
    evalStr = strcat("mintsData_",nodeIDXu4,"=", "mintsDataPMAll;");
    eval(evalStr)
end

%% GPS Fixes CN1 : mintsData_001e06318c91
mintsData_001e06318c91.latitudeCoordinate(...
    mintsData_001e06318c91.dateTime<datetime(2020,12,5,'timezone','utc')&...
    mintsData_001e06318c91.dateTime>datetime(2019,5,24,'timezone','utc'),:)=32.992193750000006;

mintsData_001e06318c91.longitudeCoordinate(...
    mintsData_001e06318c91.dateTime<datetime(2020,12,5,'timezone','utc')&...
    mintsData_001e06318c91.dateTime>datetime(2019,5,24,'timezone','utc'),:)=-96.757776000000000;

mintsData_001e06318c91.latitudeCoordinate(...
    mintsData_001e06318c91.dateTime<datetime(2021,2,23,'timezone','utc')&...
    mintsData_001e06318c91.dateTime>datetime(2021,2,3,'timezone','utc'),:)=32.992193750000006;

mintsData_001e06318c91.longitudeCoordinate(...
    mintsData_001e06318c91.dateTime<datetime(2021,2,23,'timezone','utc')&...
    mintsData_001e06318c91.dateTime>datetime(2021,2,3,'timezone','utc'),:)=-96.757776000000000;

mintsData_001e06318c91.latitudeCoordinate(...
    mintsData_001e06318c91.dateTime<datetime(2021,4,15,'timezone','utc')&...
    mintsData_001e06318c91.dateTime>datetime(2021,3,4,'timezone','utc'),:)=32.992193750000006;


mintsData_001e06318c91.longitudeCoordinate(...
    mintsData_001e06318c91.dateTime<datetime(2021,4,15,'timezone','utc')&...
    mintsData_001e06318c91.dateTime>datetime(2021,3,4,'timezone','utc'),:)=-96.757776000000000;



%% Have to fix GPS Issues
mintsData_001e0637371e.latitudeCoordinate(...
    mintsData_001e0637371e.dateTime<datetime(2020,9,28,'timezone','utc')&...
    mintsData_001e0637371e.dateTime>datetime(2020,8,14,'timezone','utc'),:)=32.992193750000006;

mintsData_001e0637371e.longitudeCoordinate(...
    mintsData_001e0637371e.dateTime<datetime(2020,9,28,'timezone','utc')&...
    mintsData_001e0637371e.dateTime>datetime(2020,8,14,'timezone','utc'),:)=-96.757776000000000;

mintsData_001e0637371e.latitudeCoordinate(...
    mintsData_001e0637371e.dateTime<datetime(2020,10,26,13,20,00,'timezone','utc')&...
    mintsData_001e0637371e.dateTime>datetime(2020,10,03,00,30,00,'timezone','utc'),:)=32.992193750000006;

mintsData_001e0637371e.longitudeCoordinate(...
    mintsData_001e0637371e.dateTime<datetime(2020,10,26,13,20,00,'timezone','utc')&...
    mintsData_001e0637371e.dateTime>datetime(2020,10,03,00,30,00,'timezone','utc'),:)=-96.757776000000000;

mintsData_001e0637371e.latitudeCoordinate(...
    mintsData_001e0637371e.dateTime<datetime(2021,2,27,'timezone','utc')&...
    mintsData_001e0637371e.dateTime>datetime(2020,11,07,21,30,00,'timezone','utc'),:)=32.992193750000006;

mintsData_001e0637371e.longitudeCoordinate(...
    mintsData_001e0637371e.dateTime<datetime(2021,2,27,'timezone','utc')&...
    mintsData_001e0637371e.dateTime>datetime(2020,11,07,21,30,00,'timezone','utc'),:)=-96.757776000000000;

%% Clearing CN1 Variables

% WSTC Data
mintsData_001e06318c91_WSTC = gpsCropCoord(mintsData_001e06318c91,32.992179, -96.757777,0.0015,0.0015);
mintsData_001e0637371e_WSTC = gpsCropCoord(mintsData_001e0637371e,32.992179,-96.757777,0.0015,0.0015);


%% For CN 1 
% At this point I delete all data for CN1 before March 3rd 
mintsData_001e06318c91_WSTC(mintsData_001e06318c91_WSTC.dateTime<...
                    datetime(2021,03,03,'timezone','utc'),:) = [];
mintsData_001e06318c91_Kept = mintsData_001e0637371e_WSTC;

mintsData_001e06318c91_Kept(mintsData_001e06318c91_Kept.dateTime>...
                    datetime(2021,03,04,'timezone','utc'),:) = [];
                
                
mintsData_001e06318c91_Analysis = [mintsData_001e06318c91_Kept;mintsData_001e06318c91_WSTC];
         

for nodeIndex = 1:1
    nodeIDXu4      = nodeIDs{nodeIndex}.nodeIDXu4;
    saveName  = strcat(rawMatsFolder,'/centralNodes/centralNodesAnalysis_',...
        sprintf('%02d',nodeIndex ),'_Mints_',nodeIDXu4,'.mat');
    folderCheck(saveName)
    save(saveName,strcat("mintsData_",nodeIDXu4,"_Analysis"))
end
