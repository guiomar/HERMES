function output = H_load ( varargin )
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

% Exits if no input.
if nargin < 1
    output = [];
    return
end

% If the first argument is a string, loads the project with this filename.
if ischar ( varargin {1} )
    projectfile = H_path ( 'HERMES', 'Projects', varargin {1}, 'project' );
    if exist ( projectfile, 'file' ), project = importdata ( projectfile );
    else output = []; return, end
    
% If the first argument is a struct uses it as project.
elseif isstruct ( varargin {1} )
    project = varargin {1};
    
% Otherwise exits.
else
    output = [];
    return
end

% Checks that the project is valid and its version is the current one.
if ~isstruct ( project ) ...
        || ~isfield ( project, 'version' ) ...
        || ~strcmp ( project.version, H_version ) ...
        || ( ischar ( varargin {1} ) && ~strcmp ( project.filename, varargin {1} ) )
    
    output = [];
    return
end


% Selects the output from the second input argument.

% Requests the project (no more attributes).
if nargin == 1
    output = project;
    
    
% Requests indexes-related information.
elseif strcmp ( varargin {2}, 'indexes' )
    
    % Checks that there is at least one run.
    if exist ( H_path ( 'Projects', project, 'indexes' ), 'file' )
        
        % Loads the runs structure.
        indexes = importdata ( H_path ( 'Projects', project, 'indexes' ) );
        
        % Requests the indexes metadata.
        if nargin == 2
            output = indexes;
        
        % Requests several indexes from a run.
        elseif nargin == 4 && isnumeric ( varargin {3} ) && isscalar ( varargin {3} ) && varargin {3} <= numel ( indexes ) && iscellstr ( varargin {4} )
            
            % Checks that the indexes were calculated in the selected run.
            if all ( ismember ( varargin {4}, indexes ( varargin {3} ).indexes ) )
                
                % Loads the index.
                output = load ( '-mat', H_path ( 'Projects', project, 'indexes', indexes ( varargin {3} ).filename ), varargin {4} {:} );
                
            else output = [];
            end
        
        % Requests all the indexes in one run.
        elseif nargin == 4 && isnumeric ( varargin {3} ) && isscalar ( varargin {3} ) && varargin {3} <= numel ( indexes ) && strcmp ( varargin {4}, 'all' )
            
            % Loads all the indexes.
            output = load ( '-mat', H_path ( 'Projects', project, 'indexes', indexes ( varargin {3} ).filename ) );
        
        % Requests one index from a run.
        elseif nargin == 4 && isnumeric ( varargin {3} ) && isscalar ( varargin {3} ) && varargin {3} <= numel ( indexes ) && ischar ( varargin {4} )
            
            % Checks that the index was calculated in the selected run.
            if isfield ( indexes ( varargin {3} ).config, varargin {4} )
                
                % Loads the index.
                output = struct2array ( load ( '-mat', H_path ( 'Projects', project, 'indexes', indexes ( varargin {3} ).filename ), varargin {4} ) );
                
            else output = [];
            end
            
        else output = [];
        end
        
    else output = struct ([]);
    end
    
    
% Requests statistics-related information.
elseif strcmp ( varargin {2}, 'statistics' )
    
    % Checks that there is at least one run of statistics.
    if exist ( H_path ( 'Projects', project, 'statistics' ), 'file' )
        
        % Loads the statistics metadata.
        statistics = importdata ( H_path ( 'Projects', project, 'statistics' ) );
        
        % Requests the statistics metadata.
        if nargin == 2
            output = statistics;
        
        % Requests one statistics run.
        elseif nargin == 3 && isnumeric ( varargin {3} ) && isscalar ( varargin {3} ) && varargin {3} <= numel ( statistics )
            
            % Gets the filename.
            output = importdata ( H_path ( 'Projects', project, 'statistics', statistics ( varargin {3} ).filename ) );
            
        else output = [];
        end
        
    else output = struct ([]);
    end
    
    
% Requests logs-related information.
elseif strcmp ( varargin {2}, 'logs' )
    
    % Checks that there is at least one log.
    if exist ( H_path ( 'Projects', project, 'logs' ), 'file' )
        
        % Loads the logs metadata structure.
        logs = importdata ( H_path ( 'Projects', project, 'logs' ) );
        
        % Requests the logs metadata.
        if nargin == 2
            output = logs;
        
        % Requests one log.
        elseif nargin == 3 && isnumeric ( varargin {3} ) && isscalar ( varargin {3} ) && varargin {3} <= numel ( logs )
            
            % Gets the filename.
            logFile = H_path ( 'Projects', project.filename, 'logs', logs ( varargin {3} ).filename );
            
            % Reads the log information.
            fid    = fopen ( logFile, 'r' );
            output = fread ( fid, 'char=>char' )';
            fclose ( fid );
            
        else output = [];
        end
        
    else output = struct ([]);
    end
    
    
% Requests the data for a subject and condition.
elseif nargin == 3 && isnumeric ( varargin {2} ) && isnumeric ( varargin {3} )
    
    % Checks that the file exists.
    if exist ( H_path ( 'Projects', project, varargin {2}, varargin {3} ), 'file' )
        
        % Loads the data file.
        data = importdata ( H_path ( 'Projects', project, varargin {2}, varargin {3} ) );
        
        % Selects the subset of channels.
        if isfield ( project.sensors, 'order' )
            
            order = project.sensors.order;
            data = data ( :, order ( order ~= 0 ), : );
        end
        
        % Makes zero mean and unity standard deviation.
        output = zscore ( data );
        
    else output = [];
    end
        
else output = [];
end
