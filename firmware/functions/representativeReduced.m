function [In_Train,...
            In_Validation,...
               trainingTT, validatingTT,...
                trainingT, validatingT ] ...
                            = representativeReduced(...
                                inputVariables,target,...
                                       trainingTT, validatingTT)
   
    
    
    trainingTT   = trainingTT(: ,{inputVariables{:},target});
    validatingTT = validatingTT(:,{inputVariables{:},target});

    trainingT    = timetable2table(trainingTT);
    validatingT  = timetable2table(validatingTT);
    
    In_Train     = table2array(trainingT(:,inputVariables));
    In_Validation     = table2array(validatingT(:,inputVariables));

    height(trainingT)
    height(validatingT)
end