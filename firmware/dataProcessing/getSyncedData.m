function mintsData = getSyncedData(dataFolder,searchPath,nodeID,sensorID,timeSpan)
%GETSYNCEDDATA Summary of this function goes here
%   Detailed explanation goes here
    dataFiles =  dir(strcat(dataFolder,searchPath,nodeID,'_',sensorID,'*.csv'));

     if(sensorID == "GPSGPGGA2")
        mintsData = rmmissing(sensorReadFast(dataFiles,@GPGGAReadFast,timeSpan));
     elseif (sensorID == "GPSGPRMC2")
        mintsData = rmmissing(sensorReadFast(dataFiles,@GPRMCReadFast,timeSpan));
     else
        mintsData = rmmissing(sensorReadFast(dataFiles,@readFast,timeSpan));
     end    
 end

