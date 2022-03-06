%% Set underlying asset
% This file performs the setup of underlying assets and thier dimensions
% Requires:         N/A
% Called from:      setParam.m
% Copyright 2016 - 2017 The MathWorks, Inc.

%% For pair trading strategy, u is set as an n-by-2 cell array
u = {'FANG','SYNA';'PXD','MTDR';'ADBE','CRM';'BHP','AMZN'};

% Check dimension of u
[nRowU, nColU] = size(u); 

% Number of assets
nU = nRowU*nColU; 