% Copyright 2016 - 2017 The MathWorks, Inc.
%% WFA for independent optimization
% Setup parameters for WFA
setParam;
for i = 1:nWalk
    disp('================ In-sample test ================')
    disp(wfaPeriod(i,:))
    dateIST2 = dateIST{i};
    
    % ===== In-sample test for each pair =====
    optimParam = zeros(nRowU,1);
    for k = 1:nRowU
        u2 = u(k,:);
        pnl = zeros(nParam,1);
        sharpeRatio = zeros(nParam,1);
        parfor j = 1:nParam
           [pnl(j),sharpeRatio(j)] = runIST(u2,prices,dateIST2,param(j));
        end
        disp(['In-sample-test for ' u2{1} ' and ' u2{2}])
        resultTable = table(param',pnl,sharpeRatio);
        optimParam(k) = calcOptimParam(resultTable,paramType);
    end
    
    % ===== Out-of-sample test =====
    [pnlTable,P,T,TOut,TClose] = runOST(u,prices,pnlTable,P,...
        T, TOut, TClose, dateOST{i}, optimParam);
end
plotSummary;