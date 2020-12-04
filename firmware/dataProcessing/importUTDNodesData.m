function [] = importUTDNodesData(yamlFile)
%IMPORTUTDNODESDATA Summary of this function goes here
%   Detailed explanation goes here
display(newline)
display("---------------------MINTS---------------------")

addpath("../../functions/")

addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml(yamlFile)

nodeIDs     = mintsDefinitions.nodeIDs;
timeSpan    = seconds(mintsDefinitions.timeSpan);


dataFolder      = mintsDefinitions.dataFolder;
rawFolder       =  dataFolder + "/raw";
rawMatsFolder   =  dataFolder + "/rawMats";

display(newline)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawMatsFolder)

display(newline)

%% Syncing Process 
syncFromCloudUTDNodes(nodeIDs,dataFolder)

% going through the UTD Nodes  IDs
for nodeIndex = 1:length(nodeIDs)

    nodeID           = nodeIDs{nodeIndex}.nodeID;
    
    AS7262Files      =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_AS7262','*.csv'))
    BME280Files      =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_BME280','*.csv'))
    GPSGPGGA2Files   =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_GPSGPGGA2','*.csv'))
    GPSGPRMC2Files   =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_GPSGPRMC2','*.csv'))
    MGS001Files      =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_MGS001','*.csv'))
    OPCN2Files       =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_OPCN2','*.csv'))
    OPCN3Files       =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_OPCN3','*.csv'))
    PPD42NSDuoFiles  =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_PPD42NSDuo','*.csv'))
    SCD30Files       =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_SCD30','*.csv'))
    SKYCAM_002Files  =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_SKYCAM_002','*.csv'))
    TSL2591Files     =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_TSL2591','*.csv'))
    VEML6075Files    =  dir(strcat(rawFolder,'/*/*/*/*/MINTS_',nodeID,'_VEML6075','*.csv'))
    
    mintsDataAS7262       = sensorRead(AS7262Files,@AS7262Read,timeSpan);
    mintsDataBME280       = sensorRead(BME280Files,@BME280Read,timeSpan);
    mintsDataGPSGPGGA2    = sensorRead(GPSGPGGA2Files,@GPGGAUtdRead,timeSpan);
    mintsDataGPSGPRMC2    = sensorRead(GPSGPRMC2Files,@GPGRMCUtdRead,timeSpan);
    mintsDataMGS001       = sensorRead(MGS001Files,@MGS001Read,timeSpan);
    mintsDataOPCN2        = sensorRead(OPCN2Files,@OPCN2Read,timeSpan);
    mintsDataOPCN3        = sensorRead(OPCN3Files,@OPCN3Read,timeSpan);
    mintsDataPPD42NSDuo  = sensorRead(PPD42NSDuoFiles,@PPD42NSDuoRead,timeSpan);
    mintsDataSCD30        = sensorRead(SCD30Files,@SCD30Read,timeSpan);
    mintsDataSKYCAM_002   = sensorRead(SKYCAM_002Files,@SKYCAM_002Read,timeSpan);
    mintsDataTSL2591      = sensorRead(TSL2591Files,@TSL2591Read,timeSpan);
    mintsDataVEML6075     = sensorRead(VEML6075Files,@VEML6075Read,timeSpan);
  
    
    %% Choosing Input Stack
    
    eval(strcat("inputStack = mintsDefinitions.inputStack",string(nodeIDs{nodeIndex}.inputStack),";"))
    
    display("Saving UTD Nodes Data");
    concatStr  =  "mintsDataAll   = synchronize(";
    for stackIndex = 1: length(inputStack)
         concatStr = strcat(concatStr,"mintsData",inputStack{stackIndex},",");
    end
    concatStr  = strcat(concatStr,"'union');");   
    eval(concatStr)
         
    if(height(mintsDataAll) >0)
        display(strcat("Saving UTD Nodes Data for Node: ", nodeID));
        saveName  = strcat(rawMatsFolder,'/UTDNodes/UTDNodesMints_',nodeID,'.mat');
        folderCheck(saveName);
        save(saveName,'mintsDataAll');
    else
       display(strcat("No Data for UTD Nodes  Node: ", nodeID ))
    end    
        
    clearvars -except dataFolder rawFolder rawMatsFolder ...
                      nodeIDs timeSpan rawFolder ...
                      nodeIndex mintsDefinitions
        
       
    end    

end

