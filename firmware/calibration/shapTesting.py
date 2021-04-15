
from scipy.io import loadmat
import yaml
import pandas as pd
import numpy as np
np.random.seed(0)
import shap
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from sklearn.ensemble import RandomForestRegressor
import scipy.io as sio
import xgboost


def mat2Py(fileName):

    # Load File Name
    mat = loadmat(fileName)
    structIn= mat['matData']
    data = structIn[0, 0]['table']['data']
    
    # Get Column Names 
    dataCols = [name[0] for name in structIn[0, 0]['columns'][0]]

    # Create Dictoinary for data Frame 
    tableDict = {}
    for colidx in range(len(dataCols)):
        tableDict[dataCols[colidx]] = [val[0] for val in data[0, 0][0, colidx]]

    # Return Data Frame 
    return pd.DataFrame(tableDict)






#  Reading the definitions File 
with open('../mintsDefinitions.yaml') as file:
    mintsDefinitions = yaml.load(file, Loader=yaml.FullLoader)
    # print(mintsDefinitions)

dataFolder         = mintsDefinitions['dataFolder']
nodeIDs            = mintsDefinitions['nodeIDs']
# timeSpan           = seconds(mintsDefinitions['timeSpan)']
# % binsPerColumn      = mintsDefinitions['binsPerColumn']
numberPerBin       = mintsDefinitions['numberPerBin']
pValid             = mintsDefinitions['pValid']
airmarID           = mintsDefinitions['airmarID']
poolWorkers         = mintsDefinitions['poolWorkers']

mintsTargets      = mintsDefinitions['mintsTargets']

rawFolder           =  dataFolder + "/raw";
rawMatsFolder       =  dataFolder + "/rawMats";
centralMatsFolder   =  rawMatsFolder  + "/CentralNodes";
referenceFolder     =  dataFolder + "/reference";
referenceMatsFolder =  dataFolder + "/referenceMats";

palasFolder         =  referenceFolder       + "/palasStream";
palasMatsFolder     =  referenceMatsFolder   + "/palas";
licorMatsFolder     =  referenceMatsFolder   + "/licor";
noxMatsFolder       =  referenceMatsFolder   + "/nox";
bcMatsFolder     =  referenceMatsFolder      + "/bc";
o3MatsFolder       =  referenceMatsFolder    + "/o3";

driveSyncFolder     =  dataFolder +"/exactBackUps/palasStream/";
mergedMatsFolder    =  dataFolder + "/mergedMats/centralNodes";
GPSFolder           =  referenceMatsFolder + "/carMintsGPS"  ;
airmarFolder        =  referenceMatsFolder + "/airmar"
modelsMatsFolder    =  dataFolder + "/modelsMats/centralNodes";
trainingMatsFolder  =  dataFolder + "/trainingMats/centralNodes";
plotsFolder         =  dataFolder + "/visualAnalysis/centralNodes";
resultsFolder       =  dataFolder + "/results/centralNodes";
updateFolder        =  dataFolder + "/lastUpdate/centralNodes";


nodeIndex  = 1
inputStack = 1
nodeID   = nodeIDs[0]['nodeIDXu4'];
nodeStack= nodeIDs[0]['inputStack'];


def main():

    # CO2 Shap Values 
    dFTrain = mat2Py('co2Train.mat') 
    dFValid = mat2Py('co2Valid.mat') 
    

    # print(dF)
    # df = pd.read_csv('/winequality-red.csv') # Load the data
    # Change Labels of Input Variables 

    # The target variable is 'quality'.
    yTrain  = dFTrain['CO2']
    yValid  = dFValid['CO2']
    
    xTrain  =  dFTrain.drop(labels='CO2',axis=1)
    xValid  =  dFValid.drop(labels='CO2',axis=1)
    xTrain.columns =mintsDefinitions['mintsInputLabelsStackPy_1_1']
    xValid.columns =mintsDefinitions['mintsInputLabelsStackPy_1_1']
    # print(xTrain)
    # model = RandomForestRegressor(max_depth=6, random_state=0, n_estimators=10)
    
    # model.fit(xTrain, yTrain)
    
    # shap_values = shap.TreeExplainer(model).shap_values(xTrain)
    # shap.summary_plot(shap_values, xTrain, plot_type="bar")
    # shap.summary_plot(shap_values, xTrain)
    # shap.dependence_plot("C0$_{2}$ SCD30", shap_values, xTrain)

    model = xgboost.train({"learning_rate": 0.01}, xgboost.DMatrix(xTrain, label=yTrain), 100)

    # explain the model's predictions using SHAP
    # (same syntax works for LightGBM, CatBoost, scikit-learn and spark models)
    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(xTrain)

    # visualize the first prediction's explanation (use matplotlib=True to avoid Javascript)
    # shap.force_plot(explainer.expected_value, shap_values[0,:], xTrain.iloc[0,:])
    shap.summary_plot(shap_values, xTrain, plot_type="bar")
    shap.summary_plot(shap_values, xTrain)
    shap.dependence_plot("C0$_{2}$ SCD30", shap_values, xTrain)

    shap.summary_plot(shap_values, xTrain, plot_type="bar")




# print(In_Train)
# print(Out_Train)

# print(dataIn)

#    'Mdl',...
#         'In_Train',...
#         'Out_Train',...
#         'In_Validation',...
#         'Out_Validation',...
#         'trainingTT',...
#         'validatingTT',...
#         'trainingT',...
#         'validatingT',...
#         'mintsInputs',...
#         'mintsInputLabels',...
#         'target',...
#         'targetLabel',...
#         'nodeID',...
#         'mintsInputs',...
#         'mintsInputLabels',...
#         'binsPerColumn',...
#         'numberPerBin',...
#         'pValid', ...
#         'resultsCurrent'...




if __name__ == "__main__":
   main()
