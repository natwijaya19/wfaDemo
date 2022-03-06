function [pnlFinal,sharpeRatio] = runIST(u,prices,d,param)
% runIST (run in-sample test) is the function to perform in-sample test 
% based on the given parameter (param) and the vector of trading days (d).
% The result will be presented in both P&L and Sharpe ratio
% Requires:         setCost.m, strategy.m, submitOrder.m, calcPNL.m,
% Called from:      runWFA1.m, runWFA2.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Initialize Parameters
P =[];
T =[];
TOut =[];
TClose =[];
pnl=[];
setCost;
nTDay = length(d);
newPnlTable = array2table(zeros(nTDay,6),'VariableNames',...
    {'date','pnl','rpnl','urpnl','slipage','tCost'});

%% In-sample test for each trading day in d
for i = 1:nTDay
    % Execute trading strategy
    [bList,sList,bPrice,sPrice,bQty,sQty]=strategy(u,prices,...
        initialCash,d(i),P,param); 
    
    % Update portfolio and transaction lists (submit orders)
    [P,T,TOut,TClose] = submitOrder(prices,P,T,TOut,TClose, d(i),...
    bList,sList,bPrice,sPrice,bQty,sQty); 

    % Calculate and store P&L
    [pnl,rpnl,urpnl,slipage,tCost] = calcPNL(prices,d(i), TOut, TClose);
    dateI = datenum(d(i));
    newPnlTable(i,:) = table(dateI,pnl, rpnl, urpnl, slipage, tCost);
end

%% Performance analytic (using Financial Toolbox)
% Calculate annualized Sharpe ratio
portValue = table2array(newPnlTable(:,2))+initialCash;
portReturn = tick2ret(portValue);
sharpeRatio = round(sharpe(portReturn,riskFree),4)*sqrt(tDayConv);
pnlFinal = pnl;
end