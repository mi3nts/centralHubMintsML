
clc
clear all 
close all 
 %% Deleting the parrelel pool 

poolobj = gcp('nocreate');
delete(poolobj); 

% General Definitions
addpath("../../functions/")
addpath("YAMLMatlab_0.4.3")

mintsDefinitions  = ReadYaml('../mintsDefinitions.yaml') 
poolWorkers         = mintsDefinitions.poolWorkers;
parpool(poolWorkers)

clc; clear all ;
utdNodesCalibratorOptimized(1);
clc;clear all ;
utdNodesCalibratorOptimized(2);
clc;clear all ;
utdNodesCalibratorOptimized(3);
clc;clear all ;
utdNodesCalibratorOptimized(4);
clc;clear all ;
tdNodesCalibratorOptimized(5);
clc;clear all ;
utdNodesCalibratorOptimized(6);
clc;clear all ;
utdNodesCalibratorOptimized(7);
clc;clear all ;
utdNodesCalibratorOptimized(8);
clc;clear all ;
utdNodesCalibratorOptimized(9);
clc;clear all ;
utdNodesCalibratorOptimized(10);
clc;clear all ;
utdNodesCalibratorOptimized(11);
clc;clear all ;
utdNodesCalibratorOptimized(12);
clc;clear all ;
utdNodesCalibratorOptimized(13);
clc;clear all ;
utdNodesCalibratorOptimized(14);
clc;clear all ;
utdNodesCalibratorOptimized(15);
clc;clear all ;

poolobj = gcp('nocreate');
delete(poolobj);

