function H_HERexport ( project, filename )
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


options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Resets the cancelation flag.
H_stop ( false );

% Sets the extension as .her.
if ~strncmp ( fliplr ( filename ), 'reh.', 4 ), filename = [ filename '.her' ]; end

% Creates the waitbar.
waitbar.start   = clock;
waitbar.handle  = [];
waitbar.title   = 'HERMES - Export project';
waitbar.message = 'Selecting the information to be exported...';
waitbar.tic     = clock;
waitbar         = H_waitbar ( waitbar );

% Reserves memory for the information structre.
files = struct ( 'filename', '', 'varname', '', 'subject', 0, 'size', repmat ( {0}, numel ( project.subjects ) * numel ( project.conditions ), 1 ) );

% Gets the size of each data file.
for subject = 1: numel ( project.subjects )
    for condition = 1: numel ( project.conditions )
        
        fileinfo = dir ( H_path ( 'Projects', project, subject, condition ) );
        index    = ( subject - 1 ) * numel ( project.conditions ) + condition;
        
        % If the file exists, stores its information.
        if ( ~isempty ( fileinfo ) )
            files ( index ).filename = H_path ( 'Projects', project, subject, condition );
            files ( index ).varname  = sprintf ( 'subject%gcondition%g', subject, condition );
            files ( index ).subject  = subject;
            files ( index ).size     = fileinfo.bytes;
        end
    end
end

% Stablish the progress associated with each file.
filesizes = [ files.size ] / sum ( [ files.size ] );
progress  = cumsum ( filesizes );

% Updates the waitbar.
waitbar.message  = 'Saving project metadata...';
waitbar.progress = [ 0 1 ];
waitbar          = H_waitbar ( waitbar );

% Saves the project structure.
save ( '-mat', filename, 'project', '-v6' );

% Updates the waitbar.
waitbar.message  = 'Saving the working logs...';
waitbar.progress = [ 0 1 ];
waitbar          = H_waitbar ( waitbar );

% Includes the logs in the project structure.
logs = struct ( 'content', repmat ( '', numel ( project.logs ), 1 ) );
for log = 1: numel ( project.logs )
    logs ( log ).content = H_load ( project, 'log', log );
end

% Saves the project structure.
save ( '-mat', filename, 'logs', '-append', '-v6' );

% Updates the waitbar.
waitbar.message = 'Saving calculated indexes...';
waitbar.tic     = clock;
waitbar         = H_waitbar ( waitbar );

% If there are calculated indexes, saves them.
fileinfo = dir ( H_path ( 'Projects', project, 'indexes' ) );
if ~isempty ( fileinfo )
    
    % Loads the calculated indexes.
    indexes = load ( '-mat', H_path ( 'Projects', project, 'indexes' ) ); %#ok<NASGU>
    
    % Saves the calculated indexes.
    save ( '-mat', filename, 'indexes', '-append', '-v6' );
    clear indexes
end

% Loads and saves to the project file all data files.
for index = 1: numel ( files )
    
    % If no file size, skips the file.
    if files ( index ).size == 0, continue, end
    
    % Updates the waitbar.
    waitbar.message = sprintf ( 'Exporting subject %g data...', files ( index ).subject );
    waitbar         = H_waitbar ( waitbar );
    
    % Loads the data.
    data = importdata ( files ( index ).filename );
    
    % Checks for cancelation.
    if ( H_stop ), delete ( filename ); return, end
    
    % Updates the waitbar.
    waitbar.progress (1) = progress ( index ) - filesizes ( index ) / 2;
    waitbar              = H_waitbar ( waitbar );
    
    % Saves the data with the new name.
    data = struct ( files ( index ).varname, data ); %#ok<NASGU>
    save ( '-mat', filename, '-struct', 'data', '-append', '-v6' );
    
    % Checks for cancelation.
    if ( H_stop ), delete ( filename ); return, end
    
    % Updates the waitbar.
    waitbar.progress (1) = progress ( index );
end

% Deletes the waitbar.
delete ( waitbar.handle );

% Promts a message if everything went OK.
text = 'Project succesfully exported';
msgbox ( text, 'HERMES - Export project', options )
