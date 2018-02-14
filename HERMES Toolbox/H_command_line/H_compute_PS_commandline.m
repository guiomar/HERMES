function indexes = H_compute_PS_commandline ( project, config )
% H_COMPUTE_PS_COMMANDLINE:
% indexes = H_compute_PS_commandline ( data, config )
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
% Specific parameter for some PS metrics
% config.bandcenter
% config.bandwidth
% config.fs
% config.method
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

% FOR CM necessary data: Nsamples x Nchannels x Ntrials !!
data = permute(data, [2 1 3]);

% Creates the flag from the number of trials.
config.trials = size(data,3) >= 8;


% Configures the waitbar
waitbar.title    = 'HERMES - Phase Synchronization measures';
waitbar.message  = 'Calculating indexes.';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];
waitbar.handle   = [];
waitbar.state.progress = 0;
waitbar.state.message  = waitbar.message;
waitbar.state.title    = waitbar.title;

% Creates the waitbar
waitbar = H_waitbar ( waitbar );

indexes = {}; 

% Fetchs option data
PLV_on  = H_check( config.measures, 'PLV'  );
PLI_on  = H_check( config.measures, 'PLI'  );
wPLI_on = H_check( config.measures, 'wPLI' );
RHO_on  = H_check( config.measures, 'RHO'  );
DPI_on  = H_check( config.measures, 'DPI'  );

% Stores parameters, configuration and metadata in the indexes structure.
for index = config.measures
    switch index{ 1 }
        case 'PLV',  name = 'Phase-Locking Value (PLV)';
        case 'PLI',  name = 'Phase-Lag Index (PLI)';
        case 'wPLI', name = 'Weighted Phase-Lag Index (wPLI)';
        case 'RHO',  name = 'Rho index (RHO)';
        case 'DPI',  name = 'Phase Directionality Index (DPI)';
        otherwise, continue
    end
    
    indexes.( index{ 1 } ).type       = 'Phase Synchronization index';
    indexes.( index{ 1 } ).name       = name;
    indexes.( index{ 1 } ).dimensions = H_dimensions( index{ 1 }, config, project );
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
if PLV_on,  indexes.PLV.data  = cell( numel( project.conditions ), numel( project.subjects ) ); end
if PLI_on,  indexes.PLI.data  = cell( numel( project.conditions ), numel( project.subjects ) ); end
if wPLI_on, indexes.wPLI.data = cell( numel( project.conditions ), numel( project.subjects ) ); end
if RHO_on,  indexes.RHO.data  = cell( numel( project.conditions ), numel( project.subjects ) ); end
if DPI_on,  indexes.DPI.data  = cell( numel( project.conditions ), numel( project.subjects ) ); end

% Throttled user cancelation check vars
tinv = 0.2;
tic;

% Goes through all subjects and conditions.
for subject = 1: numel( project.subjects )
    for condition = 1: numel( project.conditions )
        
        % Configures the waitbar.
        waitbar.progress( 1: 2 ) = [ subject numel( project.subjects ) ];
        waitbar.progress( 3: 4 ) = [ condition numel( project.conditions ) ];
                
        % Calculates the indexes.
        output = H_methods_PS( data, config, waitbar );
        
        % Checks for user cancelation (Throttled)
%         if toc > tinv,
%             if ( H_stop ), return, end
%             tic;
%         end
        
        % Stores the indexes in the output structure.
        if PLV_on,  indexes.PLV.data  { condition, subject } = output.PLV.data;  end
        if PLI_on,  indexes.PLI.data  { condition, subject } = output.PLI.data;  end
        if wPLI_on, indexes.wPLI.data { condition, subject } = output.wPLI.data; end
        if RHO_on,  indexes.RHO.data  { condition, subject } = output.RHO.data;  end
        if DPI_on,  indexes.DPI.data  { condition, subject } = output.DPI.data;  end
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
    if PLV_on,  indexes.PLV.pval  = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if PLI_on,  indexes.PLI.pval  = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if wPLI_on, indexes.wPLI.pval = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if RHO_on,  indexes.RHO.pval  = cell( numel( project.conditions ), numel( project.subjects ) ); end
    if DPI_on,  indexes.DPI.pval  = cell( numel( project.conditions ), numel( project.subjects ) ); end
    
    % Applies permutation statistics to discard random interactions.
    for subject = 1: numel( project.subjects )
        for condition = 1: numel( project.conditions )
            
            % Configures the waitbar.
            waitbar.progress( 1: 2 ) = [ subject numel( project.subjects ) ];
            waitbar.progress( 3: 4 ) = [ condition numel( project.conditions ) ];
            
            % Reserves memory for the indexes.
            if PLV_on,  surrogates.PLV  = zeros( size( indexes.PLV.data  { condition, subject } ) ); end
            if PLI_on,  surrogates.PLI  = zeros( size( indexes.PLI.data  { condition, subject } ) ); end
            if wPLI_on, surrogates.wPLI = zeros( size( indexes.wPLI.data { condition, subject } ) ); end
            if RHO_on,  surrogates.RHO  = zeros( size( indexes.RHO.data  { condition, subject } ) ); end
            if DPI_on,  surrogates.DPI  = zeros( size( indexes.DPI.data  { condition, subject } ) ); end
            
            % Performs n iterations.
            for iteration = 1: config.surrogates
                
                % Calculates the indexes of the surrogated data.
                surrogate = H_methods_PS( H_surrogate( data ), config );
                
                % Checks for user cancelation (Throttled)
%                 if toc > tinv,
%                     if ( H_stop ), return, end
%                     tic
%                 end
                
                % Stores a 1 if the value is lower than the index.
                if PLV_on,  surrogates.PLV  = surrogates.PLV  + ( surrogate.PLV.data  > indexes.PLV.data  { condition, subject } ); end
                if PLI_on,  surrogates.PLI  = surrogates.PLI  + ( surrogate.PLI.data  > indexes.PLI.data  { condition, subject } ); end
                if wPLI_on, surrogates.wPLI = surrogates.wPLI + ( surrogate.wPLI.data > indexes.wPLI.data { condition, subject } ); end
                if RHO_on,  surrogates.RHO  = surrogates.RHO  + ( surrogate.RHO.data  > indexes.RHO.data  { condition, subject } ); end
                if DPI_on,  surrogates.DPI  = surrogates.DPI  + ( surrogate.DPI.data  > indexes.DPI.data  { condition, subject } ); end
                
                % Updates the waitbar.
                waitbar.progress( 5: 6 ) = [ iteration config.surrogates ];
                waitbar = H_waitbar( waitbar );
            end
            
            % Gets the p-value by dividing by the number of iterations.
            if PLV_on,  indexes.PLV.pval  { condition, subject } = surrogates.PLV  / ( config.surrogates + 1 ); end
            if PLI_on,  indexes.PLI.pval  { condition, subject } = surrogates.PLI  / ( config.surrogates + 1 ); end
            if wPLI_on, indexes.wPLI.pval { condition, subject } = surrogates.wPLI / ( config.surrogates + 1 ); end
            if RHO_on,  indexes.RHO.pval  { condition, subject } = surrogates.RHO  / ( config.surrogates + 1 ); end
            if DPI_on,  indexes.DPI.pval  { condition, subject } = surrogates.DPI  / ( config.surrogates + 1 ); end
        end
    end
end

% Checks for user cancelation (Throttled)
% if toc > tinv,
%     if ( H_stop ), return, end
% end

delete( waitbar.handle );
waitbar.handle = [];
