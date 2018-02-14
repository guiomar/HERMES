% COMPUTE_LAGARRAY
% Computes a lag-array from a lag set.
%
% L = compute_lagarray(lagSet)
%
% where
%
% LAGSET is an arbitrary dimensional cell-array
% containing either real arrays or scalars.
% All the real arrays that are not scalars must
% have the same number M of elements. The LAGSET
% is treated by its linearization, as are the
% contained arrays. The scalars will be extended
% to arrays of the size M with the same scalar
% in all elements.
%
% L is a 2-dimensional real array, where L(i, :)
% contains M lags corresponding to LAGSET(i).

% Description: Computes a lag-array from a lag set
% Documentation: tim_matlab_impl.txt

function L = compute_lagarray(lagSet)

lagArrays = numel(lagSet);

% Check for errors and find out the
% maximum number of lags L.

lags = 1;
for i = 1 : lagArrays
    if ~isnumeric(lagSet{i})
        error('The members of LAGSET must be numeric arrays.');
    end
    iLags = numel(lagSet{i});
    if iLags > lags
        if lags > 1
            error(['The members of LAGSET must be either scalars ', ...
                'or arrays with the same number of elements.']);
        end
        lags = iLags;
    end
end

% Expand scalars to arrays of length L.

newLagSet = lagSet;

for i = 1 : lagArrays
    if numel(lagSet{i}) == 1
        newLagSet{i} = ones(1, lags) * lagSet{i};
    else
        newLagSet{i} = lagSet{i}(:)';
    end
end

% Form a numeric array from the cell-array.

L = cell2mat(newLagSet');
