
function [In_Train,Out_Train,...
    In_Validation,Out_Validation,...
    trainingTT, validatingTT,...
    trainingT, validatingT ] ...
    = representativeSampleSimpleNANTT(timeTableIn,inputVariables,target,pvalid,...
    nodeID, targetLabel,mergedMatsFolder)

timeTableIn     = rmmissing(timeTableIn(:,[{inputVariables{:},target}]));

try
    if(target=="CO2")
        timeTableIn(timeTableIn.CO2>1000,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end

try
    if(target=="NO2")
        timeTableIn(timeTableIn.NO2<0,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end
try
    if(target=="NO")
        timeTableIn(timeTableIn.NO<0,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end

try
    if(target=="NOX")
        timeTableIn(timeTableIn.NOX<0,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end


try
    if(target=="H2O")
        timeTableIn(timeTableIn.H2O>100,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end

try
    if(target=="BC")
        timeTableIn(timeTableIn.BC<0,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end


try
    if(target=="O3")
        timeTableIn(timeTableIn.O3<0,:) = [];
    end
catch ME
    disp('Error Message:')
    disp(ME.message)
end



display("Save merged data for calibration with reduced target data: "+nodeID )
fileNameStr = strcat(mergedMatsFolder,"/utdWithTargets_", nodeID,...
    "_",targetLabel,".mat");
folderCheck(fileNameStr)
save(fileNameStr,'timeTableIn')

[trainInd,valInd,testInd] = dividerand(height(timeTableIn),1-pvalid,0,pvalid);

tableIn  =  timetable2table(timeTableIn);
In       =  table2array(tableIn(:,inputVariables));
Out      =  table2array(tableIn(:,target));

In_Train       = In(trainInd,:);
In_Validation  = In(testInd,:);

Out_Train      = Out(trainInd);
Out_Validation = Out(testInd);

trainingTT     = timeTableIn(trainInd ,[{inputVariables{:},target}]);
validatingTT   = timeTableIn(testInd  ,[{inputVariables{:},target}]);

trainingT          = timetable2table(trainingTT);
validatingT        = timetable2table(validatingTT);

trainingT.dateTime   = [];
validatingT.dateTime = [];

end
