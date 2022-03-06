%% Set the initial status of parameters
% This file initializes the status of varoables
% Requires:         N/A
% Called from:      setParam.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Initialize portfolio, transaction and P&L table
P =[];
T =[];
TOut =[];
TClose =[]; 
pnlTable = [];

%% Initialize graphic parameters
g = line;
h = line('LineStyle','none','Marker','o','MarkerFaceColor','b');
x1 = [];
y1 = [];
x2 = [];
y2 = [];