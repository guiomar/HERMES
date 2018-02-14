% MUTUAL_INFORMATION_T
% A temporal mutual information estimate from samples.
%
% I = mutual_information_t(X, Y, timeWindowRadius)
%
% where
%
% X and Y are signal sets.
%
% TIMEWINDOWRADIUS is an integer which determines the temporal radius 
% around each point that will be used by the estimator.
%
% I is the estimated temporal mutual information.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG and YLAG ('xLag', 'yLag') are integers which
% denote the amount of lag to apply to signal X and Y, 
% respectively. Default 0.
%
% K ('k') is an integer which denotes the number of nearest 
% neighbors to be used by the estimator.
%
% FILTER ('filter') is an arbitrary-dimensional real-array, whose
% linearization contains temporal weighting coefficients. 
% Default: 1 (i.e. no temporal weighting is performed)
%
% Type 'help tim' for more documentation.

% Description: Temporal mutual information estimation
% Documentation: mutual_information.txt

function I = mutual_information_t(X, Y, timeWindowRadius, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 3);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments.
xLag = 0;
yLag = 0;
k = 1;
filter = 1;
eval(process_options(...
    {'k', 'xLag', 'yLag', 'filter'}, varargin));

if isnumeric(X)
    X = {X};
end

if isnumeric(Y)
    Y = {Y};
end

if ~iscell(X) || ~iscell(Y)
    error('X or Y is not a cell-array.');
end

if numel(X) ~= numel(Y)
    error('The number of trials in X and Y differ.');
end

% Pass parameter error checking to entropy_combination.

I = entropy_combination_t(...
    [X(:)'; Y(:)'], ...
    [1, 1, 1; 2, 2, 1], timeWindowRadius, ...
    'lagSet', {xLag, yLag}, ...
    'k', k, ...
    'filter', filter);
