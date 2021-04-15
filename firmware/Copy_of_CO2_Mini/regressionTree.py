
from scipy.io import loadmat, savemat
import yaml
import pandas as pd
import numpy as np
import pickle
np.random.seed(0)
import shap
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
from sklearn.ensemble import RandomForestRegressor
import scipy.io as sio
import xgboost
# import the regressor 
from sklearn.tree import DecisionTreeRegressor  
  


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
    dFTrain = mat2Py('co2Train3.mat') 
    dFValid = mat2Py('co2Valid3.mat') 
    

    # print(dF)
    # df = pd.read_csv('/winequality-red.csv') # Load the data
    # Change Labels of Input Variables 

    # The target variable is 'quality'.
    yTrain  = dFTrain['CO2']
    yValid  = dFValid['CO2']
    
    xTrain  =  dFTrain.drop(labels='CO2',axis=1)
    xValid  =  dFValid.drop(labels='CO2',axis=1)
    xTrain.columns =mintsDefinitions['mintsInputLabelsStackPy_2_1']
    xValid.columns =mintsDefinitions['mintsInputLabelsStackPy_2_1']


        # create a regressor object 
    # model= DecisionTreeRegressor(random_state = 0)  
    
    # fit the regressor with X and Y data 
    # model.fit(xTrain, yTrain)
    # model = xgboost.train({"learning_rate": 0.01}, xgboost.DMatrix(xTrain, label=yTrain), 100)
    
    # model = RandomForestRegressor(random_state=0,n_jobs=-1, verbose=1)
    # model.fit(xTrain, yTrain)
    
    # save the model to disk
    filename = 'finalized_Tree3.sav'
    # pickle.dump(model, open(filename, 'wb'))
    print("Model Trainined")
    # print("Loading Model")
    model = pickle.load(open(filename, 'rb'))
    print("Model Loaded")
    # result = loaded_model.score(X_test, Y_test)
    
    print("Shap Analisys")
    explainer = shap.TreeExplainer(model)
    shap_values = explainer.shap_values(xTrain)
    print("Shap Done")

    # visualize the first prediction's explanation (use matplotlib=True to avoid Javascript)
    # shap.force_plot(explainer.expected_value, shap_values[0,:], xTrain.iloc[0,:])
    # shap.summary_plot(shap_values, xTrain, plot_type="bar")

    shap.dependence_plot("C0$_{2}$ SCD30", shap_values, xTrain)
    print("Plotting Figure")
    f = plt.figure()
    mngr = plt.get_current_fig_manager()
    mngr.window.setGeometry(0, 0,2000 ,1300)
    plt.title("CO$_{2}$ Regression Tree \n SHAP Predictor Importance"\
             ,fontsize=18)
    shap.summary_plot(shap_values, xTrain)
    f.savefig("shapTree3.png")

    predTrain = model.predict(xTrain)
    predValid = model.predict(xValid)
    mdic = {"outTrainEstimate": predTrain, "outValidEstimate": predValid}
    savemat("RTOut3.mat", mdic)

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
