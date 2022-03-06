% Copyright 2017 The MathWorks, Inc.
How to run walk-forward analysis?
 - There are 2 main files: runWFA1.m and runWFA2.m.
 - runWFA1.m find the trading parameter that maximing objective function of underlying together while runWFA2.m independently optimize parameters of each underlying

How to adjust assumptions?
 - SetParam.m
	* Testing period assumptions:
		# globalStart 	= First testing date
		# globalEnd 	= Last testing date
		# Lead 		= Lead time (days) before globalStart to extract data
		# nPeriod 	= number of period to be sliced
		# nISTPeriod 	= number of IST period
 - setParam.m
	* Optimization assumption:
		# paramType 	= objective for optimization
		# param 	= a vector of variable to be optimized
 - setUnderlying.m
	* Universe of assets:
		# u 		= List of underlying assets
 - setCost.m:
	* Transaction cost assumption:
		# slipGlobal	= slippage/market impact
		# tCostGlobal 	= transaction cost per trading value
	* Performance analytic	assumption:
		# initialCash 	= initial investment in cash amount
		# tDayConv	= trading Day Convention
		# riskFree	= risk free rate
