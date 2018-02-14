% PERMUTATION_TEST 
% Use a permutation test to obtain significance thresholds
%
% y = permutation_test(pset, pindex, ifunc, alpha)
%
% where
% 
% PSET is a pointset object, i.e. a N x T cell array containing N
% time-series and T repetitions for each time series. 
%
% PINDEX is a vector of permutation indices. See: help permute_pset.
%
% IFUNC is a function_handle that takes a pointset object as input
% parameter. 
%
% ALPHA is the significance level. Default 0.05.
% 
% For example, to assess the significance threshold for a pointset 
% pset = [X Y Z W] when calculating the temporal partial transfer
% entropy we would do:
%
% ifunc = @(pset) transfer_entropy_pt(pset(1,:), pset(2,:), pset(3,:), ...
%	 pset(4,:), 10);
%
% y = permutation_test(pset, [1 2 1 1], ifunc);
%
% See also: permute_pset

% Description: Permutation test to determine significance threshold
% Documentation: tim_matlab_impl.txt
% Author: German Gomez-Herrero

function y = permutation_test(pset, pindex, ifunc, alpha)

K = 0; % use 1 to increase the number of permutations beyond the minimum 

if nargin < 4 || isempty(alpha)
	alpha = 0.05; 
end

if nargin < 3, 
    error('Not enough input parameters');
end

ns = ceil((1 - alpha) * 10^(-log10(alpha) + K));

if ns > size(pset,2),
    error('%d data trials are needed for alpha=%1.2f.',ns,alpha);
end

psetperm = permute_pset(pset, pindex, ns);

y = [];
fprintf('  Performing %d permutations',ns);

for i = 1:ns
   tmp = ifunc(psetperm{i});
   if isempty(y),
       y = tmp;
   else
       y = max(y, tmp);
   end   
   fprintf('.');
end
fprintf('[done]\n');

