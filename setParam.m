%% Setup files for walk-forward analysis
% This file performs the setup of global parameters, testing periods,
% and other necessary parameters
% Requires:         calcPeriod.m,setUnderlying.m,setCost.m,setInitStatus.m
%                   getPrices.m, getUniqueTDay
% Called from:      runwfa.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Set global parameters and format
clear;
clc;
global u nU Open Close AdjClose tDay g h x1 y1 x2 y2 uniqueTDay 
format bank; % Use banking format for easy visualization of numeric data

%% Set testing period parameters
% global start/end date for WFA
globalStart = datenum('2013-04-01'); 
globalEnd = datenum('2016-06-30'); 

% Set number of days before global start date to extract data
lead = 60; 

% set the number of periods to be sliced
nPeriod = 39; 

% Set the number of IST period. Assume that the number of OST period = 1
nISTPeriod = 3;

% Create testing period table with the equal range based on calendar days
periodTable = calcPeriod(globalStart,globalEnd,nPeriod);

% Calculate number of walk
nWalk = nPeriod - nISTPeriod; 
disp(['Total Walk is ' num2str(nWalk)]);

% Prepare walk-forward period table (wfaPriod)
walk = [1:nWalk]'; 
endISTPeriod = walk + nISTPeriod - 1; 
startIST = datetime(periodTable{walk,2});
endIST = datetime(periodTable{endISTPeriod,3}); 
startOST = datetime(periodTable{endISTPeriod + 1,2}); 
endOST = datetime(periodTable{endISTPeriod + 1,3});
wfaPeriod = table(walk, startIST, endIST, startOST, endOST); 

%% Set other parameters
setUnderlying
setCost

% Set range of parameter to be optimized
param = [20:5:40]; 
nParam = length(param)

% Choose optimization objectibe to maximize (2) P&L  and (3) Sharpe Ratio 
paramType = 3; 

% Retrieve price data for all underlying assets
Open = cell(1,nU);
Close = cell(1,nU);
tDay = cell(1,nU);
for i = 1:nU
    [Open{i}, Close{i},tDay{i}] = getPrices(u{i},globalStart,globalEnd,lead);
end

% Merge into single variable
prices ={tDay, Open, Close}; 

% Find unique trading days for all trading days combined
uniqueTDay = getUniqueTDay(globalStart,globalEnd);

%% Find date vectors for each walk (IST & OST)
for i = 1: nWalk
dateIST{i} = getDateRange(startIST(i),endIST(i));
dateOST{i} = getDateRange(startOST(i),endOST(i));
end

%% Initialize the status of variables
setInitStatus