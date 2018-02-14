function pvalues = mykkw ( sets, groups, waitbar )

% =========================================================================
%
% This function is part of the HERMES toolbox:
% http://hermes.ctb.upm.es/
% 
% Copyright (c)2010-2015 Universidad Politecnica de Madrid, Spain
% HERMES is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% HERMES is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details. You should have received 
% a copy of the GNU General Public License % along with HERMES. If not, 
% see <http://www.gnu.org/licenses/>.
% 
%
% ** Please cite: 
% Niso G, Bruna R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, Ricardo Bruna, 2012
%

% Gets the mirrored matrices.
mirs = permute ( sets, [ 1 3 2 4 5 ] );
symm = all ( sets (:) == mirs (:) );

% If the matrices are symmetrical checks only the upper triangular.
if symm
    template    = triu   ( true ( H_size ( sets, [ 2 3 ] ) ), 1 );
    triangular  = repmat ( template, H_size ( sets, [ 0 0 4 inf ] ) );
    comparisons = find ( triangular );
    
% Otherwise checks the whole matrix.
else
    comparisons = 1: prod ( H_size ( sets, [ 2 inf ] ) );
end

% Throttled variables.
tinv = 0.2;
tic;

% Reserves memory for the output data.
pvalues = zeros ( H_size ( sets, [ 2 inf ] ) );

% Goes through all the comparisons.
for comparison = 1: numel ( comparisons )
    
    % Calculates the p-value associated to this comparison.
    pvalues ( comparisons ( comparison ) ) = kruskalwallis ( sets ( :, comparisons ( comparison ) ), groups, 'off' );
    
    % Throttled check.
    if toc > tinv
        
        % Checks for user cancelation.
        if ( H_stop ), return, end
        
        % Updates the waitbar.
        if nargin == 3
            waitbar.progress (1) = comparison;
            waitbar.progress (2) = numel ( comparisons );
            waitbar = H_waitbar ( waitbar );
        end
        
        tic
    end
end

% If the matrices are symmetrical fills the lower triangular.
if symm
    pvalues = pvalues + permute ( pvalues, [ 2 1 3: ndims( pvalues ) ] );
    pvalues = pvalues + ( triangular + permute ( triangular, [ 2 1 3: ndims( triangular ) ] ) == 0 );
end
