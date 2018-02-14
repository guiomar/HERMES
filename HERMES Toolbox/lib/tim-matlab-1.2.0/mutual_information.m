% MUTUAL_INFORMATION 
% A mutual information estimate from samples.
%
% I = mutual_information(X, Y)
% I = mutual_information(X, Y, 'key', value, ...)
%
% where
%
% X and Y are signal sets.
%
% I is the estimated mutual information.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG and YLAG ('xLag', 'yLag') are integers which
% denote the amount of lag to apply to signal X and Y, 
% respectively. Default 0.
%
% K ('k') is an integer which denotes the number of nearest 
% neighbors to be used by the estimator. Default 1.
%
% Type 'help tim' for more documentation.

% Description: Mutual information estimation
% Documentation: mutual_information.txt

function I = mutual_information(X, Y, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 2);
concept_check(nargout, 'outputs', 0 : 1);

if isnumeric(X)
    X = {X};
end

if isnumeric(Y)
    Y = {Y};
end

% Optional input arguments.
k = 1;
xLag = 0;
yLag = 0;
eval(process_options({'k', 'xLag', 'yLag'}, varargin));

if ~iscell(X) || ~iscell(Y)
    error('X or Y is not a cell-array.');
end

if numel(X) ~= numel(Y)
    error('The number of trials in X and Y differ.');
end

% Pass parameter error checking to entropy_combination.

I = entropy_combination(...
    [X(:)'; Y(:)'], ...
    [1, 1, 1; 2, 2, 1], ...
    'lagSet', {xLag, yLag}, ...
    'k', k);
