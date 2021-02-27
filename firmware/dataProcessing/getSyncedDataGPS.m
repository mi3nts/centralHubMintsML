function mintsData = getSyncedDataGPS(dataFolder,searchPath,nodeID,sensorID,timeSpan)
%GETSYNCEDDATA Summary of this function goes here
%   Detailed explanation goes here
 dataFiles =  dir(strcat(dataFolder,searchPath,nodeID,'_',sensorID,'*.csv'));
 mintsData = rmmissing(sensorReadFast(dataFiles,@readFast,timeSpan));
 
end
