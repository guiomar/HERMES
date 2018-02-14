% DIFFERENTIAL_ENTROPY_KL_T
% A temporal differential entropy estimate from samples
% using Kozachenko-Leonenko nearest neighbor estimator.
%
% H = differential_entropy_kl_t(S, timeWindowRadius)
% H = differential_entropy_kl_t(S, timeWindowRadius, 'key', value, ...)
%
% where
%
% S is a signal set.
%
% TIMEWINDOWRADIUS is an integer which determines the temporal radius 
% around each point that will be used by the estimator.
%
% H is the estimated temporal differential entropy.
%
% Optional input arguments in 'key'-value pairs:
%
% K ('k') is an integer which denotes the number of nearest neighbors 
% to be used by the estimator. Default 1.
%
% FILTER ('filter') is a real array, which gives the temporal 
% weighting coefficients. Default 1.
%
% Type 'help tim' for more documentation.

% Description: Temporal differential entropy estimation
% Detail: Kozachenko-Leonenko nearest neighbor estimator
% Documentation: differential_entropy_kl.txt

function H = differential_entropy_kl_t(...
    S, timeWindowRadius, varargin)

% Package initialization
eval(package_init(mfilename('fullpath')));

concept_check(nargin, 'inputs', 2);
concept_check(nargout, 'outputs', 0 : 1);

% Optional input arguments
k = 1;
filter = 1;
eval(process_options({'k', 'filter'}, varargin));

if isnumeric(S)
    S = {S};
end

concept_check(S, 'signalSet');
concept_check(timeWindowRadius, 'timeWindowRadius');
concept_check(k, 'k');
concept_check(filter, 'filter');

H = tim_matlab('differential_entropy_kl_t', ...
    S, timeWindowRadius, k, filter);
