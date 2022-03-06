function [P,T,TOut,TClose] = updatePort(P,T,TOut,TClose,TNew)
% updatePort will update portfolio (P), all transaction (T), 
% outstanding transaction (TOut), and closed transaction (TClose) 
% based on existing lists and new transaction list (TNew) 
% Requires:         updateTClose, updatePortCost (both are local function)
% Called from:      submitOrder.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% update all transaction (T)
% Check TNew is empty, otherwise update T and extract variable from TNew
if isempty(TNew) == true
    disp('No Transaction')
    return
else
    if isempty(T) == true
        T = TNew;
    else 
        T = [T ; TNew];
    end
    symbol = TNew.symbol;
    side = TNew.side;
    qty = TNew.qty;
    cost = TNew.execPrice;
end

%% update P, TOut, and TClose
if isempty(TOut) == false
    % Number of transactions in TOut
    L1 = height(TOut); 
    
    % Number of assets in Portfolio (P)
    L2 = height(P); 
    
    % Check if TNew is open(1)/close(0) and get the location in P where
    % symbols are matched (not neccessary open)
    [open,loc] = isOpen(symbol, side, P); 
    
    % If new transaction is not an existing symbol in P,
    % add new data into TOut and P
    if loc == 0 
        TOut = [TOut; TNew];
        Pnew = table(symbol,side,qty,cost);
        P = [P;Pnew];
    
    % If new transaction is an existing symbol (open) in P,
    % add new data into TOut, add qty to P, and update cost in P
    elseif open == 1 
        TOut = [TOut; TNew];
        netqty = P.qty(loc)+ qty;
        P.cost(loc) = (P.cost(loc)*P.qty(loc) + cost*qty)/netqty;
        P.qty(loc) = netqty;
        
    % If new transaction is an existing symbol (close) in P,
    % update TOut and P
    elseif open == 0 
        qty2 = qty;
        delrow = zeros(L1,1); 
        
        % Go into each tranaction of Tout
        for i = 1:L1
            TOutSymbol = TOut.symbol(i); % extact the symbol
            if strcmp(TOutSymbol,symbol) % if symbol is matched, then:
                %if qty2 is still positive
                if qty2 > 0
                    % if qty in Tout is greater than qty2, meaning that we
                    % have to dedeuct the qty from Tout and no need to
                    % delete this whole transaction out
                    if TOut.qty(i) > qty2
                        % Add new transact with qty2 to Tclose
                        TClose = updateTClose(TOut(i,:),TClose,TNew,qty2);
                        % New qty = original qty minus qty2 from Tnew
                        newqty = TOut.qty(i) - qty2;
                        
                        % Prorate slipage and tcost in Tout because qty is
                        % reduced.
                        % calculate new slipage in Tout
                        TOut.slipage(i) = TOut.slipage(i)*newqty/...
                            TOut.qty(i);
                        % calculate new tcost in Tout
                        TOut.tCost(i) = TOut.tCost(i)*newqty/TOut.qty(i);
                        TOut.qty(i) = newqty; % update qty in Tout
                        qty2 = 0; % Flag that qty2 is completely matched
                        
                        % if qty in Tout <= qty2, meaning
                        % that we have to delete the transaction from Tout
                    else
                        % Calculate unmatch qty in Nnew
                        qty2 = qty2-TOut.qty(i);
                        % Add new transact with qty2 to Tclose based on
                        % original qty in Tout
                        TClose = updateTClose(TOut(i,:),TClose,TNew,...
                            TOut.qty(i));
                        % reduce qty in Tout to zero (already closed)
                        TOut.qty(i) = 0;
                        % no need to update slipage and t cost as this row
                        % will be deleted
                        delrow(i) = 1; % mark this row for deletion
                        
                    end
                end
            end
        end
        
        %Delete row in Tout that were flag due to completely closed
        idx = find(delrow);
        for i = idx
            TOut(i,:) = [];
        end
        
        delrow = 0;
        for i = 1:L2 % Deduct qty of TNew from Port and update cost
            PSymbol = P.symbol(i);
            if strcmp(PSymbol,symbol) %is symbol match?
                % Dedeuct the portfolio qty by the closing qty
                P.qty(i) = P.qty(i) - qty;
                
                % If the qty of asset in the portfolio is still positive,
                % then update the new cost based on FIFO
                if P.qty(i)> 0
                    P.cost(i) = updatePortCost(TOut,symbol,side);
                else
                    % If the qty of asset in the portfolio is not positive,
                    % then flag this asset to be deleted
                    delrow(i) = 1;
                end
            end
        end
        
        %Delete row in portfolio that were flag due to completely closed
        idx = find(delrow);
        for i = idx
            P(i,:) = [];
        end
    end
    
else % If TOut is empty
    P = table(symbol,side,qty,cost); % Add Tnew to P
    TOut = TNew; % Add Tnew to TOut
    % Tclose remain unchanged
end

end
%% updatePortCost (local function)
function newCost = updatePortCost(TOut,symbol,side)
% This subfunction is for updating portfolio cost when the qty is
% reduced. The updated cost is based on FIFO (First In, First Out)

% Initialing parameters
value = 0;
totalQty = 0;
newCost = 0;

% Number of outstanding transactions
L = height(TOut); 

% Find the opposite side
if strcmp(side,'BUY')
    oppSide = {'SELL'};
elseif strcmp(side,'SELL')
    oppSide = {'BUY'};
else
    error('Unknow Side')
end

% Looping into outstanding transaction one-by-one
for j = 1:L
    % Check if the symbol is matched
    testsymbol = strcmp(TOut.symbol(j),symbol);
    % Check if the side is opposite
    testside = strcmp(TOut.side(j),oppSide);
    
    % If symbols are match and sides are opposite, then calculate
    % total qty and value (value = sum of price*qty)
    if testsymbol && testside
        value = value + TOut.qty(j)* TOut.execPrice(j);
        totalQty = totalQty + TOut.qty(j);
    end
end

if totalQty == 0
    % In case that there is no qty found (Not supposed to happen)
    error('No qty found in Tout')
else
    % Calculate new cost
    newCost = value/totalQty;
end
end
%% updateTClose (local function)
function TClose = updateTClose(TOut,TClose, TNew, closeQty)
% This is for updating the closed transaction when there is a new
% transaction with the opposite side from the one in portfolio.

% Extract open/close datetime from Tout and Tnew respectively
opendatetime = TOut.dateTime;
closedatetime = TNew.dateTime;

% Compare the symbol in Tout and Tnew (should be the same)
symbol1 = TOut.symbol; % Extract symbol from Tout
symbol2 = TNew.symbol; % Extract symbol from Tnew
if strcmp(symbol1,symbol2)
    % create new variable ('symbol') if both symbols are the same
    symbol = symbol1; 
else
    % Return error if symbol is not the same
    error('Unmatched symbol')
end


openSide = TOut.side; % Extract side from Tout as an open side
closeSide = TNew.side; % Extract side from Tnew
openPrice = TOut.execPrice; % Extract openprice from Tout
closePrice = TNew.execPrice; % Extract closeprice from Tnew

% Compare the side in Tout and Tnew (should be opposite)
if strcmp(closeSide,'BUY')
    if strcmp(openSide,'SELL')
        % Calculate capital gain when open side is sell
        capGain = closeQty*(openPrice-closePrice);
    else
        error('Same side')
    end
elseif strcmp(closeSide,'SELL')
    if strcmp(openSide,'BUY')
        % Calculate capital gain when open side is buy
        capGain = closeQty*(closePrice-openPrice);
    else
        error('Same side')
    end
else
    error('Side is unknown')
end

% Update slipage and tcost in outstanding transactions
% Concept here is to prorate the slipage based on the existing 
qty1 = closeQty;
qty2 = TNew.qty;
qty3 = TOut.qty;
slipage = TOut.slipage*qty1/qty3 + TNew.slipage*qty1/qty2;
tCost = TOut.tCost*qty1/qty3 + TNew.tCost*qty1/qty2;

% Update the closing transaction table (add new one to the bottom if there
% is already an existing Tclose
TCloseNew = table(opendatetime,closedatetime,symbol,openSide,openPrice,...
    closePrice, closeQty, slipage, tCost, capGain);
if isempty(TClose)
    TClose = TCloseNew;
else
    TClose = [TClose; TCloseNew];
end
end
%% Check if TNew (from its symbol and side) is open/close order
function [open, location] = isOpen(symbol, side, P)
    % Check if TNew is open (1) or close (0) transaction
    open = 1; % Set default as a new (1)
    location = 0; % Set default location
    L1 = height(P); % Number of transactions in P
    
    for i = 1:L1
        PSymbol = P.symbol(i); % Extract symbol from P
        PSide = P.side(i); % Extract side from P
        % Find opposite side of the transaction in P
        if strcmp(PSide,'BUY')
            oppSide1 = {'SELL'};
        elseif strcmp(PSide,'SELL')
            oppSide1 = {'BUY'};
        else
            error('Unknow Side')
        end
        
        % Find the location in the table where symbols are matched
        % Symbol  is supposed to be unique in P
        if strcmp(PSymbol,symbol)
            location = i;
            % If sides are opposite, flag as a closing transaction
            if strcmp(side,oppSide1)
                open = 0;
            end
        end

    end
end