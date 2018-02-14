function statistics = H_statistics ( project, config )

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

% Resets the cancelation variable.
H_stop (0);

% Configures the waitbar.
waitbar.start    = clock;
waitbar.title    = 'HERMES - Statistics';
waitbar.message  = 'Preparing the data';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];
waitbar.handle   = [];

waitbar.state.progress = 0;
waitbar.state.message  = waitbar.message;
waitbar.state.title    = waitbar.title;

waitbar = H_waitbar ( waitbar );

% Prepares the metadata.
statistics.filename    = sprintf ( '%03g.stats', numel ( H_load ( project, 'statistics' ) ) + 1 );
statistics.date        = clock;
statistics.description = sprintf ( 'Statistics calculated on %s at %s', datestr ( statistics.date, 24 ), datestr ( statistics.date, 13 ) );
statistics.info        = [];
statistics.index       = { config.index  };
statistics.method      = { config.method };
statistics.config      = config;

statistics.info.groups     = project.groups;
statistics.info.conditions = project.conditions;

% Loads the calculated index from the selected run.
indexes = H_load ( project, 'indexes', config.run, config.index );

% Stores the indexes metadata in the statistics metadata structure.
statistics.origin = rmfield ( indexes, 'data' );

% Obtains the sets to compare.
switch config.fix
    
    % Gets the data for each condition in the selected group.
    case 'Group'
        set1 = indexes.data ( config.set1,  [ project.statistical.group ] == config.fixed );
        set2 = indexes.data ( config.set2,  [ project.statistical.group ] == config.fixed );
        
    % Gets the data for each group in the selected condition.
    case 'Condition'
        set1 = indexes.data ( config.fixed, [ project.statistical.group ] == config.set1 );
        set2 = indexes.data ( config.fixed, [ project.statistical.group ] == config.set2 );
        
    otherwise
        return
end

% Shifts the sets one dimension up.
set1 = cellfun ( @reshape, set1, repmat ( { H_size( set1 {1}, [ 0 inf ] ) }, size ( set1 ) ), 'UniformOutput', false );
set2 = cellfun ( @reshape, set2, repmat ( { H_size( set2 {1}, [ 0 inf ] ) }, size ( set2 ) ), 'UniformOutput', false );

% Converts the sets to matrixes.
set1 = cell2mat ( set1 (:) );
set2 = cell2mat ( set2 (:) );

% Transforms the matrixes into simetric ones.
if ismember ( config.index, { 'PSI', 'DPI', 'GC', 'TE', 'S', 'H', 'M', 'N', 'L', 'PDC', 'DTF' } )
    set1 = ( set1 + permute ( set1, [ 1 3 2 4: ndims( set1 ) ] ) ) / 2;
    set2 = ( set2 + permute ( set2, [ 1 3 2 4: ndims( set2 ) ] ) ) / 2;
end

% Selects the desired window, if any.
if config.time1 || config.time2
    
    % Gets the dimension defining the windows.
    windim = find ( strcmp ( statistics.origin.dimensions ( 1, : ), 'time' ) );
    perm   = 1: ndims ( set1 ) + 1;
    perm   ( 1 ) = windim + 1;
    perm   ( windim + 1 ) = 1;
    
    % Gets the selected windows for each set.
    set1   = permute ( set1, perm );
    set1   = set1 ( config.time1, :, :, :, : );
    set1   = permute ( set1, perm );
    
    set2   = permute ( set2, perm );
    set2   = set2 ( config.time2, :, :, :, : );
    set2   = permute ( set2, perm );
    
    % Modifies the window definition in the original index configuration.
    statistics.origin.dimensions { 2, windim } = [ 0 0 ];
end

% Computes statistic methods.
switch config.method
    
    % Calculates the uncorrected statistics.
    case 'Uncorrected'
        statistics.data = H_statisticsUC   ( set1, set2, config.parameters, config.fix, waitbar );
    
    % Calculates the FDR.
    case 'FDR'
        statistics.data = H_statisticsFDR  ( set1, set2, config.parameters, config.fix, waitbar );
        
    % Calculates the CBPT.
    case 'CBPT'
        statistics.data = H_statisticsCBPT ( set1, set2, config.parameters, config.fix, project.sensors.position, waitbar );
        
    otherwise
        return
end

% If no significant results, rises a warning.
if isstruct ( statistics.data ) && isempty ( statistics.data )
    warndlg ( 'No significant results were found with these parameters', 'HERMES - Statistics warning' );
end

% Checks for user cancelation.
if ( H_stop ), return, end

% Updates the waitbar.
waitbar.message = 'Saving the results';
waitbar = H_waitbar ( waitbar );

% Saves the calculated statistics.
H_save ( project, 'statistics', statistics );

% Deletes the waitbar.
delete ( waitbar.handle );
