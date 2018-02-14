% MUTUAL_INFORMATION_P
% A partial mutual information estimate from samples.
%
% I = mutual_information_p(X, Y, Z)
% I = mutual_information_p(X, Y, Z, 'key', value, ...)
%
% where
%
% X, Y, and Z are signal sets.
%
% I is the estimated partial mutual information.
%
% Optional input arguments in 'key'-value pairs:
%
% XLAG, YLAG, and ZLAG ('xLag', 'yLag', 'zLag') are integers which
% denote the amount of lag to apply to signal X, Y, and Z, 
% respectively. Default 0.
%
% Type 'help tim' for more documentation.

% Description: Partial mutual information estimation
% Documentation: mutual_information.txt

function I = mutual_information_p(...
    X, Y, Z, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 3);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments.
k = 1;
xLag = 0;
yLag = 0;
zLag = 0;
eval(process_options({'k', 'xLag', 'yLag', 'zLag'}, varargin));

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

I = entropy_combination(...
    [X(:)'; Z(:)'; Y(:)'], ...
    [1, 2, 1; 2, 3, 1; 2, 2, -1], ...
    'lagSet', {xLag, zLag, yLag}, ...
    'k', k);
