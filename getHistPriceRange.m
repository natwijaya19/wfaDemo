function histPrice = getHistPriceRange(prices,symbol,date,price,lag)
% getHistPriceRange extract the historical price of one symbol based on 
% price type starting from (date - lag +1) to (date)
% Allowed price type: 'ATO' = 'open', 'ATC'/'CLOSE' = 'close', 'ADJ CLOSE'
% Requires:         strategy.m
% Call from:        N/A
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Setup data
setUnderlying;
date = datenum(date);

% Find the index of given symbol in the universe (u)
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
idx1 = find(cellfun(cellfind(symbol),u));

%% Extract price based on price type and date
% Determine price type (OPEN, CLOSE, ADJ CLOSE) from the given price type
if strcmp(price,'ATO')
    Open = prices{2};
    histPrice = Open{idx1};
elseif strcmp(price,'ATC')
    Close = prices{3};
    histPrice = Close{idx1};
elseif strcmp(price,'CLOSE')
    Close = prices{3};
    histPrice = Close{idx1};
else
    error('Price is not ATO/ATC')
end
histDate1 =  prices{1};
histDate2 = histDate1{idx1};

% Extract price by date
idx2 = find(histDate2==date);
histPrice = histPrice(idx2-(lag-1):idx2);
end