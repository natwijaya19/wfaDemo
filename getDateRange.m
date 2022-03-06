function [extractedDate] = getDateRange(startDate,endDate)
% getDateRange extract the date within the given start date and end date
% from the uniqueTDay (global variable)
% Requires:         N/A
% Called from: 	    setParam.m
% Copyright 2016 - 2017 The MathWorks, Inc.

% Data setup
global uniqueTDay
startDate = datenum(startDate);
endDate = datenum(endDate);

% Convert to datetime format
idx = (uniqueTDay >= startDate) & (uniqueTDay <= endDate);
extractedDate = uniqueTDay(idx);
extractedDate = datetime(extractedDate, 'ConvertFrom', 'datenum');
end