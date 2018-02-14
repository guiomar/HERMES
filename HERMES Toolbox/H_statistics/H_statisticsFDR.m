function statistics = H_statisticsFDR ( set1, set2, config, fix, waitbar )

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

% Initializes the output.
statistics = [];

% Updates the waitbar.
waitbar.title    = 'HERMES - FDR statistics';
waitbar.message  = 'Calculating statistics';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];

waitbar = H_waitbar ( waitbar );

% Reserves memory for the p-values.
pvalues = zeros ( H_size ( set1, [ 2 inf ] ) );

% Throttled variables.
tinv    = 0.2;
tic;

% Sets the flag for paired comparison.
paired = strcmp ( fix, 'Group' );

% Calculates the statistics with the selected configuration.
switch config.test
    
    % Calculates the t-test.
    case 'ttest'
        
        if paired, pvalues = myttest  ( set1, set2 );
        else       pvalues = myttest2 ( set1, set2 );
        end
        
    % Calculates to Wilcoxon test.
    case 'wilcoxon'
        
        if paired, pvalues = mysignrank ( set1, set2, waitbar );
        else       pvalues = myranksum  ( set1, set2, waitbar );
        end
        
    % Calculates to KKW for two groups.
    case 'kkw'
        
        % Sets the configuration.
        sets    = [ set1; set2 ];
        groups  = [ ones( size ( set1, 1 ), 1 ); 2 * ones( size ( set2, 1 ), 1 ) ];
        
        if paired, return
        else       pvalues = mykkw ( sets, groups, waitbar );
        end
end

% Checks for user cancelation.
if ( H_stop ), return, end

% Updates the waitbar.
waitbar.title    = 'HERMES - FDR statistics';
waitbar.message  = 'Calculating FDR from the statistics';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];
waitbar          = H_waitbar ( waitbar );

% Reserves memory for the FDR values.
values = zeros ( size ( pvalues ) );

% Goes trhough every comparision.
for comparision = 1: size ( pvalues ( :, :, : ), 3 )
    
    % Gets the upper diagonal for the comparision.
    subset = false ( size ( pvalues ) );
    subset ( :, :, comparision ) = triu ( true ( H_size ( pvalues, [ 1 2 ] ) ), 1 );
    
    % Calculates the FDR values.
    values ( subset ) = fdr2 ( pvalues ( subset ), config.FDRq, config.FDRtype, 0 );
    
    % Throttled check.
    if toc > tinv
    
        % Checks for user cancelation.
        if ( H_stop ), return, end
        
        % Updates the waitbar.
        waitbar.progress (1) = comparision;
        waitbar.progress (2) = size ( set1 ( :, :, :, : ), 4 );
        waitbar              = H_waitbar ( waitbar );
        
        tic
    end
end

% Completes the matrixes.
values = values + permute ( values, [ 2 1 3: ndims( values ) ] );

% Sets the information for the two clusters.
statistics (1).label   = 'Set 1 > Set 2';
statistics (1).cluster = values & shiftdim ( mean ( set1, 1 ) > mean ( set2, 1 ) );
statistics (1).pvalue  = 0;

statistics (2).label   = 'Set 2 > Set 1';
statistics (2).cluster = values & shiftdim ( mean ( set1, 1 ) < mean ( set2, 1 ) );
statistics (2).pvalue  = 0;

% Deletes the clusters with no significant values.
if ~any ( statistics (2).cluster ), statistics (2) = []; end
if ~any ( statistics (1).cluster ), statistics (1) = []; end

% Deletes the waitbar.
delete ( waitbar.handle );
