function indexes = H_compute_IT_commandline ( project, config )
% H_COMPUTE_IT_COMMANDLINE:
% indexes = H_compute_IT_commandline ( data, config )
%
% data = Nchannels x Nsamples x (Ntrials)
% config.window
% -length (in ms)
% -overlap (in %)
% config.fs (in Hz)
% config.measures (cell: {'COR','COH'})
% config.statistics (0,1)
% config.nSurrogates 
% config.time
%
% Specific parameter for some IT metrics
% config.EmbDim
% config.TimeDelay
% config.Nneighbours
%
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
% Authors:  Guiomar Niso, 2014
%



% Creates project
project.samples     = size(data,2);
project.fs          = config.fs;
project.time        = config.time;
project.conditions  = 1;
project.subjects    = 1;

% FOR IT necessary data: Nsamples x Nchannels x Ntrials !!
data = permute(data, [2 1 3]);

% Creates the flag from the number of trials.
config.trials = size(data,3) >= 8;

% Configures the waitbar.
waitbar.title    = 'HERMES - Information Theory measures';
waitbar.message  = 'Calculating indexes.';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];
waitbar.handle   = [];
waitbar.state.progress = 0;
waitbar.state.message  = waitbar.message;
waitbar.state.title    = waitbar.title;

% Creates the waitbar.
waitbar = H_waitbar( waitbar );

indexes = {}; 

% Stores parameters, configuration and metadata in the indexes structure.
for index = config.measures
    switch index{ 1 }
        case 'MI',   name = 'Mutual Information (MI)';
        case 'TE',   name = 'Transfer Entropy (TE)';
        case 'PMI',  name = 'Partial Mutual Information (PMI)';
        case 'PTE',  name = 'Partial Transfer Entropy (PTE)';
        otherwise, continue
    end
    
    indexes.( index{ 1 } ).type       = 'Information Theory index';
    indexes.( index{ 1 } ).name       = name;
    indexes.( index{ 1 } ).dimensions = H_dimensions ( index{ 1 }, config, project );
    indexes.( index{ 1 } ).date       = clock;
    indexes.( index{ 1 } ).config     = config;
end

% If no index selected, return
if isempty(indexes)
    delete( waitbar.handle );
    waitbar.handle = [];
    return
end

% Reserves memory for the indexes.
if H_check( config.measures, 'MI' ),  indexes.MI.data  = cell( numel( project.conditions ), numel( project.subjects ) ); end
if H_check( config.measures, 'TE' ),  indexes.TE.data  = cell( numel( project.conditions ), numel( project.subjects ) ); end
if H_check( config.measures, 'PMI' ), indexes.PMI.data = cell( numel( project.conditions ), numel( project.subjects ) ); end
if H_check( config.measures, 'PTE' ), indexes.PTE.data = cell( numel( project.conditions ), numel( project.subjects ) ); end

% Goes through all subjects and conditions.
for subject = 1: numel( project.subjects )
    for condition = 1: numel( project.conditions )
        
        % Configures the waitbar.
        waitbar.progress( 1: 2 ) = [ subject numel( project.subjects ) ];
        waitbar.progress( 3: 4 ) = [ condition numel( project.conditions ) ];
        
        % Calculates the indexes.
        output = H_methods_IT( data, config, waitbar );
        
        % Checks for user cancelation.
%         if ( H_stop ), return, end
        
        % Stores the indexes in the output structure.
        if H_check( config.measures, 'MI' ),  indexes.MI.data  { condition, subject} = output.MI.data;   end
        if H_check( config.measures, 'TE' ),  indexes.TE.data  { condition, subject} = output.TE.data;   end
        if H_check( config.measures, 'PMI' ), indexes.PMI.data { condition, subject} = output.PMI.data;  end
        if H_check( config.measures, 'PTE' ), indexes.PTE.data { condition, subject} = output.PTE.data;  end
   end
end

% Calculates permutation statistics.
if config.statistics
    
    % Configures the waitbar.
    waitbar.tic      = clock;
    waitbar.message  = 'Calculating permutation statistics (this could take a while).';
    waitbar.progress = [ 0 1 ];
    waitbar = H_waitbar ( waitbar );
    
    % Reserves memory for the statistics.
    if H_check( config.measures, 'TE' ),  indexes.TE.pval  = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if H_check( config.measures, 'MI' ),  indexes.MI.pval  = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if H_check( config.measures, 'PTE' ), indexes.PTE.pval = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if H_check( config.measures, 'PMI' ), indexes.PMI.pval = cell( numel( project.conditions ), numel( project.subjects ) ); end
    
    % Applies permutation statistics to discard random interactions.
    for subject = 1: numel ( project.subjects )
        for condition = 1: numel ( project.conditions )
            
            % Configures the waitbar.
            waitbar.progress( 1: 2 ) = [ subject numel( project.subjects ) ];
            waitbar.progress( 3: 4 ) = [ condition numel( project.conditions ) ];
            
            % Reserves memory for the indexes.
            if H_check( config.measures, 'MI' ),  surrogates.MI  = zeros( size( indexes.MI.data  { condition, subject } ) ); end
            if H_check( config.measures, 'TE' ),  surrogates.TE  = zeros( size( indexes.TE.data  { condition, subject } ) ); end
            if H_check( config.measures, 'PMI' ), surrogates.PMI = zeros( size( indexes.PMI.data { condition, subject } ) ); end
            if H_check( config.measures, 'PTE' ), surrogates.PTE = zeros( size( indexes.PTE.data { condition, subject } ) ); end
            
            % Performs n iterations.
            for iteration = 1: config.surrogates
                
                % Calculates the indexes of the surrogated data.
                surrogate = H_methods_IT ( H_surrogate ( data ), config );
                
                % Checks for user cancelation.
%                 if ( H_stop ), return, end
                
                % Stores a 1 if the value is lower than the index.
                if H_check( config.measures, 'MI' ),  surrogates.MI  = surrogates.MI  + ( surrogate.MI.data  > indexes.MI.data  { condition, subject } ); end
                if H_check( config.measures, 'TE' ),  surrogates.TE  = surrogates.TE  + ( surrogate.TE.data  > indexes.TE.data  { condition, subject } ); end
                if H_check( config.measures, 'PMI' ), surrogates.PMI = surrogates.PMI + ( surrogate.PMI.data > indexes.PMI.data { condition, subject } ); end
                if H_check( config.measures, 'PTE' ), surrogates.PTE = surrogates.PTE + ( surrogate.PTE.data > indexes.PTE.data { condition, subject } ); end
                
                % Updates the waitbar.
                waitbar.progress ( 5: 6 ) = [ iteration config.surrogates ];
                waitbar = H_waitbar ( waitbar );
            end
            
            % Gets the p-value by dividing by the number of iterations.
            if H_check( config.measures, 'MI' ),  indexes.MI.pval  { condition, subject } = surrogates.MI  / ( config.surrogates + 1 ); end
            if H_check( config.measures, 'TE' ),  indexes.TE.pval  { condition, subject } = surrogates.TE  / ( config.surrogates + 1 ); end
            if H_check( config.measures, 'PMI' ), indexes.PMI.pval { condition, subject } = surrogates.PMI / ( config.surrogates + 1 ); end
            if H_check( config.measures, 'PTE' ), indexes.PTE.pval { condition, subject } = surrogates.PTE / ( config.surrogates + 1 ); end
        end
    end
end

% Checks for user cancelation.
% if ( H_stop ), return, end

delete( waitbar.handle );
waitbar.handle = [];
