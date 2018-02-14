% DIFFERENTIAL_ENTROPY_KL
% A differential entropy estimate from samples
% using Kozachenko-Leonenko nearest neighbor estimator.
%
% H = differential_entropy_kl(S)
% H = differential_entropy_kl(S, 'key', value, ...)
%
% where
%
% S is a signal set.
%
% H is the estimated differential entropy.
%
% Optional input arguments in 'key'-value pairs:
%
% K ('k') is an integer which denotes the number of nearest neighbors 
% to be used by the estimator.
%
% Type 'help tim' for more documentation.

% Description: Differential entropy estimation
% Detail: Kozachenko-Leonenko nearest neighbor estimator
% Documentation: differential_entropy_kl.txt

function H = differential_entropy_kl(S, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 1);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments
k = 1;
eval(process_options({'k'}, varargin));

if isnumeric(S)
    S = {S};
end

% Concept checks
concept_check(S, 'signalSet');
concept_check(k, 'k');

H = tim_matlab('differential_entropy_kl', ...
	S, k);
