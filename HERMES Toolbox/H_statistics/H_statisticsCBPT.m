function  statistics = H_statisticsCBPT ( set1, set2, config, fix, positions, waitbar )

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
% Niso G, Bruna R, Pereda E, Guti�rrez R, Bajo R., Maest� F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, Ricardo Gutierrez, 2010
% 	    Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Gutierrez, 2013
%

% Initializes the output.
statistics = [];

% Updates the waitbar.
waitbar.title    = 'HERMES - Non Parametric CBPT statistics';
waitbar.message  = 'Calculating statistics...';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];

waitbar = H_waitbar ( waitbar );

% Joins the subjects (or conditions) in an unique matrix.
set = [ set1; set2 ];

% Gets the set sizes.
dim1 = size ( set1, 1 );
dim2 = size ( set2, 1 );

% Limits the iterations to the total avaliable combinations.
if strcmp ( fix, 'Group' ) && pow2 ( dim1 ) < config.Nperm
    
    % For conditions, the maximum number of combinations is 2 ^ subjects.
    config.Nperm = pow2 ( dim1 ) - 1;
end
if strcmp ( fix, 'Condition' ) && nchoosek ( dim1 + dim2, dim1 ) < config.Nperm
    
    % For groups, the maximum number of combinations comes from the binomial coeficent.
    config.Nperm = nchoosek ( dim1 + dim2, dim1 );
end

% Memory reservation.
masses = zeros ( config.Nperm, 1 );
surr1  = zeros ( size ( set1 ) );
surr2  = zeros ( size ( set2 ) );

% Throttled variables.
tinv = 0.2;
tic

% Calculates the distance between nodes.
distances = squareform ( pdist ( positions ) );

% If no 3D positions, promts an error and exits.
if any ( isnan ( distances ) )
    errordlg ( 'Can not perform CBPT without 3D sensors positions.' );
    delete ( waitbar.handle );
    return
end

% Gets the distance threshold from the distance between nodes.
maxdist = config.MaxDist * min ( distances + max ( distances (:) ) * eye ( size ( distances ) ) );

% Calculates the original clusters.
[ clusters, mass ] = find_significant_clusters ( set1, set2, distances, maxdist, config.Nclusters, fix );

% Updates the waitbar.
waitbar.message = 'Calculating permutations...';
waitbar = H_waitbar ( waitbar );

% Create Nperm-1 shuffings, plus the original ordening.
for iteration = 1: config.Nperm

    switch fix
        
        % Comparision between groups.
        case 'Condition'
            
            % Tries all possible permutations
            if config.Nperm == nchoosek ( dim1 + dim2, dim1 )
                sorting = nchooseki ( dim1 + dim2, dim1, iteration );
                
            % Shuffles the subjects.
            else
                sorting = randperm ( dim1 + dim2 ) <= dim1;
            end
            
            % Separates the subjects in two groups of the original size.
            surr1 ( :, : ) = set (  sorting, : ); 
            surr2 ( :, : ) = set ( ~sorting, : ); 
            
        % Pairwise comparision between conditions.
        case 'Group'

            % Tries all possible permutations.
            if config.Nperm == pow2 ( dim1 ) - 1
                sorting = dec2bin ( iteration, dim1 ) == '1';
                
            % Random sorting.
            else
                sorting = rand ( 1, dim1 ) > .5;
            end
            
            % Reorders the conditions for a random set of subjects.
            surr1 (:) = set (  sorting .* ( 1: dim1 ) + ~sorting .* ( dim1 + ( 1: dim2 ) ), : );
            surr2 (:) = set ( ~sorting .* ( 1: dim1 ) +  sorting .* ( dim1 + ( 1: dim2 ) ), : );
    end
    
    % Gets the 'mass' of the first cluster in the surrogate data.
    [ tmp, mass_perm ]     = find_significant_clusters ( surr1, surr2, distances, maxdist, 1, fix ); %#ok<ASGLU>
    masses ( iteration ) = abs ( mass_perm (1) );
    
    
    % Throttled check.
    if toc > tinv
        
        % Checks for user cancelation.
        if ( H_stop ), return, end
        
        % Updates the waitbar.
        waitbar.progress (1) = iteration;
        waitbar.progress (2) = config.Nperm;
        waitbar = H_waitbar ( waitbar );
        
        tic
    end
end

% % Gets the null distribution.
% distribution = sort ( masses, 'descend' );
% 
% % Calculates the threshold according to Nichols & Holmes.
% threshold = distribution ( floor ( config.alpha * config.Nperm ) + 1 );
% 
% % Calculates the p-values for the significant clusters.
% pval ( abs ( mass ) >= threshold ) = sum ( masses ( :, ones ( sum ( abs ( mass ) >= threshold ), 1 ) ) >= abs ( mass ( ones ( config.Nperm, 1 ), abs ( mass ) >= threshold ) ) ) / config.Nperm;
% 
% pval_f     = pval ( pval <= config.alpha );
% mask_sign  = reshape ( repmat ( sign( mass ( pval <= config.alpha ) ), size( clusters ( 1 , : ,:, :, : ) ) ),  size ( clusters ( pval <= config.alpha , : ,:, :, : ) ) );
% clusters_f = clusters ( pval <= config.alpha , : ,:, :, : ) .* mask_sign ;
% 
% if isempty (pval_f)
%     clusters_f = zeros( size( clusters(1,:,:,:,:) ) );
%     pval_f     = 0;
% end

% Calculates the p-value from the null distribution.
pvalues = sum ( repmat ( abs ( mass ), numel ( masses ), 1 ) <= repmat ( masses, 1, numel ( mass ) ), 1 ) / ( config.Nperm + 1 );

% Gets the significant clusters.
significant = pvalues <= config.alpha;

% If no significant clusters, returns an empty cluster.
if ~any ( significant )
    clusters = {};
    pvalues  = {};
    labels   = {};

% Otherwise return only significant clusters
else
    clusters = clusters ( significant, :, :, :, : );
    pvalues  = pvalues  ( significant );
    labels   = cellfun  ( @( num ) sprintf ( 'Cluster %i', num ) , num2cell ( 1: sum ( significant ) ), 'UniformOutput', false );
    
    % Sets the direction.
    mass     = mass     ( significant );
    clusters = clusters .* sign ( repmat ( mass (:), H_size ( clusters, [ 0 2 inf ] ) ) );
    
    % Splits the cluster in a cell string.
    clusters = mat2cell ( clusters, ones ( size ( pvalues ) ) );
    clusters = cellfun  ( @shiftdim, clusters, 'UniformOutput', false );
end

statistics = struct ( 'label', labels (:), 'cluster', clusters (:), 'pvalue', pvalues (:) );

% Deletes the waitbar.
delete ( waitbar.handle );
