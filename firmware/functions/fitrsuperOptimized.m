function Super = fitrsuperOptimized(In_Train,Out_Train)

    %--------------------------------------------------------------------------
    % set number of optimization steps for each learner
    nensemble_optimize_iterations=30;
    ngpr_optimize_iterations=30;
    ngpr_super_optimize_iterations=20;
    ngpr_super_error_optimize_iterations=20;

    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    % Train a hyper-parameter optimized NN model for regression
    disp('Train a hyper-parameter optimized NN model for regression')
    tic
    Super.Mdl_NN=fitrnn(In_Train,Out_Train);
    toc

    % Use the fit on the training and validation data
    Out_TrainEstimate_Fit_NN = Super.Mdl_NN(In_Train')';

    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    % Train a hyper-parameter optimized GPR model for regression
    disp('Train a hyper-parameter optimized GPR model for regression')

    % First Optimize all the parameters
    disp('First Optimize all the GPR parameters')
    tic
    Mdl = fitrgp(In_Train,Out_Train,...
        'OptimizeHyperparameters','all',...
        'HyperparameterOptimizationOptions',...
            struct(...
            'AcquisitionFunctionName','expected-improvement-plus',...
            'MaxObjectiveEvaluations',ngpr_optimize_iterations,...
            'UseParallel',true ...
            )...            
        );
    toc

    % Take a copy of the attributes
    disp('Take a copy of the best attributes')
    Best_Sigma=Mdl.HyperparameterOptimizationResults.XAtMinEstimatedObjective.Sigma;
    Best_BasisFunction=char(Mdl.HyperparameterOptimizationResults.XAtMinEstimatedObjective.BasisFunction);
    Best_KernelFunction=char(Mdl.HyperparameterOptimizationResults.XAtMinEstimatedObjective.KernelFunction);
%     Best_KernelScale=Mdl.HyperparameterOptimizationResults.XAtMinEstimatedObjective.KernelScale;
%     Best_Standardize=string2boolean(char(Mdl.HyperparameterOptimizationResults.XAtMinEstimatedObjective.Standardize));

    % Now use these optimum settings to do an exact GPR fit
    disp('Now use these optimum settings to do an exact GPR fit')
    tic
    Super.Mdl_GPR = compact(fitrgp(In_Train,Out_Train,...
        'Sigma',Best_Sigma,...
        'BasisFunction',Best_BasisFunction,...
        'KernelFunction',Best_KernelFunction,...
        'Standardize',1 ...
        ));
    toc                    

    % Use the fit on the training and validation data
    Out_TrainEstimate_Fit_GPR = predict(Super.Mdl_GPR,In_Train);

    %--------------------------------------------------------------------------
    % Train a hyper-parameter optimized Ensemble of Trees model for regression
    disp('Train a hyper-parameter optimized Ensemble of Trees model for regression')

    tic
    Super.Mdl_Ensemble = compact(fitrensemble(In_Train,Out_Train,...
        'OptimizeHyperparameters','all',...
        'HyperparameterOptimizationOptions',...
            struct(...
            'AcquisitionFunctionName','expected-improvement-plus',...
            'MaxObjectiveEvaluations',nensemble_optimize_iterations,...
            'UseParallel',true ...
            )...
        ));
    toc    


    % Use the fit on the training and validation data
    Out_TrainEstimate_Fit_Ensemble = predict(Super.Mdl_Ensemble,In_Train);

    %--------------------------------------------------------------------------
    % Now train the super learner
    disp('Train the super learner model for regression')

    % The model inputs include each of the individual learners
    In_Super_Train=[In_Train Out_TrainEstimate_Fit_NN Out_TrainEstimate_Fit_GPR Out_TrainEstimate_Fit_Ensemble];

    tic
    Super.Mdl = compact(fitrgp(In_Super_Train,Out_Train,...
        'OptimizeHyperparameters','all',...
        'HyperparameterOptimizationOptions',...
            struct(...
            'AcquisitionFunctionName','expected-improvement-plus',...
            'MaxObjectiveEvaluations',ngpr_super_optimize_iterations,...
            'UseParallel',true ...
            )...            
        ));
    toc     

    % keep track of the optimization figures so we can close them later

    % Use the fit on the training and validation data
    Out_TrainEstimate_Fit_Super = predict(Super.Mdl,In_Super_Train);

    % Calculate the mean square error and correlation coeffecient
    %--------------------------------------------------------------------------
    % Calculate the error
    Error_TrainEstimate_Fit_Super=Out_Train-Out_TrainEstimate_Fit_Super;

    % The model inputs include each of the individual learners
    In_Super_Error_Train=[In_Super_Train Out_TrainEstimate_Fit_Super];


    % Now train the super learner error
    disp('Train the super learner error model for regression')

    tic
    Super.MdlError = compact(fitrgp(In_Super_Error_Train,Error_TrainEstimate_Fit_Super,...
        'Standardize',1,...
        'OptimizeHyperparameters','all',...
        'HyperparameterOptimizationOptions',...
            struct(...
            'AcquisitionFunctionName','expected-improvement-plus',...
            'MaxObjectiveEvaluations',ngpr_super_error_optimize_iterations,...
            'UseParallel',true ...
            )...            
        )); 
    toc    

end

