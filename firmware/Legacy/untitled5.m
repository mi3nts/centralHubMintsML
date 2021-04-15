
dataFolder : "/home/teamlary/mnt/teamlary1/mintsData"
poolWorkers: 8

timeSpan: 30 
timeSpan2: 3600 

airmarID: "001e0610c0e4"

BinsPerColumn  : 2
numberPerBin   : 2

pValid         : 0.15

nodeIDs:
    - nodeIDXu4:    "001e06318c91"
      nodeIDPi:     "b827ebf74482"
      nodeIDJetson: "00044bec2707"
      inputStack: 1
    - nodeIDXu4:    "001e06373724"
      nodeIDPi:     "b827eb52fc29"
      nodeIDJetson: "00044be6fea1"
      inputStack: 1
    - nodeIDXu4:    "001e0637371e"
      nodeIDPi:     "b827eb60cd60"
      nodeIDJetson: "00044be5fc9c"
      inputStack: 1

mintsTargets:
    - target:       "CO2"
      targetLabel:  "CO_{2}"
      unit:  "ppm"
      instrument:  "LI-850 Gas Analyzer"
      targetStack: 1
      limits:  [320,380]

    - target:       "H2O"
      targetLabel:  "H_{2}O"
      unit:  "mmol/mol"
      instrument:  "LI-850 Gas Analyzer"
      targetStack: 1
      limits:  [0,35]

    - target:       "BC"
      targetLabel:  "BC"
      unit:  "mg/m3"
      instrument:  "2B BC MONITOR "
      targetStack: 1
      limits:  [0,25]

    - target:       "O3"
      targetLabel:  "O_{3}"
      unit:  "ppbv"
      instrument:  "2B O_{3} MONITOR "
      targetStack: 1
      limits:  [0,70]


#    - target:       "NO2"
#      targetLabel:  "NO_{2}"
#      unit:  "ppb"
#      instrument:  "2B NO2/NO/NOX MONITOR "
#      targetStack: 1
#      limits:  [0,100]
#
#   - target:       "NOX"
#      targetLabel:  "NO_{X}"
#      unit:  "ppb"
#      instrument:  "2B NO2/NO/NOX MONITOR "
#      targetStack: 1
#      limits:  [0,100]

#   - target:       "NO"
#      targetLabel:  "NO"
#      unit:  "ppb"
#      instrument:  "2B NO2/NO/NOX MONITOR "
#      targetStack: 1
#      limits:  [0,100]


## meant for CO2, H20, NO2 and PM
mintsInputsStack_1_1:
     - "temperature_mintsDataBME280"
     - "pressure_mintsDataBME280"  
     - "humidity_mintsDataBME280"  
     - "altitude_mintsDataBME280"  
     - "pm1_mintsDataHM3301"       
     - "pm2_5_mintsDataHM3301"     
     - "pm10_mintsDataHM3301"      
     - "nh3"                       
     - "co"                        
     - "no2"                       
     - "c3h8"                      
     - "c4h10"                     
     - "ch4"                       
     - "h2"                        
     - "c2h5oh"                    
     - "binCount0"                 
     - "binCount1"                 
     - "binCount2"                 
     - "binCount3"                 
     - "binCount4"                 
     - "binCount5"                 
     - "binCount6"                 
     - "binCount7"                 
     - "binCount8"                 
     - "binCount9"                 
     - "binCount10"                
     - "binCount11"                
     - "binCount12"                
     - "binCount13"                
     - "binCount14"                
     - "binCount15"                
     - "binCount16"                
     - "binCount17"                
     - "binCount18"                
     - "binCount19"                
     - "binCount20"                
     - "binCount21"                
     - "binCount22"                
     - "binCount23"                
     - "bin1TimeToCross"           
     - "bin3TimeToCross"           
     - "bin5TimeToCross"           
     - "bin7TimeToCross"           
     - "sampleFlowRate"            
     - "temperature_mintsDataOPCN3"
     - "humidity_mintsDataOPCN3"   
     - "pm1_mintsDataOPCN3"        
     - "pm2_5_mintsDataOPCN3"      
     - "pm10_mintsDataOPCN3"       
     - "rejectCountGlitch"         
     - "rejectCountLongTOF"        
     - "rejectCountRatio"          
     - "rejectCountOutOfRange"     
     - "fanRevCount"               
     - "laserStatus"               
     - "c02"                       
     - "temperature_mintsDataSCD30"
     - "humidity_mintsDataSCD30"   

mintsInputLabelsStack_1_1:
     - "Temperature BME280"
     - "Pressure BME280"  
     - "Humidity BME280"  
     - "Altitude BME280"  
     - "PM_{1} HM3301"       
     - "PM_{2.5} HM3301"     
     - "PM_{10} HM3301"      
     - "NH_{3} MiCS6814"                                   
     - "CO MiCS6814"                                    
     - "NO_{2} MiCS6814"                                   
     - "C_{3}H_{8} MiCS6814"                                  
     - "C_{4}H_{10} MiCS6814"                                 
     - "CH_{4} MiCS6814"                                   
     - "H_{2} MiCS6814"                                    
     - "C_{2}H_{5}OH MiCS6814"                    
     - "Bin 0 OPCN3"                 
     - "Bin 1 OPCN3"                 
     - "Bin 2 OPCN3"                 
     - "Bin 3 OPCN3"                 
     - "Bin 4 OPCN3"                 
     - "Bin 5 OPCN3"                 
     - "Bin 6 OPCN3"                 
     - "Bin 7 OPCN3"                 
     - "Bin 8 OPCN3"                 
     - "Bin 9 OPCN3"                 
     - "Bin 10 OPCN3"                
     - "Bin 11 OPCN3"                
     - "Bin 12 OPCN3"                
     - "Bin 13 OPCN3"                
     - "Bin 14 OPCN3"                
     - "Bin 15 OPCN3"                
     - "Bin 16 OPCN3"                
     - "Bin 17 OPCN3"                
     - "Bin 18 OPCN3"                
     - "Bin 19 OPCN3"                
     - "Bin 20 OPCN3"                
     - "Bin 21 OPCN3"                
     - "Bin 22 OPCN3"                
     - "Bin 23 OPCN3"                
     - "Bin 1 time to Cross OPCN3"           
     - "Bin 3 time to Cross OPCN3"           
     - "Bin 5 time to Cross OPCN3"           
     - "Bin 7 time to Cross OPCN3"           
     - "Sample Flow Rate OPCN3"            
     - "Temperature OPCN3"
     - "Humidity OPCN3"   
     - "PM_{1} OPCN3"        
     - "PM_{2.5} OPCN3"      
     - "PM_{10} OPCN3"       
     - "Reject Count Glitch"         
     - "Reject Count Long TOF"        
     - "Reject Count Ratio"          
     - "Reject Count Out Of Range"     
     - "Fan Rev Count"               
     - "Laser Status"                           
     - "C0_{2} SCD30"                       
     - "Temperature SCD30"
     - "Humidity SCD30"   

mintsInputLabelsStackPy_1_1:
     - "Temperature BME280"
     - "Pressure BME280"  
     - "Humidity BME280"  
     - "Altitude BME280"  
     - "PM$_{1}$ HM3301"       
     - "PM$_{2.5}$ HM3301"     
     - "PM$_{10}$ HM3301"      
     - "NH$_{3}$ MiCS6814"                                   
     - "CO MiCS6814"                                    
     - "NO$_{2}$ MiCS6814"                                   
     - "C$_{3}$H$_{8}$ MiCS6814"                                  
     - "C$_{4}$H$_{10}$ MiCS6814"                                 
     - "CH$_{4}$ MiCS6814"                                   
     - "H$_{2}$ MiCS6814"                                    
     - "C$_{2}$H$_{5}$OH MiCS6814"                    
     - "Bin 0 OPCN3"                 
     - "Bin 1 OPCN3"                 
     - "Bin 2 OPCN3"                 
     - "Bin 3 OPCN3"                 
     - "Bin 4 OPCN3"                 
     - "Bin 5 OPCN3"                 
     - "Bin 6 OPCN3"                 
     - "Bin 7 OPCN3"                 
     - "Bin 8 OPCN3"                 
     - "Bin 9 OPCN3"                 
     - "Bin 10 OPCN3"                
     - "Bin 11 OPCN3"                
     - "Bin 12 OPCN3"                
     - "Bin 13 OPCN3"                
     - "Bin 14 OPCN3"                
     - "Bin 15 OPCN3"                
     - "Bin 16 OPCN3"                
     - "Bin 17 OPCN3"                
     - "Bin 18 OPCN3"                
     - "Bin 19 OPCN3"                
     - "Bin 20 OPCN3"                
     - "Bin 21 OPCN3"                
     - "Bin 22 OPCN3"                
     - "Bin 23 OPCN3"                
     - "Bin 1 time to Cross OPCN3"           
     - "Bin 3 time to Cross OPCN3"           
     - "Bin 5 time to Cross OPCN3"           
     - "Bin 7 time to Cross OPCN3"           
     - "Sample Flow Rate OPCN3"            
     - "Temperature OPCN3"
     - "Humidity OPCN3"   
     - "PM$_{1}$ OPCN3"        
     - "PM$_{2.5}$ OPCN3"      
     - "PM$_{10}$ OPCN3"       
     - "Reject Count Glitch"         
     - "Reject Count Long TOF"        
     - "Reject Count Ratio"          
     - "Reject Count Out Of Range"     
     - "Fan Rev Count"               
     - "Laser Status"                           
     - "C0$_{2}$ SCD30"                       
     - "Temperature SCD30"
     - "Humidity SCD30"  






