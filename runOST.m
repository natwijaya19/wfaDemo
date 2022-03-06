function [pnlTable,P,T,TOut,TClose] = runOST(u,prices,...
    pnlTable,P,T,TOut,TClose,d,param)
% runOST (run out-of-sample test) is the function to perform out-of-sample 
% test based on given parameter (param) and the vector of trading days (d).
% The result will be presented in both P&L and Sharpe ratio
% Requires:         setCost.m, strategy.m, submitOrder.m, calcPNL.m,
%                   plotAnimatedline.m, plotMarker.m
% Called from:      runWFA1.m, runWFA2.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Initialize Parameters
setCost;
nTDay = length(d);
newPnlTable = array2table(zeros(nTDay,6),'VariableNames',...
    {'date','pnl','rpnl','urpnl','slipage','tCost'});

%% Out-of-sample test for each trading day in d
disp('============== Out-of-sample test ==============')
for i = 1:nTDay
    % Execute trading strategy
    [bList,sList,bPrice,sPrice, bQty,sQty]=strategy(u,prices,...
        initialCash,d(i),P,param); 
    
    % Update portfolio and transaction lists (submit orders)
    [P,T,TOut,TClose] = submitOrder(prices,P,T,TOut,TClose,d(i),...
    bList,sList,bPrice,sPrice,bQty,sQty); 

    % Calculate and store P&L
    [pnl,rpnl, urpnl, slipage, tCost] = calcPNL(prices,d(i), TOut, TClose);
    dateI = datenum(d(i));
    newPnlTable(i,:) = table(dateI,pnl, rpnl, urpnl, slipage, tCost);
   
    % Plot animated line
    plotAnimatedPnl;
end

% Create/add P&L table
if isempty(pnlTable)
    pnlTable = newPnlTable;
else
    pnlTable = [pnlTable; newPnlTable];
end

% Plot marker
plotMarker;

%% Performance analytic (using Financial Toolbox)
% Calculate annualized Sharpe ratio
portValue = table2array(pnlTable(:,2))+initialCash;
portReturn = tick2ret(portValue);
sharpeRatio = round(sharpe(portReturn,riskFree),4)*sqrt(tDayConv);

% Display performance
disp([' * Cumulative P&L = ' num2str(pnlTable.pnl(end,1))]);
disp([' * Cumulative Sharpe Ratio = ' num2str(sharpeRatio)]);
end