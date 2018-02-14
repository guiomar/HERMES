% PERMUTE_PSET 
% Permute trials from a pointset object. 
%
% y = permute_pset(x, pindex, n)
%
% where
%
% X is a 2-dimensional cell-array of signals, where the
% element (i, j) contains the j:th trial of the i:th signal.
%
% N is the number of random permutations to generate.
%
% PINDEX is a vector having as many elements as rows has X and that
% determines whether certain time-series (rows of x) have to be treated as
% a single entity when performing the permutations. For instance, a PINDEX = [1 1 2 1]
% means that in a permuted version of the original pointset, the first,
% second and fourth time-series have to correspond to the same trial while the
% third row should correspond to a different trial. 
%
% Y is a cell-array of permuted pointsets. 

% Description: Random permutations of a pointset
% Documentation: tim_matlab_impl.txt
% Author: German Gomez-Herrero

function y = permute_pset(x, I, nc)

if nargin < 3 || isempty(nc)
	% number of permuted psets to return!
	nc = 1; 
end 

ntrials = size(x, 2);
ndim = size(x, 1);

if nargin < 2 || isempty(I),
    I = 1:ndim;
end

uI = unique(I);
if length(uI) < 2,
    return;
end

k = length(uI);
ncmax = factorial(ntrials) / (factorial(k) * factorial(ntrials - k));

if isnan(ncmax)
	ncmax = Inf; 
end

if nc > ncmax,
    error('(permutepset) At most %d permuted psets can be generated.',ncmax);
end

trialperms = zeros(ntrials,ntrials);
trialperms(1,:) = 1:ntrials;
for i = 2:ntrials
    trialperms(i, :) = circshift(trialperms(i - 1, :)', 1)';
end

% possible combinations of rows
irow = nchoosek(1 : ntrials,k);

y = cell(nc, 1);
for j = 1 : nc
    yin = x;
    for i = 1 : length(uI)         
        yin(I==uI(i),:) = x(I==uI(i),trialperms(irow(j,i),:));
    end
    y{j} = yin;
end

if nc < ncmax,
    y = y(randperm(nc));
end

if length(y) < 2
	y = y{1}; 
end