function [h] = fdr2(p, q, type, nf)

%Input
% - p, vector of p values
% - q, fraction of false positives (on average). This substitites p in
%traditional tests. A q=0.10 is a good starting point.
% - type, 1 or 2, type=2 is more conservative and general and the one used in fieldtrip
% - nf if 1 estimates the null fraction of voxels from p>0.5

% 28 may 2009. Type added, includes less restrictive condition from paper
% below. Angel
% original fdr from fieldtrip


% FDR false discovery rate
%
% Use as
%   h = fdr(p, q)
%
% This implements
%   Genovese CR, Lazar NA, Nichols T.
%   Thresholding of statistical maps in functional neuroimaging using the false discovery rate.
%   Neuroimage. 2002 Apr;15(4):870-8.

% Copyright (C) 2005, Robert Oostenveld
%
% $Log: fdr.m,v $
% Revision 1.2  2006/06/07 12:57:09  roboos
% also support n-D input arrays
%
% Revision 1.1  2005/11/08 16:02:58  roboos
% initial implementation
%

% convert the input into a row vector
dim = size(p);
p = reshape(p, 1, numel(p));
if nf
    null_fraction=numel(find(p>0.5))/(numel(p)*(1-0.5));
end
% sort the observed uncorrected probabilities
[ps, indx] = sort(p);

% count the number of voxels
V = length(p);

% compute the threshold probability for each voxel
if nf
    pi= 1/null_fraction * ((1:V)/V)  * q / c(V,type);
else
    pi = ((1:V)/V)  * q / c(V,type);
end

h = (ps<=pi);

% undo the sorting
[dum, unsort] = sort(indx);
h = h(unsort);

% convert the output back into the original format
h = reshape(h, dim);

function s = c(V,type)
if type==1
    s=1;
else
    % See Genovese, Lazar and Holmes (2002) page 872, second column, first paragraph
    if V<1000
      % compute it exactly
      s = sum(1./(1:V));
    else
      % approximate it
      s = log(V) + 0.57721566490153286060651209008240243104215933593992359880576723488486772677766467093694706329174674951463144724980708248096050401448654283622417399764492353625350033374293733773767394279259525824709491600873520394816567;
    end
end
