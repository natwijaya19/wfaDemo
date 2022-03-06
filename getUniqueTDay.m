function uniqueTDay = getUniqueTDay(startDate,endDate)
% getUniqueTDay will find all unique trading days witin startDate and 
% endDate of all underlying assets combined and return in a vector of date
% in datenum format
% Requires:         N/A
% Called from:      setParam.m, runIST.m, runOST.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Initial setup
global nU tDay
uniqueTDay =[];

%% Find unique trading day
for i = 1:nU
    % get all trading day based of underlying i
    tDay2 = tDay{i}; 
    
    % get the index of trading day within startDate and endDate
    idx = (tDay2 >= startDate) & (tDay2 <= endDate); 
    tDayRange = tDay2(idx);
    
    % If unique trading day is empty, then set the unique tDayRange.
    % Otherwise, add new trading day in and find unique trading day
    if isempty(uniqueTDay)
        uniqueTDay = tDayRange;
    else
        uniqueTDay = unique([uniqueTDay;tDayRange]);
    end
end
end

