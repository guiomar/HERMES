% DIVERGENCE_WKV
% A Kullback-Leibler divergence estimate from samples
% using Wang-Kulkarni-Verdu nearest neighbor estimator.
%
% D = divergence_wkv(X, Y)
%
% where
%
% X and Y are signal sets.
%
% Type 'help tim' for documentation.

% Description: Kullback-Leibler divergence estimation
% Detail: Wang-Kulkarni-Verdu nearest neighbor estimator
% Documentation: divergence_wkv.txt

function D = divergence_wkv(X, Y)

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

concept_check(X, 'signalSet');
concept_check(Y, 'signalSet');

if numel(X) ~= numel(Y)
	error('The number of trials in X and Y do not match.');
end

if size(X{1}, 1) ~= size(Y{1}, 1)
    error('The dimensions of X and Y do not match.');
end

D = tim_matlab('divergence_wkv', ...
	X, Y);

end
