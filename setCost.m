%% Set cost and related assumptions
% This file defines the cost-related variables, such as initial cash, 
% risk-free rate, slipage, and transaction cost.
% Requires:         N/A
% Called from:      setParam.m, runIST.m, runOST.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Set trading/transaction costs
% Slipage is 0.2% of trading value
slipGlobal = 0.002; 

% Transaction is 0.1% of trading value
tCostGlobal = 0.001; 

%% Setup performance analytic variables
% Note that initialCash is mainly used for performance analytic and 
% determining the position size. **** Negative cash might occur ***
initialCash = 100000; 
tDayConv = 252; %
riskFree = 0.01/tDayConv;