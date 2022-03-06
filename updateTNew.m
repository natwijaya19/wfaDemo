function TNew = updateTNew(prices,dateTime,symbol,side,qty,orderPrice,...
    slipglobal,tCostHlobal)
% updateTNew will create new transaction list (TNew) based on buy/sell 
% lists (including price and quantity) generate from trading strategy 
% Requires:         getHistPrice.m
% Called from:      submitOrder.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Data conversion
% Convert to cell array with upper case 
symbol = {upper(symbol)}; 
side = {upper(side)};
if isnumeric(orderPrice) == false
    orderPrice = {upper(orderPrice)}; 
end

% Convert cell array to matrix (array)
if iscell(qty)
    qty = cell2mat(qty);
end

%% Create TNew (new transaction)
% Assign numeric execution price based on specified price type
% Get open price for ATO or close price for ATC
if isnumeric(orderPrice) == true
    execPrice = orderPrice;
else 
    if strcmp(orderPrice{1},'ATO') || strcmp(orderPrice{1},'ATC')...
        || strcmp(orderPrice{1},'CLOSE')
        
        execPrice = getHistPrice(prices,symbol,dateTime,orderPrice);
    else
        error('Wrong price')
    end
end

% Calculate slipage and transaction for this trade
slipage = execPrice*qty*slipglobal;
tCost = execPrice*qty*tCostHlobal;

% Create TNew (new transaction)
TNew = table(dateTime, symbol,side,qty,orderPrice,execPrice,slipage,tCost);
end