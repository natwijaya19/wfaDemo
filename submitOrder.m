function [P,T,TOut,TClose] = submitOrder(prices,P,T,TOut,TClose, d,...
    bList,sList,bPrice,sPrice,bQty,sQty)
% submitOrder will update the portfolio and transaction lists based on
% the buy/sell lists (including price and quantity) generate from trading
% strategy in strategy.m
% Requires:         setCost.m, trade.m, updatePort.m
% Called from:      runIST.m, runOST.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Inititalize trading cost
setCost;
%%  Submit buy orders
if isempty(bList) == false % If buying list is not empty
    for i = 1:length(bList)
        % Put buy order in T (All Transaction) and TNew (New Transaction)
        TNew = updateTNew(prices, d, bList{i},'buy',bQty{i},bPrice{i},...
            slipGlobal,tCostGlobal);
        % Update Portfolio, TOut (Outstanding Transaction), and TClose
        % (Closed Transaction) based on the TNew
        [P,T,TOut,TClose] = updatePort(P,T,TOut,TClose,TNew);
    end
end
%%  Submit sell orders
if isempty(sList) == false % If selling list is not empty
    for i = 1:length(sList) 
        % Put sell order in T (All Transaction) and TNew (New Transaction)
        TNew = updateTNew(prices, d, sList{i},'sell',sQty{i},sPrice{i},...
            slipGlobal,tCostGlobal);
        % Update Portfolio, TOut (Outstanding Transaction), and TClose
        % (Closed Transaction) based on the TNew
        [P,T,TOut,TClose] = updatePort(P,T,TOut,TClose,TNew);
    end
end
end

