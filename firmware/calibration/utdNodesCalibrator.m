
function [] = utdNodesCalibrator(nodeIndex)

clc
clearvars -except nodeIndex 
close all 

poolobj = gcp('nocreate');
delete(poolobj);


display(newline)
display("---------------------MINTS---------------------")

addpath("../../functions/")

addpath("YAMLMatlab_0.4.3")
mintsDefinitions  = ReadYaml('../mintsDefinitions.yaml')

dataFolder         = mintsDefinitions.dataFolder;
nodeIDs     = mintsDefinitions.nodeIDs;
timeSpan    = seconds(mintsDefinitions.timeSpan);
binsPerColumn      = mintsDefinitions.binsPerColumn;
numberPerBin       = mintsDefinitions.numberPerBin ;
pValid             = mintsDefinitions.pValid;
airmarID           = mintsDefinitions.airmarID;
instruments        = mintsDefinitions.instruments;
units               = mintsDefinitions.units;
poolWorkers         = mintsDefinitions.poolWorkers;

parpool(poolWorkers)

mintsTargets      = mintsDefinitions.mintsTargets;
mintsTargetLabels = mintsDefinitions.mintsTargetLabels;


rawFolder           =  dataFolder + "/raw";
rawMatsFolder       =  dataFolder + "/rawMats";
UTDMatsFolder       =  rawMatsFolder  + "/UTDNodes";
referenceFolder     =  dataFolder + "/reference";
referenceMatsFolder =  dataFolder + "/referenceMats";
palasFolder         =  referenceFolder       + "/palasStream";
palasMatsFolder     =  referenceMatsFolder   + "/palas";
driveSyncFolder     =  strcat(dataFolder,"/exactBackUps/palasStream/");
mergedMatsFolder    =  dataFolder + "/mergedMats/UTD";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/UTDNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/UTDNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/UTDNodes";
resultsFolder       =  dataFolder + "/results/UTDNodes";

% for graphing 
limitsLow  ={ 0,  0,  0,  0,  0  , 0  ,0,  20, 10, .98};
limitsHigh= {20, 40, 50, 60,  100, 500, 45,  75, 25,  .995};

versionStrTrain = ['UTD_Rsl_All_' datestr(today,'yyyy_mm_dd')];
versionStrMdl   = versionStrTrain;
disp(versionStrMdl)
display(newline)
dailyString        = "UTD_Rsl_All_Daily";
dailyStringImp     = "UTD_Rsl_All_Daily_Imp";
disp(dailyString)
display(newline)          
graphTitle1     = "Super Learner All Inputs";
disp(graphTitle1)
display(newline)           
                        
display(newline)
folderCheck(dataFolder)
display("Data Folder Located @:"+ dataFolder)
display("Raw Data Located @: "+ dataFolder)
display("Raw DotMat Data Located @ :"+ rawMatsFolder)
display("UTD Nodes DotMat Data Located @ :"+ UTDMatsFolder)
display("Reference Data Located @: "+ referenceFolder )
display("Reference DotMat Data Located @ :"+ referenceMatsFolder)
display("Palas Raw Data Located @ :"+ palasFolder)
display("Palas DotMat Data Located @ :"+ palasMatsFolder)
display("Car GPS Files Located @ :"+ GPSFolder)

%% Loading Files 
display("Loading Palas Files")
load(strcat(palasMatsFolder,"/palas.mat"));
palasData = palas;

display("Loading GPS Files");
load(strcat(GPSFolder,"/carMintsGPSCoords.mat"));
carGpsData = mintsData;

display("Loading Airmar Files");
load(strcat(airmarFolder,"/airMar_",airmarID,".mat"));
airmarData = mintsDataAll;
% The airmar was always at the cage, but just incase I am only taking
% inputs that has GPS. 

airmarData = removevars( airmarData, {...
                        'courseOGTrue'                           ,...
                        'courseOGMagnetic'                       ,...
                        'speedOverGroundKnots'                   ,...
                        'speedOverGroundKMPH'                    ,...
                        'heading'                                ,...
                        'barrometricPressureMercury'             ,...
                        'barrometricPressureBars_mintsDataWimda' ,...
                        'windDirectionTrue'                      ,...
                        'windDirectionMagnetic'                  ,...
                        'windSpeedKnots'                         ,...
                        'windSpeedMetersPerSecond'               ,...
                        'windAngle'                              ,...
                        'windSpeed'                              ...
                        });


airmarDataWSTC     = gpsCropCoord(airmarData,32.992179, -96.757777,0.0015,0.0015);

airmarDataWSTC     = removevars( airmarDataWSTC, {...    
                                'latitudeCoordinate'  ,...
                                'longitudeCoordinate'  });      
                            
airmarDataWSTC.Properties.VariableNames =    {'temperatureAirmar'    ,...                    
                                            'humidityAirmar'            ,...          
                                            'dewPointAirmar'                ,...              
                                            'pressureAirmar'};
                                        
%% Syncing Data 
display("Aligning GPS data with Palas Data")
palasWithGPS  =  rmmissing(synchronize(palasData,carGpsData,'intersection'));

display("WSTC Palas Data")
palasWSTC = gpsCropCoord(palasWithGPS,32.992179, -96.757777,0.0015,0.0015);
palasWSTC = removevars( palasWSTC, {...    
                                'latitudeCoordinate'  ,...
                                'longitudeCoordinate'  });

display("Palas With Airmar")
palasWithAirmar  =  rmmissing(synchronize(palasWSTC,airmarDataWSTC,'intersection'));

%% Loading UTD Data and merging them with Palas Data 
display("Analysis")

% Check if availble for UTD Nodes 


% 

results=  struct;

% for nodeIndex = 1:length(nodeIDs)
    nodeResults=  struct;
    
    nodeID = nodeIDs{nodeIndex}.nodeID;
    
    % Defining the Input Stack
    eval(strcat("mintsInputs      = mintsDefinitions.mintsInputsStack",string(nodeIDs{nodeIndex}.inputStack),";"))
    eval(strcat("mintsInputLabels = mintsDefinitions.mintsInputLabelsStack",string(nodeIDs{nodeIndex}.inputStack),";"))
    
    
    % if file Exists was recorded 
    fileName  = strcat(rawMatsFolder,'/UTDNodes/UTDNodesMints_',nodeID,'.mat');;

    if isfile(fileName)
        load(fileName);
    else
       display(strcat("No Data Exists for Node: ",nodeID)); 
       return  
    end
    %% Removing Extreme Outliers 
    mintsDataAll(mintsDataAll.pm1>500)  = [] ; 


    %% Cropping GPS Coordinates 
    utdMintsAll = GPSCropCoordinatesUTD(mintsDataAll,32.992179, -96.757777,0.0015,0.0015);
    
    %% Gaining Only input Variables for training 
    
    utdMintsTraining  = rmmissing(utdMintsAll(:,mintsInputs));
    
    % if enough data was recorded 
    if (height(utdMintsTraining)<100)
       display(strcat("Not enough Data points for Node: ",nodeID));
       return  
    end    
    
    
    utdWithTargets =  rmmissing(synchronize(utdMintsTraining,palasWithAirmar,'intersection'));
                                                                  
    display("Save merged data for calibration: "+nodeID )
    fileNameStr = strcat(mergedMatsFolder,"/utdWithTargets_", nodeID,".mat");
    folderCheck(fileNameStr)
    save(fileNameStr,...
            'utdWithTargets')                 
    
    %% Creating Training Data for calibration
    display(newline)
    display("Creating Training Data Sets for Node: "+ nodeID )  
    
    for targetIndex = 1: length(mintsTargets)   
        try
        
            target = mintsTargets{targetIndex};
            targetLabel = mintsTargetLabels{targetIndex};

            display(newline)
            display("Gainin Data set for Node "+ nodeID + " with target output " + target)  
            [In_Train,Out_Train,...
                In_Validation,Out_Validation,...
                    trainingTT, validatingTT,...
                        trainingT, validatingT ] ...
                                        = representativeSampleTT(utdWithTargets,mintsInputs,target,pValid,binsPerColumn,numberPerBin);    

            if(target == "dCn_palas" )
                trainingT(trainingT.dCn_palas == Inf,:) = [];
                In_Train(trainingT.dCn_palas == Inf,:) = [];
                Out_Train(trainingT.dCn_palas == Inf,:) = [];
                In_Validation(validatingT.dCn_palas == Inf,:) = [];
                Out_Validation(validatingT.dCn_palas == Inf,:) = [];
                trainingTT(trainingT.dCn_palas == Inf,:) = [];
                validatingTT(validatingT.dCn_palas == Inf,:) = [];
                trainingT(trainingT.dCn_palas == Inf,:) = [];
                validatingT(validatingT.dCn_palas == Inf,:) = [];
            end                        

            display("Running Regression")

            tic     

            OutDescription='UTD Calibration';
            Mdl = fitrsuper(In_Train,Out_Train,In_Validation,Out_Validation,OutDescription);
            toc

    %--------------------------------------------------------------------------
            % Stat NAN 
            eval(strcat("resultsGlobal.x",nodeID,".",versionStrTrain,".",target,"= NaN;"))
            eval(strcat("results.x",nodeID,".",versionStrTrain,".",target,"= NaN;"))
            
            
            %% Estimating Statistics 

            outTrainEstimate= predictrsuper(Mdl,In_Train);
            outValidEstimate= predictrsuper(Mdl,In_Validation);

    %% Get Statistics 
    
            display(newline);
            combinedFigDaily   = getFileNameFigure(plotsFolder,nodeID,target,dailyString)
            folderCheck(combinedFigDaily) 

            combinedFig        = strrep(combinedFigDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain)) 
            folderCheck(combinedFig) 

            graphTitle2 = strcat(" ");

            drawScatterPlotMintsCombinedLimitsUTD(Out_Train,...
                                             outTrainEstimate,...
                                             Out_Validation,...
                                             outValidEstimate,...
                                             limitsLow{targetIndex},...
                                             limitsHigh{targetIndex},...
                                             nodeID,...
                                             targetLabel,...
                                             instruments{targetIndex},...
                                             "UTD Node",...
                                             units{targetIndex},...
                                             combinedFigDaily,...
                                             graphTitle1,...
                                             graphTitle2); 
    %         
          resultsCurrent=drawScatterPlotMintsCombinedLimitsUTD(Out_Train,...
                                             outTrainEstimate,...
                                             Out_Validation,...
                                             outValidEstimate,...
                                             limitsLow{targetIndex},...
                                             limitsHigh{targetIndex},...
                                             nodeID,...
                                             targetLabel,...
                                             instruments{targetIndex},...
                                             "UTD Node",...
                                             units{targetIndex},...
                                             combinedFig,...
                                             graphTitle1,...
                                             graphTitle2); 

            %% Saving Model Files 
            display(strcat("Saving Model Files for Node: ",string(nodeID), " & target :" ,targetLabel));
            modelsSaveNameDaily = getMintsNameGeneral(modelsMatsFolder,nodeID,...
                                        target,"daily_Mdl")
            folderCheck(modelsSaveNameDaily)

            modelsSaveName      = strrep(modelsSaveNameDaily,"daily_Mdl",strcat(versionStrMdl,"/",versionStrMdl))                                                
            folderCheck(modelsSaveName)
            
            
            save(modelsSaveName,'Mdl',...
                                'mintsInputs',...
                                'mintsInputLabels',...
                                'target',...
                                'targetLabel',...
                                'resultsCurrent'...
                                )    

            save(modelsSaveNameDaily,'Mdl',...
                                'mintsInputs',...
                                'mintsInputLabels',...
                                'target',...
                                'targetLabel',...
                                'resultsCurrent'...
                                 )                  

           display(newline);
           
           %% Saving Training Data 
           
           trainingSaveNameDaily = getMintsNameGeneral(trainingMatsFolder,nodeID,...
                                        target,dailyString)
           folderCheck(trainingSaveNameDaily)                        

           trainingSaveName      = strrep(trainingSaveNameDaily,dailyString,strcat(versionStrTrain,"/",versionStrTrain))                        
           folderCheck(trainingSaveName) 
                             
                             
    
            save(trainingSaveNameDaily,...
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
                     'pValid', ...
                     'resultsCurrent'...
                 )                        

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


           

           %% Keeping CUrrent Statistics
           eval(strcat("resultsGlobal.x",nodeID,".",versionStrTrain,".",target,"=resultsCurrent;"))                                                        
           eval(strcat("results.x",nodeID,".",versionStrTrain,".",target,"=resultsCurrent;"))                                                        

           %% Saving the Structure File 
           clearvars -except...
                       graphTitle1...
                       versionStrTrain versionStrMdl dailyString dailyStringImp ...
                       plotsFolder limitsLow limitsHigh units instruments....
                       palasWithAirmar deployments ...  
                       nodeIDs nodeID utdWithTargets UTDMatsFolder...
                       versionStrTrain versionStrMdl ...
                       rawMatsFolder mergedMatsFolder ...
                       trainingMatsFolder modelsMatsFolder...
                       nodeIDs nodeIndex nodeID ...
                       mintsInputs mintsInputLabels ...
                       mintsTargets mintsTargetLabels targetIndex ...
                       binsPerColumn numberPerBin pValid  ...
                       mintsDefinitions results resultsFolder ...
                       resultsGlobal resultsCurrent

            close all

            
        catch e
            close all
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
        end
        
    end %Targets
    display(newline);
    
    resultsDailyFN   = getFileNameStat(resultsFolder,nodeID,dailyString)
    folderCheck(resultsDailyFN) 
    save(resultsDailyFN,'resultsCurrent') 
    
    resultsFN        = strrep(resultsDailyFN,dailyString,strcat(versionStrTrain,"/",versionStrTrain)) 
    folderCheck(resultsFN) 
    save(resultsFN,'resultsCurrent')
    
    display("Node Done")
    
% end % Nodes   

% resultsDailyGlobalFN   = getFileNameStatGlobal(resultsFolder,dailyString)
% folderCheck(resultsDailyGlobalFN) 
% save(resultsDailyGlobalFN,'resultsGlobal')
% 
% resultsGlobalFN        = strrep(resultsDailyGlobalFN,dailyString,strcat(versionStrTrain,"/",versionStrTrain)) 
% folderCheck(resultsDailyGlobalFN) 
% save(resultsDailyFN,'resultsGlobal') 

%% Deleting the parrelel pool 

poolobj = gcp('nocreate');
delete(poolobj);

%% End of code 





