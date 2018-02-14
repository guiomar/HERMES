% TRANSFER_ENTROPY_T
% A temporal transfer entropy estimate from samples.
%
% I = transfer_entropy_t(X, Y, W, timeWindowRadius)
% I = transfer_entropy_t(X, Y, W, timeWindowRadius, 'key', value, ...)
%
% where
%
% X, Y, and W are signal sets.
%
% TIMEWINDOWRADIUS is an integer which determines the temporal radius 
% around each point that will be used by the estimator.
%
% I is the estimated temporal transfer entropy.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG, YLAG, and WLAG ('xLag', 'yLag', 'wLag') 
% are integers which denote the amount of lag to apply to signals 
% X, Y, and W, respectively. Default 0.
%
% K ('k') is an integer which denotes the number of nearest 
% neighbors to be used by the estimator. Default 1.
%
% FILTER ('filter') is a real array, which gives the temporal 
% weighting coefficients. Default 1.
%
% Type 'help tim' for more documentation.

% Description: Temporal transfer entropy estimation
% Documentation: transfer_entropy.txt

function I = transfer_entropy_t(...
    X, Y, W, timeWindowRadius, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 4);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments
k = 1;
xLag = 0;
yLag = 0;
wLag = 0;
filter = 1;
eval(process_options(...
    {'k', 'xLag', 'yLag', 'wLag', 'filter'}, varargin));

if isnumeric(X)
    X = {X};
end

if isnumeric(Y)
    Y = {Y};
end

if isnumeric(W)
    W = {W};
end

if ~iscell(X) || ~iscell(Y) || ~iscell(W)
    error('X, Y, or W is not a cell-array.');
end

if numel(X) ~= numel(Y) || numel(X) ~= numel(W)
    error('The number of trials in X, Y, and W differ.');
end

I = entropy_combination_t(...
    [W(:)'; X(:)'; Y(:)'], ...
    [1, 2, 1; 2, 3, 1; 2, 2, -1], ...
    timeWindowRadius, ...
    'lagSet', {wLag, xLag, yLag}, ...
    'k', k, ...
    'filter', filter);
