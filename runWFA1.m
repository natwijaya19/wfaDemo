% Copyright 2016 - 2017 The MathWorks, Inc.
%% Start WFA for overall optimization
%Setup parameters for WFA
setParam;

%% 
parfor i = 1:nWalk
    disp('=============== In-sample test ===============')
    disp(wfaPeriod(i,:))
    dateIST2 = dateIST{i};
    
    % ===== In-sample test =====
    pnl = zeros(1,nParam);
    sharpeRatio = zeros(1,nParam);
    for j = 1:nParam
        [pnl(j),sharpeRatio(j)] = runIST(u,prices,dateIST2,param(j));
    end
    resultTable = table(param',pnl',sharpeRatio');
    optimParam = calcOptimParam(resultTable,paramType);
    
    % ===== Out-of-sample test =====
    [pnlTable,P,T,TOut,TClose] = runOST(u,prices,pnlTable,P,...
        T, TOut, TClose, dateOST{i}, optimParam);
end
plotSummary;