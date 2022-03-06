% Plot P&L line on each trading day
% Called from:      runOST.m
% Copyright 2016 - 2017 The MathWorks, Inc.

global g  x1 y1  
x1 = [x1; dateI];
y1 = [y1; pnl];
g.XData = x1;
g.YData = y1;
datetick('x','mmm dd, yyyy')
drawnow limitrate