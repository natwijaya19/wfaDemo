function histPrice = getHistPrice(prices,symbol,date,price,lag)
% getHistPrice extract the historical price of one symbol based on date,
% price type, and the lag from the specify date (lag is optional)
% Allowed price type: 'ATO' = 'open', 'ATC'/'CLOSE' = 'close', 'ADJ CLOSE'
% Requires:         updateTNew.m, strategy.m
% Call from:        N/A
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Setup data
if nargin < 5
   lag = 0;
end

setUnderlying;
date = datenum(date);

% Find the index of given symbol in the universe (u)
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
idx1 = find(cellfun(cellfind(symbol),u));

%% Extract price based on price type and date
% Determine price type (OPEN, CLOSE) from the given price type

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
histPrice = histPrice(max(idx2-lag,1));
end