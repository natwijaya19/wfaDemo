function [pnl, rpnl, urpnl, slipage, tCost] = calcPNL(prices,date,...
 TOut, TClose)
% calcPNL will calculate P%L (pnl), realized P&L (rpnl), unrealized P&L 
% (urpnl), actual slipage, and actual transaction cost. 
% Every number is cumulative
% Requires:         getHistPrice.m (for mark-to-market)
% Called from:      runIST.m, runOST.m
% Copyright 2016 - 2017 The MathWorks, Inc.

% Set initial status of variable
urpnl = 0;
capGain = 0;
slipage = 0;
tCost = 0;

%% Calculate P&L related variables from closed transaction (TClose)
% No unrealized P&L here because it can only be in TOut
if ~isempty(TClose)
    capGain = sum(TClose.capGain);
    slipage = sum(TClose.slipage);
    tCost = sum(TClose.tCost);
end

%% Calculate P&L related variables from oustanding transaction (TOut)

% Calculate P&L if Tout is not empty
if ~isempty(TOut)
    
    % Find slipage and tCost in tOut
    slipage = slipage + sum(TOut.slipage);
    tCost = tCost + sum(TOut.tCost);
    
    nTOut = height(TOut);
    for i = 1:nTOut
        symbol = TOut.symbol{i};
        side = upper(TOut.side{i});
        qty = TOut.qty(i); 
        
        % Assign side = 1 for BUY, -1 for SELL
        if strcmp(side,'BUY')
            side1 = 1;
        elseif strcmp(side,'SELL')
            side1 = -1;
        else
            error('Wrong side') 
        end
        
        % calculate unrealized p&L
        openPrice = TOut.execPrice(i);
        closePrice = getHistPrice(prices,symbol,date,'CLOSE');
        urpnl = urpnl+ qty*side1*(closePrice-openPrice);
    end
end
%% Calculate realized P&L and Total P&L
rpnl = capGain - slipage - tCost;
pnl = rpnl + urpnl;
end

