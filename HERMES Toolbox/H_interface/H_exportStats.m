function H_exportStats ( project, run, filename )
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
% Authors:  Ricardo Bruna, 2012
%

% Resets the cancelation flag.
H_stop (0);

% Creates the waitbar.
waitbar.start    = clock;
waitbar.handle   = [];
waitbar.progress = [ 0 2 ];
waitbar.title    = 'HERMES - Export statistics';
waitbar.message  = 'Selecting statistics to export...';
waitbar.tic      = clock;

waitbar = H_waitbar ( waitbar );

% Loads the statistics run into the project structure.
statistics = H_load ( project, 'statistics', run );

% Updates the waitbar.
waitbar.message  = 'Saving the file...';
waitbar.progress = [ 1 2 ];
waitbar = H_waitbar ( waitbar );

% If file output, saves the indexes file.
if ischar ( filename )
    save ( '-mat', '-v6', filename, 'project', 'statistics' )
    
% If workspace output, stores the variable in the workspace.
else
    assignin ( 'base', 'statistics', statistics );
end

% Destroys the waitbar.
delete ( waitbar.handle );

% Promts a message of success.
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'None', 'Default', 'No' );
if ischar ( filename ), text = 'Statistics file ''%s'' succesfully saved.';
else                    text = 'Statistics succesfully exported.';
end
text = sprintf ( text, filename );

uiwait ( msgbox ( text, 'HERMES - Export statistics', options ) )
