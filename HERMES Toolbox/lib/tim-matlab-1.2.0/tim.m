% TIM Matlab interface
% ====================
%
% The functions in TIM Matlab are highly similar. Therefore
% writing separate documentation for each function would be
% redundant and present maintenance issues. To avoid this, we 
% have instead decided to factor those similarities into this 
% generic documentation.
%
% Signals and trials
% ------------------
%
% A _signal_ is a real (m x n)-matrix that contains n samples of an
% m-dimensional signal.
%
% Consider a signal as the result of a single experiment. When making
% such an experiment it is often useful to repeat it many times,
% perhaps to obtain lower variance for the measurement. These
% repetitions are called _trials_. If the different trials are
% comparable to each other, then TIM can make use of them more
% efficiently in the estimations, compared to computing estimates
% for the trials and then combining the results. 
%
% Signal sets 
% -----------
%
% A _signal set_ is an arbitrary-dimensional cell-array whose 
% linearization contains the trials of a signal. A real array is 
% interpreted as a cell-array containing one trial. The estimators 
% take as parameters signal sets rather than single signals.
%
% When an estimator takes as input multiple signal sets, then
% they are required to contain the same number of trials. The 
% dimension of the signals must be equal inside a signal set,
% but need not be equal between signal sets. The number of samples
% may vary from signal to signal even inside a single signal set.
%
% Lags
% ----
%
% The signals can be applied time-delays in the estimators, and the
% amount of this delay is called a _lag_. Each lag can be given 
% either as a scalar or as an array. If a lag is given as an array
% it means that the user wishes to repeat the estimation many times
% with the lag varying as specified in the array. Those functions that
% would output a scalar, then output a column vector, and those functions
% that would output a row vector, then output a matrix. In case some of the 
% lags are given as arrays, those arrays must have the same number of 
% elements, and a scalar lag is interpreted as an array of the same size 
% with the given value as elements. The default for a lag is 0.
%
% Temporal parameters
% -------------------
%
% When using temporal versions of the estimators, the temporal adaptivity
% is obtained by time-windowing the signals. In these estimators, the 
% `timeWindowRadius` parameter determines the radius of the time-window.
%
% Another control on the time-adaptivity is given by the `filter`
% parameter. It is an arbitrary-dimensional real array whose linearization 
% contains the coefficients by which to weight the results in the time-window. 
% The coefficient in the middle of the array corresponds to the current 
% time instant. The size of the array can be arbitrary but must be odd.
% In addition, the coefficients must sum to a non-zero value.
% Default [1].
%
% Other parameters
% ----------------
%
% Many of the estimators are based on k:th nearest neighbors. The
% `k` here can be specified in many of the estimators. The default
% for it is 1.

% Description: TIM Matlab help
% Documentation: tim_matlab_help.txt
