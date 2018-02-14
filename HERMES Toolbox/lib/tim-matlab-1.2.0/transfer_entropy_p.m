% TRANSFER_ENTROPY_P
% A partial transfer entropy estimate from samples.
%
% I = transfer_entropy_p(X, Y, Z, W)
% I = transfer_entropy_p(X, Y, Z, W, 'key', value, ...)
%
% where
%
% X, Y, Z, and W are signal sets.
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
% Type 'help tim' for more documentation.

% Description: Partial transfer entropy estimation
% Documentation: transfer_entropy.txt

function I = transfer_entropy_p(X, Y, Z, W, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 4);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments
k = 1;
xLag = 0;
yLag = 0;
zLag = 0;
wLag = 0;
eval(process_options(...
    {'k', 'xLag', 'yLag', 'zLag', 'wLag'}, varargin));

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

I = entropy_combination(...
    [W(:)'; X(:)'; Z(:)'; Y(:)'], ...
    [1, 3, 1; 2, 4, 1; 2, 3, -1], ...
    'lagSet', {wLag, xLag, zLag, yLag}, ...
    'k', k);
