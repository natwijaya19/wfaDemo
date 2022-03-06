function optimParam = calcOptimParam(resultTable,paramType)
% calcOptimParam will find the optimal parameter that maximize the 
% objective function (P&L or Sharpe ratio), which is set in setParam.m.
% Requires:         N/A
% Called from:      runWFA1.m, runWFA2.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Find the optimal parameter
% Find the maximum result based on ParamType, which is set in setParam.m
result = table2array(resultTable);
maxParam = max(result(:,paramType)); 

% Find the paramter that has the result = maxParam
% If the number of parameter > 1, select the first one. Usually, it will be
% the smallest one, but it depends on how we setup in setParam.m
idx = find(result(:,paramType) == maxParam,1,'first');
optimParam = result(idx,1);

% Display the resultTable and optimal parameter
resultTable.Properties.VariableNames = {'Parameter' ...
    'ProfitLoss' 'SharpeRatio'};
disp(resultTable);
disp(['Optimal parameter = ' num2str(optimParam)]);
disp('------------------------------------------------');
end