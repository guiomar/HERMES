% TRANSFER_ENTROPY_PT
% A temporal partial transfer entropy estimate from samples.
%
% I = transfer_entropy_pt(X, Y, Z, W, timeWindowRadius)
% I = transfer_entropy_pt(X, Y, Z, W, timeWindowRadius, 'key', value, ...)
%
% where
%
% X, Y, Z, and W are signal sets.
%
% TIMEWINDOWRADIUS is an odd positive integer, which denotes 
% the radius of the temporal window.
%
% I is the estimated temporal partial transfer entropy.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG, YLAG, ZLAG, and WLAG ('xLag', 'yLag', 'zLag', 'wLag') 
% are integers which denote the amount of lag to apply to signals 
% X, Y, Z, and W, respectively. Default 0.
%
% K ('k') is an integer which denotes the number of nearest 
% neighbors to be used by the estimator. Default 1.
%
% FILTER ('filter') is a real array, which gives the temporal 
% weighting coefficients. Default 1.
%
% Type 'help tim' for more documentation.

% Description: Temporal partial transfer entropy estimation
% Documentation: transfer_entropy.txt

function I = transfer_entropy_pt(...
    X, Y, Z, W, timeWindowRadius, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 5);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments
k = 1;
xLag = 0;
yLag = 0;
zLag = 0;
wLag = 0;
filter = 1;
eval(process_options(...
    {'k', 'xLag', 'yLag', 'zLag', 'wLag', 'filter'}, varargin));

if isnumeric(X)
    X = {X};
end

if isnumeric(Y)
    Y = {Y};
end

if isnumeric(Z)
    Z = {Z};
end

if isnumeric(W)
    W = {W};
end

if ~iscell(X) || ~iscell(Y) || ~iscell(Z) || ~iscell(W)
    error('X, Y, Z, or W is not a cell-array.');
end

if numel(X) ~= numel(Y) || numel(X) ~= numel(Z) || ...
    numel(X) ~= numel(W)
    error('The number of trials in X, Y, Z, and W differ.');
end

% Pass parameter error checking to entropy_combination.

I = entropy_combination_t(...
    [W(:)'; X(:)'; Z(:)'; Y(:)'], ...
    [1, 3, 1; 2, 4, 1; 2, 3, -1], ...
    timeWindowRadius, ...
    'lagSet', {wLag, xLag, zLag, yLag}, ...
    'k', k, ...
    'filter', filter);
