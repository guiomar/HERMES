% ENTROPY_COMBINATION
% An entropy combination estimate from samples.
%
% I = entropy_combination(signalSet, rangeSet)
% I = entropy_combination(signalSet, rangeSet, 'key', value, ...)
%
% where
%
% SIGNALSET is a 2-dimensional (p x q) cell-array 
% containing q trials of p signals.
%
% RANGESET is a 2-dimensional (m x 3) array which on each row 
% contains an integer triple of the form (a, b, s). Each triple
% denotes the rows (a : b) in SIGNALSET. Those signals are concatenated
% to form a higher-dimensional signal for which differential entropy
% is (implicitly) computed in the entropy combination. The s denotes
% the factor by which the differential entropy is multiplied before
% summing to the end-result.
%
% I is a real (L x 1)-matrix of computed entropy combinations, where L is 
% the number of specified lags. The I(i) corresponds to the entropy
% combination estimate using the lag LAGSET{j}(i) for signal j.
%
% Optional input arguments in 'key'-value pairs:
%
% LAGSET ('lagSet') is an arbitrary-dimensional cell-array whose 
% linearization contains p arrays of lags to apply to each signal. Each 
% array of lags is either a scalar, or has L elements, where L is the 
% maximum number of elements among the arrays in LAGSET. An array of lags
% is handled by its linearization. If an array of lags is a scalar, it is 
% extended to an array with L elements with the scalar as its elements.
% Default: a (p x 1) cell-array of scalar zeros.
%
% K ('k') is an integer which denotes the number of nearest neighbors 
% to be used by the estimator.
%
% Type 'help tim' for more documentation.

% Description: Entropy combination estimation
% Documentation: entropy_combination.txt

function I = entropy_combination(signalSet, rangeSet, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 2);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments.
k = 1;
lagSet = num2cell(zeros(size(signalSet, 1), 1));
eval(process_options({'lagSet', 'k'}, varargin));

concept_check(k, 'k');

signals = size(signalSet, 1);
marginals = size(rangeSet, 1);

for i = 1 : signals
    concept_check(signalSet(i, :), 'signalSet')
end

if marginals == 0
    error('RANGESET is empty.');
end

if size(rangeSet, 2) ~=3
    error('The width of RANGESET must be 3');
end

for i = 1 : marginals
    if rangeSet(i, 1) > rangeSet(i, 2)
        error('For each RANGESET triple (a, b, s) must hold a <= b.');
    end
    if rangeSet(i, 1) < 1
        error('There is a RANGESET triple (a, b, s) with a < 1.');
    end
    if rangeSet(i, 2) > signals
        error('There is a RANGESET triple (a, b, s) with b > signals.');
    end
end

if numel(lagSet) ~= signals
	error(['LAGSET must contain the same number of elements as ', ...
	'there are signals in SIGNALSET.']);
end

lagArray = compute_lagarray(lagSet);

lags = size(lagArray, 2);
I = zeros(lags, 1);

for i = 1 : lags
    I(i) = tim_matlab(...
        'entropy_combination', ...
        signalSet, rangeSet, ...
        lagArray(:, i), k);
end
