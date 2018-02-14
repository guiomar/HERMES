function indexes = H_compute_GS ( project, config )
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
% Authors:  Guiomar Niso, 2010
%           Guiomar Niso, Ricardo Bruna, 2012
%



% Configures the waitbar.
waitbar          = config.waitbar;
waitbar.title    = 'HERMES - Generalized Synchronization measures';
waitbar.message  = 'Calculating indexes.';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];

waitbar.state.progress = 0;
waitbar.state.message  = waitbar.message;
waitbar.state.title    = waitbar.title;

% Creates the waitbar.
waitbar = H_waitbar ( waitbar );

% Checks the completitude of the configuration structure.
config = config.GS;

if ~isfield ( config, 'measures' ),   config.measures   = {};  end
if ~isfield ( config, 'statistics' ), config.statistics = 0;   end
if ~isfield ( config, 'surrogates' ), config.surrogates = 100; end

% Appends the information of the execution to the project log.
H_log ( project, 'calling', config );

% Stores parameters, configuration and metadata in the indexes structure.
for index = config.measures
    switch index { 1 }
        case 'S',  name = 'S index (S)';
        case 'H',  name = 'H index (H)';
        case 'M',  name = 'M index (M)';
        case 'N',  name = 'N index (N)';
        case 'L',  name = 'L index (L)';
        case 'SL', name = 'Synchronization Likelyhood index (SL)';
        otherwise, continue
    end
    
    indexes.( index { 1 } ).type       = 'Generalized Synchronization index';
    indexes.( index { 1 } ).name       = name;
    indexes.( index { 1 } ).dimensions = H_dimensions ( index { 1 }, config, project );
    indexes.( index { 1 } ).date       = clock;
    indexes.( index { 1 } ).config     = config;
end

% Reserves memory for the indexes.
if H_check ( config.measures, 'S'  ), indexes.S.data  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
if H_check ( config.measures, 'H'  ), indexes.H.data  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
if H_check ( config.measures, 'M'  ), indexes.M.data  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
if H_check ( config.measures, 'N'  ), indexes.N.data  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
if H_check ( config.measures, 'L'  ), indexes.L.data  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
if H_check ( config.measures, 'SL' ), indexes.SL.data = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end

% Goes through all subjects and conditions.
for subject = 1: numel ( project.subjects )
    for condition = 1: numel ( project.conditions )
        
        % Configures the waitbar.
        waitbar.progress ( 1: 2 ) = [ subject numel( project.subjects ) ];
        waitbar.progress ( 3: 4 ) = [ condition numel( project.conditions ) ];
        
        % Loads the subject and condition data.
        data = H_load ( project, subject, condition );
        
        % Calculates the indexes.
        if H_check ( config.measures, { 'S' 'H' 'M' 'N' 'L' } ), outputGS = H_methods_GS ( data, config, waitbar ); end
        if H_check ( config.measures, 'SL' ),                    outputSL = H_methods_SL ( data, config, waitbar ); end
        if ( H_stop ), return, end
        
        % Stores the indexes in the output structure.
        if H_check ( config.measures, 'S'  ), indexes.S.data  { condition, subject } = outputGS.S.data;  end
        if H_check ( config.measures, 'H'  ), indexes.H.data  { condition, subject } = outputGS.H.data;  end
        if H_check ( config.measures, 'M'  ), indexes.M.data  { condition, subject } = outputGS.M.data;  end
        if H_check ( config.measures, 'N'  ), indexes.N.data  { condition, subject } = outputGS.N.data;  end
        if H_check ( config.measures, 'L'  ), indexes.L.data  { condition, subject } = outputGS.L.data;  end
        if H_check ( config.measures, 'SL' ), indexes.SL.data { condition, subject } = outputSL.SL.data; end
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
    if H_check ( config.measures, 'S'  ), indexes.S.pval  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
    if H_check ( config.measures, 'H'  ), indexes.H.pval  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
    if H_check ( config.measures, 'M'  ), indexes.M.pval  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
    if H_check ( config.measures, 'N'  ), indexes.N.pval  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
    if H_check ( config.measures, 'L'  ), indexes.L.pval  = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
    if H_check ( config.measures, 'SL' ), indexes.SL.pval = cell ( numel ( project.conditions ), numel ( project.subjects ) ); end
    
    % Applies permutation statistics to discard random interactions.
    for subject = 1: numel ( project.subjects )
        for condition = 1: numel ( project.conditions )
            
            % Configures the waitbar.
            waitbar.progress ( 1: 2 ) = [ subject numel( project.subjects ) ];
            waitbar.progress ( 3: 4 ) = [ condition numel( project.conditions ) ];
            
            % Loads the subject and condition data.
            data = H_load ( project, subject, condition );
            
            % Reserves memory for the indexes.
            if H_check ( config.measures, 'S'  ), surrogates.S  = zeros ( size ( indexes.S.data  { condition, subject } ) ); end
            if H_check ( config.measures, 'H'  ), surrogates.H  = zeros ( size ( indexes.H.data  { condition, subject } ) ); end
            if H_check ( config.measures, 'M'  ), surrogates.M  = zeros ( size ( indexes.M.data  { condition, subject } ) ); end
            if H_check ( config.measures, 'N'  ), surrogates.N  = zeros ( size ( indexes.N.data  { condition, subject } ) ); end
            if H_check ( config.measures, 'L'  ), surrogates.L  = zeros ( size ( indexes.L.data  { condition, subject } ) ); end
            if H_check ( config.measures, 'SL' ), surrogates.SL = zeros ( size ( indexes.SL.data { condition, subject } ) ); end
            
            % Performs n iterations.
            for iteration = 1: config.surrogates
                
                % Calculates the indexes of the surrogated data.
                if H_check ( config.measures, { 'S' 'H' 'M' 'N' 'L' } ), surrogateGS = H_methods_GS  ( H_surrogate ( data ), config ); end
                if H_check ( config.measures, 'SL' ),                    surrogateSL = H_methods_SL ( H_surrogate ( data ), config ); end
                
                % Checks for user cancelation.
                if ( H_stop ), return, end
                                                
                % Stores a 1 if the value is lower than the index.
                if H_check ( config.measures, 'S'  ), surrogateGS.S  = surrogates.S  + ( surrogateGC.S.data  > indexes.S.data  { condition, subject } ); end
                if H_check ( config.measures, 'H'  ), surrogateGS.H  = surrogates.H  + ( surrogateGC.H.data  > indexes.H.data  { condition, subject } ); end
                if H_check ( config.measures, 'M'  ), surrogateGS.M  = surrogates.M  + ( surrogateGC.M.data  > indexes.M.data  { condition, subject } ); end
                if H_check ( config.measures, 'N'  ), surrogateGS.N  = surrogates.N  + ( surrogateGC.N.data  > indexes.N.data  { condition, subject } ); end
                if H_check ( config.measures, 'L'  ), surrogateGS.L  = surrogates.L  + ( surrogateGC.L.data  > indexes.L.data  { condition, subject } ); end
                if H_check ( config.measures, 'SL' ), surrogateSL.SL = surrogates.SL + ( surrogateSL.SL.data > indexes.SL.data { condition, subject } ); end
        
                % Updates the waitbar.
                waitbar.progress ( 5: 6 ) = [ iteration config.surrogates ];
                waitbar = H_waitbar ( waitbar );
            end
            
            % Gets the p-value by dividing by the number of iterations.
            if H_check ( config.measures, 'S'  ), indexes.S.pval  { condition, subject } = surrogates.S  / ( config.surrogates + 1 ); end
            if H_check ( config.measures, 'H'  ), indexes.H.pval  { condition, subject } = surrogates.H  / ( config.surrogates + 1 ); end
            if H_check ( config.measures, 'M'  ), indexes.M.pval  { condition, subject } = surrogates.M  / ( config.surrogates + 1 ); end
            if H_check ( config.measures, 'N'  ), indexes.N.pval  { condition, subject } = surrogates.N  / ( config.surrogates + 1 ); end
            if H_check ( config.measures, 'L'  ), indexes.L.pval  { condition, subject } = surrogates.L  / ( config.surrogates + 1 ); end
            if H_check ( config.measures, 'SL' ), indexes.SL.pval { condition, subject } = surrogates.SL / ( config.surrogates + 1 ); end
        end
    end
end

% Checks for user cancelation.
if ( H_stop ), return, end

delete ( waitbar.handle );
waitbar.handle = [];

% Appends the information of the successful execution to the project log.
H_log ( project, 'success' );