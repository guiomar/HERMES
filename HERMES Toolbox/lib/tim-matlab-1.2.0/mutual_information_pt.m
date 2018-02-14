% MUTUAL_INFORMATION_PT
% A temporal partial mutual information estimate from samples.
%
% I = mutual_information_pt(X, Y, Z, timeWindowRadius)
% I = mutual_information_pt(X, Y, Z, timeWindowRadius, 'key', value, ...)
%
% where
%
% X, Y, and Z are signal sets.
%
% TIMEWINDOWRADIUS is an integer which determines the temporal radius 
% around each point that will be used by the estimator.
%
% I is the estimated temporal partial mutual information.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG, YLAG, and ZLAG ('xLag', 'yLag', 'zLag') are integers which
% denote the amount of lag to apply to signal X, Y, and Z, 
% respectively. Default 0.
%
% FILTER ('filter') is an arbitrary-dimensional real-array, whose
% linearization contains temporal weighting coefficients. 
% Default: 1 (i.e. no temporal weighting is performed)
%
% Type 'help tim' for more documentation.

% Description: Temporal partial mutual information estimation
% Documentation: mutual_information.txt

function I = mutual_information_pt(X, Y, Z, timeWindowRadius, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 4);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments.
xLag = 0;
yLag = 0;
zLag = 0;
k = 1;
filter = 1;
eval(process_options(...
    {'k', 'xLag', 'yLag', 'zLag', 'filter'}, varargin));

if isnumeric(X)
    X = {X};
end

if isnumeric(Y)
    Y = {Y};
end

if isnumeric(Z)
    Z = {Z};
end

if ~iscell(X) || ~iscell(Y) || ~iscell(Z)
    error('X, Y, or Z is not a cell-array.');
end

if numel(X) ~= numel(Y) || numel(X) ~= numel(Z)
    error('The number of trials in X, Y, and Z differ.');
end

% Pass parameter error checking to entropy_combination.

I = entropy_combination_t(...
    [X(:)'; Z(:)'; Y(:)'], ...
    [1, 2, 1; 2, 3, 1; 2, 2, -1], timeWindowRadius, ...
    'lagSet', {xLag, zLag, yLag}, ...
    'k', k, ...
    'filter', filter);
