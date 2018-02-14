% TRANSFER_ENTROPY 
% A transfer entropy estimate from samples.
%
% I = transfer_entropy(X, Y, W)
% I = transfer_entropy(X, Y, W, 'key', value, ...)
%
% where
%
% X, Y, and W are signal sets.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG, YLAG, and WLAG ('xLag', 'yLag', 'wLag') are integers which
% denote the amount of lag to apply to signal X, Y, and Z,
% respectively. Default 0.
%
% K ('k') is an integer which denotes the number of nearest 
% neighbors to be used by the estimator. Default 1.
%
% Type 'help tim' for more documentation.

% Description: Transfer entropy estimation
% Documentation: transfer_entropy.txt

function I = transfer_entropy(X, Y, W, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 3);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments.
xLag = 0;
yLag = 0;
wLag = 0;
k = 1;
eval(process_options({'k', 'xLag', 'yLag', 'wLag'}, varargin));

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

% Pass parameter error checking to entropy_combination.

I = entropy_combination(...
    [W(:)'; X(:)'; Y(:)'], ...
    [1, 2, 1; 2, 3, 1; 2, 2, -1], ...
    'lagSet', {wLag, xLag, yLag}, ...
    'k', k);
