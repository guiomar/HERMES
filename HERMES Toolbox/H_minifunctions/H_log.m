function H_log ( project, action, varargin )
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
% Authors:  Ricardo Bruna, 2013
%


% Loads the logs metadata.
logs = H_load ( project, 'logs' );

% Creates the new log entry, if required.
if strcmp ( action, 'new' )
    
    log.filename    = sprintf ( '%03g.log', numel ( logs ) + 1 );
    log.date        = clock;
    log.description = strcat ( 'Log created on ', datestr ( clock, ' yyyy-mm-dd at HH:MM:SS' ) );
    
    % Saves the new log metadata.
    logs = cat ( 1, logs, log ); %#ok<NASGU>
    save ( '-v6', H_path ( 'Projects', project, 'logs' ), 'logs' );
    
    % Creates the new file.
    fid = fopen ( H_path ( 'Projects', project, 'logs', log.filename ), 'w' );
    
    % Gets the configuration structure.
    configurations = H_show ( varargin {1}, 5, 'Configuration structure' );
    
    fprintf ( fid, 'Execution started on %s.\n\n', datestr ( now, 'dddd, yyyy-mm-dd at HH:MM:SS' ) );
    fprintf ( fid, 'Executing HERMES with ''config'' structure:\n\n%s', configurations );
    
    % Closes the file.
    fclose ( fid );
    
    return
end
    
% Opens the file to append.
fid = fopen ( H_path ( 'Projects', project, 'logs', logs ( end ).filename ), 'a' );

% Marks the begining of the new entry.
fprintf ( fid, '##ENTRY##\n' );

% Writes the description.
fprintf ( fid, 'Entry generated on %s:\n\n', datestr ( now, 'dddd, yyyy-mm-dd at HH:MM:SS' ) );

% Selects the action.
switch ( action )
    
    % Calls a new function.
    case 'calling'
        
        % Gets the information of the calling functions.
        functions = dbstack ( 1 );
        
        % Gets the input configuration structure.
        configurations = H_show ( varargin {1}, 5, 'Configuration structure' );
        
        fprintf ( fid, '     Executing function ''%s'' with ''config'' structure:\n\n%s', functions (1).name, configurations );
    
    % Calls a new function.
    case 'success'
        
        % Gets the information of the calling functions.
        functions = dbstack (1);
        
        fprintf ( fid, '     Succesfully executed function ''%s''.\n\n', functions (1).name );
    
    % Calls a new function.
    case 'finished'
        
        fprintf ( fid, 'Run successfully finished in %s.\n', varargin {1} );
    
    % User cancelation.
    case 'cancel'
        
        fprintf ( fid, '     Canceled by the user.\n' );
    
    % Error handling.
    case 'error'
        
        % Gets the input configuration files.
        error_msg = H_show ( varargin {1}, 5, 'Error information' );
        
        fprintf ( fid, '     An error has ocurred.\n\n%s', error_msg );
end

% Closes the file.
fclose ( fid );