function H_HERexport ( project )
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


options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Gets the filename and path.
[ filename, path ] = uiputfile ( { '*.her','HERMES project files (*.her)' }, 'HERMES - Export project' );
if path == 0, return, end
filename = strcat ( path, filename );

% Resets the cancelation flag.
H_stop (0);

% Sets the extension as .her.
if ~strncmp ( fliplr ( filename ), 'reh.', 4 ), filename = [ filename '.her' ]; end

% Creates the waitbar.
waitbar.start   = clock;
waitbar.handle  = [];
waitbar.title   = 'HERMES - Export project';
waitbar.message = 'Selecting the information to be exported...';
waitbar.tic     = clock;
waitbar = H_waitbar ( waitbar );

indexes    = H_load ( project, 'indexes' );
statistics = H_load ( project, 'statistics' );
logs       = H_load ( project, 'logs' );


% Updates the waitbar.
waitbar.message  = 'Saving project metadata...';
waitbar.progress = [ 0 1 ];
waitbar = H_waitbar ( waitbar );

% Saves the project structure.
save ( '-mat', filename, 'project', '-v6' );

% Sets the variable name in the indexes structure and saves it.
for run = 1: numel ( indexes )
    indexes ( run ).varname = sprintf ( 'indexes%g', run );
end
save ( '-mat', '-v6', '-append', filename, 'indexes' );

% Sets the variable name in the statistics structure and saves it.
for run = 1: numel ( statistics )
    statistics ( run ).varname = sprintf ( 'statistics%g', run );
end
save ( '-mat', '-v6', '-append', filename, 'statistics' );

% Sets the variable name in the log structure and saves it.
for run = 1: numel ( logs )
    logs ( run ).varname = sprintf ( 'log%g', run );
end
save ( '-mat', '-v6', '-append', filename, 'logs' );


% Updates the waitbar.
waitbar.message      = 'Saving the subject''s data...';
waitbar.progress (1) = 0;
waitbar.progress (2) = numel ( project.subjects ) * numel ( project.conditions );
waitbar = H_waitbar ( waitbar );

% Saves the subjects data in the HER file.
for subject = 1: numel ( project.subjects )
    for condition = 1: numel ( project.conditions )
        output = struct ( sprintf ( 'subject%gcondition%g', subject, condition ), H_load ( project, subject, condition ) ); %#ok<NASGU>
        save ( '-mat', '-v6', '-append', filename, '-struct', 'output' );
        
        % Updates the waitbar.
        waitbar.progress (1) = ( subject - 1 ) * numel ( project.conditions ) + condition;
        waitbar = H_waitbar ( waitbar );
    end
end


% Updates the waitbar.
waitbar.message      = 'Saving the calculated indexes...';
waitbar.progress (1) = 0;
waitbar.progress (2) = numel ( indexes );
waitbar = H_waitbar ( waitbar );

% Saves the indexes in the HER file.
for run = 1: numel ( indexes )
    
    output = struct ( indexes ( run ).varname, H_load ( project, 'indexes', run, 'all' ) ); %#ok<NASGU>
    save ( '-mat', '-v6', '-append', filename, '-struct', 'output' );
    
    % Updates the waitbar.
    waitbar.progress (1) = run;
    waitbar = H_waitbar ( waitbar );
end


% Updates the waitbar.
waitbar.message      = 'Saving the calculated statistics...';
waitbar.progress (1) = 0;
waitbar.progress (2) = numel ( statistics );
waitbar = H_waitbar ( waitbar );

% Saves the statistics in the HER file.
for run = 1: numel ( statistics )
    output = struct ( statistics ( run ).varname, H_load ( project, 'statistics', run ) ); %#ok<NASGU>
    save ( '-mat', '-v6', '-append', filename, '-struct', 'output' );
    
    % Updates the waitbar.
    waitbar.progress (1) = run;
    waitbar = H_waitbar ( waitbar );
end


% Updates the waitbar.
waitbar.message      = 'Saving the working logs...';
waitbar.progress (1) = 0;
waitbar.progress (2) = numel ( logs );
waitbar = H_waitbar ( waitbar );

% Saves the logs in the HER file.
for run = 1: numel ( logs )
    output = struct ( logs ( run ).varname, H_load ( project, 'logs', run ) ); %#ok<NASGU>
    save ( '-mat', '-v6', '-append', filename, '-struct', 'output' );
    
    % Updates the waitbar.
    waitbar.progress (1) = run;
    waitbar = H_waitbar ( waitbar );
end


% Deletes the waitbar.
delete ( waitbar.handle );

% Promts a message if everything went OK.
text = 'Project succesfully exported';
msgbox ( text, 'HERMES - Export project', options )
