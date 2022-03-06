% Copyright 2016 - 2017 The MathWorks, Inc.
%% Calculate risk metrics
% Calculate P&L
pnl = pnlTable.pnl(end,1);
percentPnl = pnl/initialCash ;
dateRange1 = datenum(globalEnd)-datenum(globalStart);
annualizedpnl = (1+percentPnl)^(365/dateRange1) -1;

% Calculate maximum drawdown and its starting and ending index (maxxDDIdx)
portValue = table2array(pnlTable(:,2))+initialCash;
portReturn = tick2ret(portValue);
[maxDD, maxDDIdx] = maxdrawdown(portValue);

% Calculate annualized Sharpe ratio
sharpeRatio = round(sharpe(portReturn,riskFree),4)*sqrt(tDayConv);

%% Plot both the backtest and benchmark performance.

% Setup graph
backtestFig = figure('Units', 'Normalized', ...
                     'Position', 0.25*[1, 1, 2, 2], ...
                     'NumberTitle', 'off', ...
                     'Name', 'WFA equity curve and risk metrics', ...
                     'Menubar', 'none');
ax = axes('Parent', backtestFig, 'Position', [0.1, 0.1, 0.5, 0.8]);

% Plot equity curve (blue line) 
plot(ax, x1, y1, 'b', 'LineWidth', 1.5)
hold(ax, 'on')

% Plot equity curve that cause maximum drawdown (red line)
maxDDIdx2 = maxDDIdx(1):maxDDIdx(end);
plot(x1(maxDDIdx2), y1(maxDDIdx2), 'r', 'LineWidth', 1.5)

% Annotate the equity curve.
legend({'Equity curve', 'Maximum drawdown range'}, 'Location', 'NW')
grid
xlabel('Date')
ylabel('Profit/Loss ($)')
title('Backtest Results')
datetick('x','mmm dd, yyyy')

%% Display the various risk metrics in a graphical table on the risk chart.
% Max. drawdown loss is based on initial cash
riskMetrics = [pnl; 100 * percentPnl; 100 * annualizedpnl; 100*maxDD; ...
               maxDD * initialCash; sharpeRatio];
names = {'P&L ($)'; 'P&L (%)'; 'Annualized P&L (% per annum)'; 
        'Max. drawdown (%)';'Max. drawdown loss ($)'; 'Sharpe ratio'};
displayData = [names, cellstr(num2str(riskMetrics, '%.2f'))];     
uitable('Parent', backtestFig, ...
        'Units', 'Normalized', ...
        'Position', [0.65, 0.5, 0.24, 0.23], ...
        'Data', displayData, ...
        'RowName', {}, ...
        'ColumnName', {'Risk Metric', 'Value'}, ...
        'ColumnWidth', {165, 60});     