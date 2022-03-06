function [bList,sList,bPrice,sPrice,bQty,sQty]=strategy(u,Prices,...
    initialCash,d,P,param)
% Simple pair trading strategy.
% Algorithm investment thesis: A pair of correlated assets that breaks its 
% Bollinger bands should convert back into middle of the band. So we are
% going to long one asset and short another asset if the upper or lower
% band is breached. After it is back to its middle band, we will unwind the
% existing position.
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Setup parameters
% Check dimension of u. if u is not in a pair format, report error
[nRowU, nColU] = size(u); 
if nColU ~= 2  
    error('This is not a pair strategy')
end

% Calculate dimension of parameter and position size per pair
nParam = length(param);
posSize = initialCash/nRowU; 

% Initialize outputs as empty variables
bList = cell(nRowU,1);
sList = cell(nRowU,1);
bPrice = cell(nRowU,1);
sPrice = cell(nRowU,1);
bQty = cell(nRowU,1);
sQty = cell(nRowU,1);

% Set execution price
exPrice = 'CLOSE';

% Set lag time for basePrice
lag = 252;

%% Calculate price ratio and Bollinger band of all pairs
bb_all = cell(nRowU,4);
for i = 1:nRowU
    % Set the window size of Bollinger Band 
    winSize = param(min(i,nParam));
   
    % Find price ratio (PR) between each pair
    basePrice1 = getHistPrice(Prices,u(i,1),d,exPrice,lag);
    basePrice2 = getHistPrice(Prices,u(i,2),d,exPrice,lag);
    currPrice1 = getHistPriceRange(Prices,u(i,1),d,exPrice,winSize + 1);
    currPrice2 = getHistPriceRange(Prices,u(i,2),d,exPrice,winSize + 1);
    PR = (currPrice1 ./ basePrice1) ./ (currPrice2 ./ basePrice2);
    
    % Calculate Bollinger band for each pair
    [mid, uppr, lowr] = bollinger(PR, winSize);
    bb_all{i} = [PR(end), mid(end), uppr(end), lowr(end)];
end

%% Main part of strategy
for i = 1:nRowU
    %% Find initial status in the portfolio:
    % 0 = hold nothing, 1 = Long asset1 and short asset2, and
    % -1 = Short asset1 and long asset2
   [status, qty1, qty2] = calcStatus(P,u,i);
   
    %% Create an order based on Bollinger band and holding status
    bb = bb_all{i}; %Set Bollinger band for pair i
    caseNum = 0;
    if (status == 0) && (bb(1) > bb(3))
        % Case 1: No holding position & PR > upper band
        caseNum = 1;
        bList{i} = u{i,2};
        sList{i} = u{i,1};
        bQty{i} = posSize/getHistPrice(Prices,bList{i},d,exPrice);
        sQty{i} = posSize/getHistPrice(Prices,sList{i},d,exPrice);
        
    elseif (status == 0) && (bb(1) < bb(4))
        % Case 2:  No holding position & PR < lower band
        caseNum = 2;
        bList{i} = u{i,1};
        sList{i} = u{i,2};
        bQty{i} = posSize/getHistPrice(Prices,bList{i},d,exPrice);
        sQty{i} = posSize/getHistPrice(Prices,sList{i},d,exPrice);
        
    elseif (status == 1) && (bb(1) > bb(2))
        % Case 3: Long asset1 and short asset2 & PR > mid band
        caseNum = 3;
        bList{i} = u{i,2};
        sList{i} = u{i,1};
        bQty{i} = qty2{:};
        sQty{i} = qty1{:};

    elseif (status == -1) && (bb(1) < bb(2))
        % Case 4: Short asset1 and long asset2 & PR < mid band
        caseNum = 4;
        bList{i} = u{i,1};
        sList{i} = u{i,2};
        bQty{i} = qty1{:};
        sQty{i} = qty2{:};
    end
    
    % Set buying/selling price if there is any action
    if caseNum > 0
        bPrice{i} = exPrice;
        sPrice{i} = exPrice;
    end

end
% Delete empty row
delRow = false(nRowU,1);
for i = 1:nRowU
    if isempty(bList{i}) == true
        delRow(i) = true;
    end
end

if max(delRow) == 1
    bList(delRow) = [];
    sList(delRow) = [];
    bQty(delRow) = [];
    sQty(delRow) = [];
    bPrice(delRow) = [];
    sPrice(delRow) = [];
end

% Convert to cell array
bQty = nonEmptyNum2Cell(bQty);
sQty = nonEmptyNum2Cell(sQty);
end

function [status, qty1, qty2] = calcStatus(P,u,i)

    %% Find initial status in the portfolio if:
    % 0     : hold nothing,
    % 1     : Long asset1 and short asset2
    % -1    : Short asset1 and long asset2
    
    qty1 = 0;
    qty2 = 0;
    
    if isempty(P)
        status = 0;
    else
        idxAsset1 = strcmp(P.symbol,u(i,1));
        idxAsset2 = strcmp(P.symbol,u(i,2));
        side1 = P.side(idxAsset1);
        side2 = P.side(idxAsset2);
        qty1 = num2cell(P.qty(idxAsset1));
        qty2 = num2cell(P.qty(idxAsset2));
        if and(strcmp(side1,'BUY'), strcmp(side2,'BUY'))
            error('Same Side. Both sides are BUY')
        elseif and(strcmp(side1,'SELL'), strcmp(side2,'SELL'))
            error('Same Side. Both sides are SELL')
        elseif and(strcmp(side1,'BUY'), strcmp(side2,'SELL'))
            status = 1;
        elseif and(strcmp(side1,'SELL'), strcmp(side2,'BUY'))
            status = -1;
        else
            status = 0;
        end
    end
end

function Y = nonEmptyNum2Cell(X)
% Data conversion (matrix to cell array)
%% Data conversion (number to cell array)
% If X is not empty, then convert from number to cell array
if isempty(X) == false 
    Y = num2cell(X);
else
    Y = X;
end

end