function path = H_path ( varargin )

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


% Stablish the HERMES path from the HERMES.m file.
basepath = fileparts ( which ( 'HERMES.m' ) );

% Extracts the options.
if nargin,     key = lower ( varargin {1} );
else           key = 'HERMES';
end
if nargin > 1, file = varargin {2};
else           file = '';
end

% Constructs the path from the options.
switch key
    case { 'temp' }
        
        % Constructs the path from the input.
        if nargin < 2
            file = filesep;
            
        elseif nargin == 2 && strcmp ( varargin {2}, 'indexes' )
            file = sprintf ( '%s indexes %s indexes.meta', filesep, filesep );
            
        elseif nargin == 3 && strcmp ( varargin {2}, 'indexes' )
            file = sprintf ( '%s indexes %s %s', filesep, filesep, varargin {3} );
            
        elseif nargin == 2 && strcmp ( varargin {2}, 'statistics' )
            file = sprintf ( '%s statistics %s statistics.meta', filesep, filesep );
            
        elseif nargin == 3 && strcmp ( varargin {2}, 'statistics' )
            file = sprintf ( '%s statistics %s %s', filesep, filesep, varargin {3} );
            
        elseif nargin == 2 && strcmp ( varargin {2}, 'logs' )
            file = sprintf ( '%s logs %s logs.meta', filesep, filesep );
            
        elseif nargin == 3 && strcmp ( varargin {2}, 'logs' )
            file = sprintf ( '%s logs %s %s', filesep, filesep, varargin {3} );
            
        elseif nargin == 3 && isnumeric ( varargin {2} ) && isnumeric ( varargin {3} )
            file = sprintf ( '%s data %s subject %03g %s condition %03g .data', filesep, filesep, varargin {2}, filesep, varargin {3} );
            
        elseif iscellstr ( varargin ( 2: end ) )
            % Constructs the route from the input arguments.
            string = strcat ( filesep, varargin ( 2: end ) );
            file = sprintf ( '%s', string {:} );
            
        end
        
        path = sprintf ( '%s %s Temp %s', basepath, filesep, file );
        path = strrep ( path, ' ', '' );
        
    case { 'p', 'projects' }
        
        % Gets the project filename.
        if isstruct ( file ) && isfield ( file, 'version' ) && strncmp ( file.version, 'HERMES v', 8 )
            filename = file.filename;
        else
            filename = file;
        end
        
        % Constructs the path for the specific project.
        if nargin < 3
            file = sprintf ( '%s', filesep );
            
        elseif nargin == 3 && strcmp ( varargin {3}, 'indexes' )
            file = sprintf ( '%s indexes %s indexes.meta', filesep, filesep );
            
        elseif nargin == 4 && strcmp ( varargin {3}, 'indexes' )
            file = sprintf ( '%s indexes %s %s', filesep, filesep, varargin {4} );
            
        elseif nargin == 3 && strcmp ( varargin {3}, 'statistics' )
            file = sprintf ( '%s statistics %s statistics.meta', filesep, filesep );
            
        elseif nargin == 4 && strcmp ( varargin {3}, 'statistics' )
            file = sprintf ( '%s statistics %s %s', filesep, filesep, varargin {4} );
            
        elseif nargin == 3 && strcmp ( varargin {3}, 'logs' )
            file = sprintf ( '%s logs %s logs.meta', filesep, filesep );
            
        elseif nargin == 4 && strcmp ( varargin {3}, 'logs' )
            file = sprintf ( '%s logs %s %s', filesep, filesep, varargin {4} );
            
        elseif nargin == 4 && isnumeric ( varargin {3} ) && isnumeric ( varargin {4} )
            file = sprintf ( '%s data %s subject %03g %s condition %03g .data', filesep, filesep, varargin {3}, filesep, varargin {4} );
            
        elseif iscellstr ( varargin ( 3: end ) )
            % Constructs the route from the input arguments.
            string = strcat ( filesep, varargin ( 3: end ) );
            file = sprintf ( '%s', string {:} );
            
        end
        
        path = sprintf ( '%s %s Projects %s %s', basepath, filesep, filesep, filename, file );
        path = strrep ( path, ' ', '' );
        
    case { 'c', 'coordinates' }
        path = [ basepath filesep 'Coordinates' filesep file ];
        
    case { 'img', 'images' }
        path = [ basepath filesep 'Images' filesep file ];
        
    case 'hermes'
        string = strcat ( filesep, varargin ( 2: end ) );
        path = [ basepath string{:} ];
    
    otherwise
        string = strcat ( filesep, varargin ( 1: end ) );
        path = [ basepath string{:} ];
end