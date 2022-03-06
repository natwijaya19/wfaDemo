function periodTable = calcPeriod(startdate1,enddate1,Nperiod)
% calcPeriod will divide the global testing period into multiple periods
% Nperiod is the number of period that we want to divide.
% Requires:         N/A
% Called from:      runWFA1.m, runWFA2.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% Find the day per period (unrounded)
% Convert dates to datenum
startdate1 = datenum(startdate1); 
enddate1 = datenum(enddate1);

% Find number of calendar days per one period
dayperperiod = (enddate1 - startdate1 +1)/Nperiod; 

%% Calculate start/end date for each period
for i = 1:Nperiod
    % Set start date for each period
    if i == 1 
        startdate(i,1) = startdate1;
    else
        startdate(i,1) = enddate(i-1,1)+1;
    end
    
    % Set end date for each period
    if i == Nperiod 
        enddate(i,1) = enddate1;
    else
        enddate(i,1) = (startdate1-1) + round(dayperperiod*i,0);
    end
end

%% Summazie into period Table
period = [1:Nperiod]';
startdate = datestr(startdate,'yyyy-mm-dd');
enddate = datestr(enddate,'yyyy-mm-dd');
periodTable = table(period, startdate,enddate);
end

