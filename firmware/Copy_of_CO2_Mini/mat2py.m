
close all
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_06_12_46_15/Central_Ronn_All_ONN_3_2021_03_06_12_46_15_001e06318c91_CO2.mat')
%  load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_06_12_26_15/Central_Ronn_All_ONN_3_2021_03_06_12_26_15_001e06318c91_CO2.mat')
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_07_16_47_39/Central_Ronn_All_ONN_3_2021_03_07_16_47_39_001e06318c91_CO2.mat')

load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/CO2_reduced_2_EL_2021_04_01_10_57_36/CO2_reduced_2_EL_2021_04_01_10_57_36_001e06318c91_CO2.mat')

trainingT.dateTime = [];   
validatingT.dateTime = [];

mat2pyFun(trainingT,'co2TrainReduced')
mat2pyFun(validatingT,'co2ValidReduced')
