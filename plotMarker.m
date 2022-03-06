% Plot Marker on P&L at the end of each period
% Called from:      runOST.m
% Copyright 2016 - 2017 The MathWorks, Inc.

global  h x2 y2
x2 = [x2 dateI];
y2 = [y2 pnl];
h.XData = x2;
h.YData = y2;
datetick('x','mmm dd, yyyy')
drawnow