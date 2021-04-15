clc
clear all
close all
 
display(newline)
display("---------------------MINTS---------------------")

addpath("YAMLMatlab_0.4.3")
addpath("../functions/")
mintsDefinitions  = ReadYaml('../mintsDefinitions.yaml')

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

syncFromCloudCN(nodeIDs,dataFolder,true,false,false);


for nodeIndex = 1:1


    nodeIDXu4      = nodeIDs{nodeIndex}.nodeIDXu4;
    nodeIDPi       = nodeIDs{nodeIndex}.nodeIDPi;
    nodeIDJetson   = nodeIDs{nodeIndex}.nodeIDJetson;

    %% Syncing Process 
        mintsDataAPDS9002   =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'APDS9002',timeSpan);
        mintsDataAS7262     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'AS7262',timeSpan);
        mintsDataBME280     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'BME280',timeSpan);
        mintsDataGL001      =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'GL001',timeSpan);
        mintsDataGPSGPGGA2  =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'GPSGPGGA2',timeSpan);
        mintsDataGUV001     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'GUV001',timeSpan);
        mintsDataHM3301     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'HM3301',timeSpan);
        mintsDataLIBRAD     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'LIBRAD',timeSpan);
        mintsDataMGS001     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'MGS001',timeSpan);
        mintsDataOPCN3      =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'OPCN3',timeSpan);
        mintsDataSCD30      =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'SCD30',timeSpan);
        mintsDataSKYCAM_002 =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'SKYCAM_002',timeSpan);
        mintsDataTB108L     =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'TB108L',timeSpan);
        mintsDataTSL2591    =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'TSL2591',timeSpan);
        mintsDataVEML6075   =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'VEML6075',timeSpan);
        mintsDataTMG3993    =  getSyncedData(dataFolder,'/*/*/*/*/*/MINTS_',nodeIDXu4,'TMG3993',timeSpan);

        display("Data Files Recorded")  

    %% Choosing Input Stack

        eval(strcat("inputStackPM = mintsDefinitions.inputStackPM",string(nodeIDs{nodeIndex}.inputStack),";"))

        display("Saving UTD Nodes Data");

        concatStr  =  "mintsDataPMAll   = synchronize(";
        for stackIndex = 1: length(sensorStack) 
            if(height(eval(strcat("mintsData",sensorStack{stackIndex})))>2)
                concatStr = strcat(concatStr,"mintsData",sensorStack{stackIndex},",");
            end
        end
        concatStr  = strcat(concatStr,"'union');");   
        eval(concatStr)

        %% Applying GPS Patches
        if nodeIndex == 1
            mintsDataPMAll.latitudeCoordinate_mintsDataGPSGPGGA2(...
                mintsDataPMAll.dateTime<datetime(2020,12,5,'timezone','utc')&...
                mintsDataPMAll.dateTime>datetime(2019,5,24,'timezone','utc'),:)=32.992193750000006;
            mintsDataPMAll.latitudeCoordinate_mintsDataGPSGPGGA2(...
                mintsDataPMAll.dateTime<datetime(2020,12,5,'timezone','utc')&...
                mintsDataPMAll.dateTime>datetime(2019,5,24,'timezone','utc'),:)=-96.757776000000000;   
        end
        
        if(height(mintsDataPMAll) >0)
            display(strcat("Saving Central Hub Data for Node: ", nodeIDXu4));
            saveName  = strcat(matsFolder,'/centralHubs/centralHub_',sprintf('%02d',nodeIndex ),'_Mints_',nodeIDXu4,'.mat');
            folderCheck(saveName);
            save(saveName,'mintsDataPMAll');
        else
           display(strcat("No Data for UTD Nodes  Node: ", nodeID ))
        end    

        clearvars -except dataFolder matsFolder ...
                   nodeIDs timeSpan ...
                   nodeIndex mintsDefinitions
end
