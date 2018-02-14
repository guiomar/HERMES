function H_save ( project, varargin ) %#ok<*NASGU>
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


% Includes the version ID in the project header.
project.version  = 'HERMES v0.9.1';

% Checks if there are calculated indexes.
if nargin > 1 && strcmp ( varargin {1}, 'indexes' )
    
    % Stores the calculated index in its file.
    if nargin == 4
        meta    = varargin {2};
        indexes = varargin {3};
        
        % Gets the file where save the calculated indexes.
        indexfile = H_path ( 'Projects', project, 'indexes', meta.filename );
        
        % Saves the indexes.
        if exist ( indexfile, 'file' ), save ( '-mat', indexfile, '-struct', 'indexes', '-v6', '-append' )
        else                            save ( '-mat', indexfile, '-struct', 'indexes', '-v6' )
        end
        
        % Saves the metadata information.
        H_save ( project, 'indexes', meta )
        
        
    % Adds the metadata to the metadata file.    
    elseif nargin == 3
        meta         = varargin {2};
        meta.config  = load ( '-mat', H_path ( 'Projects', project, 'indexes', meta.filename ) );
        meta.indexes = fieldnames ( meta.config );
        
        for index = 1: numel ( meta.indexes )
            meta.config.( meta.indexes { index } ) = rmfield ( meta.config.( meta.indexes { index } ), 'data' );
        end
        
        % Gets the file where save the calculated indexes.
        metafile = H_path ( 'Projects', project, 'indexes' );
        indexes  = H_load ( project, 'indexes' );
        
        % If the session is stored in the meta file, overwrites it.
        if numel ( indexes ) && any ( strcmp ( meta.filename, { indexes.filename } ) )
            indexes ( strcmp ( meta.filename, { indexes.filename } ) ) = meta;
            
        % Otherwise creates a new session.
        else
            indexes  = [ indexes meta ];
        end
        
        % Saves the indexes metadata.
        save ( '-mat', metafile, 'indexes', '-v6' )
    end

% Checks if there are calculated statistics.
elseif nargin > 1 && strcmp ( varargin {1}, 'statistics' )
    
    oldstats = H_load ( project, 'statistics' );
    index    = numel ( oldstats ) + 1;
    
    statistics = varargin {2};
    save ( H_path ( 'Projects', project, 'statistics', statistics.filename ), '-mat', '-v6', 'statistics' );
    
    statistics = rmfield ( statistics, 'data' );
    statistics = cat ( 1, oldstats, statistics );
    
    save ( H_path ( 'Projects', project, 'statistics' ), '-mat', '-v6', 'statistics' );
    
% If there is no indexes, saves the project.
else
    save ( '-mat', H_path ( 'Projects', project, 'project' ), 'project', '-v6' );
end