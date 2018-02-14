function projects = H_projects
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


% Sets the base path and creates the structure.
path = H_path ( 'p' );
projects = struct ( 'name', {}, 'filename', {} );

directories = dir ( path );

% Checks each folder in the path searching for projects.
for d = 1: numel ( directories )
    if ~directories ( d ).isdir || strcmp ( directories ( d ).name, 'tmp' ) || strcmp ( directories ( d ).name, '.' ) || strcmp ( directories ( d ).name, '..' ), continue, end
    if ~exist ( [ path filesep directories( d ).name filesep 'project' ], 'file' ), continue, end
    
    project = importdata ( [ path filesep directories( d ).name filesep 'project' ] );
    
    % If the folder contains a project takes the metadata.
    if isstruct ( project ) ...
            && isfield ( project, 'version' ) ...
            && strncmp ( project.version, 'HERMES', 6 ) ...
            && strcmp  ( project.filename, directories ( d ).name )
        
        projects ( numel ( projects ) + 1 ).name = project.name;
        projects ( numel ( projects ) ).filename = project.filename;
    end
end