function [] = mat2pyFun(tableIn,saveName)
    matData = struct('table', struct(tableIn), ...
        'columns', {struct(tableIn).varDim.labels});
    save(saveName, 'matData');
end