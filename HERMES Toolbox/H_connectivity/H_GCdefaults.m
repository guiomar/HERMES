function output = H_GCdefaults ( project, winlength, maxorder )
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
% ** Please cite: ---------------------------------------------------------
% Niso G, Bruña R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%


% Sets the number of vectors to check.
samplesize = 100;

% Sets the cancelation flag to false.
H_stop ( false );

% Cretes and configures the waitbar.
waitbar.start    = clock;
waitbar.progress = [ 0 1 ];
waitbar.handle   = [];
waitbar.title    = 'Set default parameters';
waitbar.message  = sprintf ( 'Selecting %.0f random vectors to check', samplesize );
waitbar.tic      = clock;

waitbar.state.progress = 0;
waitbar.state.message  = '';
waitbar.state.title    = '';

waitbar = H_waitbar ( waitbar );

% Creates an index refering each trial in the data.
trials = cell2mat ( { project.statistical.trials } );
index  = zeros ( sum ( cell2mat ( { project.statistical.trials }' ) ), 3 );

% Throttled variables.
interval_between_checks = 0.1;
tic

for subject = 1: numel ( project.subjects )
    for condition = 1: numel ( project.conditions )
        offset = sum ( sum ( trials ( :, 1: subject - 1 ) ) ) + sum ( trials ( 1: condition - 1, subject ) );
        
        index ( offset + 1: offset + trials ( condition, subject ), 1 ) = subject;
        index ( offset + 1: offset + trials ( condition, subject ), 2 ) = condition;
        index ( offset + 1: offset + trials ( condition, subject ), 3 ) = 1: trials ( condition, subject );
    end
end

% Randomly selects the trials and a channel for each selected trial.
check = index ( randi ( size ( index, 1 ), samplesize, 1 ), : );
check ( :, 4 ) = randi ( project.channels, samplesize, 1 );
check = sortrows ( check );

% Reserves memory for the vectors.
data = zeros ( project.samples, samplesize );

% Gets the files to load.
files = unique ( check ( :, 1: 2 ), 'rows' );

% Loads each file and gets the required vectors.
for file = 1: size ( files, 1 )
    
    % Load the whole data in two dimensions.
    datafile = H_load ( project, files ( file, 1 ), files ( file, 2 ) );
    datasize = [ size( datafile, 2 ) size( datafile, 3 ) ];
    datafile = datafile ( :, : );
    
    % Gets the list of vectors.
    active   = check ( :, 1 ) == files ( file, 1 ) & check ( :, 2 ) == files ( file, 2 );
    vectors  = check ( active, [ 4 3 ] );
    vectors  = sub2ind ( datasize, vectors ( :, 1 ), vectors ( :, 2 ) );
    
    % Selects the data and stores it.
    data ( :, active ) = datafile ( :, vectors );
    
    % Throttled check.
    if toc > interval_between_checks
        tic
        
        % Checks for user cancelation.
        if ( H_stop ), return, end
        
        % Updates the waitbar.
        if ~isempty ( waitbar )
            waitbar.progress ( 1 ) = file;
            waitbar.progress ( 2 ) = size ( files, 1 );
            waitbar                = H_waitbar ( waitbar );
        end
    end
end

% Updates the waitbar.
waitbar.progress = [ 0 1 ];
waitbar.message  = 'Calculating default parameters';
waitbar.tic      = clock;
waitbar          = H_waitbar ( waitbar );

% Gets the order for each vector.
orders = zeros ( samplesize, 1 );
for vector = 1: samplesize
    
    % Gets a random window of the desired length.
    window = ( 1: winlength ) + randi ( size ( data, 1 ) - winlength );
    
    % Calculates the optimal order for the given vector.
    [ bic, aic ] = cca_find_model_order ( data ( window, vector )', 3, maxorder + 1 );
    
    orders ( vector ) = min ( bic, aic );
    
    % Throttled check.
    if toc > interval_between_checks
        tic
        
        % Checks for user cancelation.
        if ( H_stop ), return, end
        
        % Updates the waitbar.
        if ~isempty ( waitbar )
            waitbar.progress ( 1 ) = vector;
            waitbar.progress ( 2 ) = samplesize;
            waitbar                = H_waitbar ( waitbar );
        end
    end
end

% Sets the order as the median of the estimated orders.
output.overflow = sum ( orders == maxorder + 1 ) / samplesize;
output.order    = ceil ( median ( orders ) );

if output.order > maxorder, output.order = maxorder; end

delete ( waitbar.handle );
