
close all
% load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_06_12_46_15/Central_Ronn_All_ONN_3_2021_03_06_12_46_15_001e06318c91_CO2.mat')
%  load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_06_12_26_15/Central_Ronn_All_ONN_3_2021_03_06_12_26_15_001e06318c91_CO2.mat')
  load('/home/teamlary/mnt/teamlary1/mintsData/trainingMats/centralNodes/001e06318c91/Central_Ronn_All_ONN_3_2021_03_07_16_47_39/Central_Ronn_All_ONN_3_2021_03_07_16_47_39_001e06318c91_CO2.mat')
 
mat2pyFun(trainingT,'co2Train3')
mat2pyFun(validatingT,'co2Valid3')
