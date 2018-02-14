function project = H_HERimport
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

% Gets the filename and path.
[ filename, path ] = uigetfile ( { '*.her','HERMES project files (*.her)' }, 'HERMES - Import project file' );
if path == 0, project = []; return, end
filename = strcat ( path, filename );

% Resets the cancelation flag.
H_stop (0);

% Destroy the temporal folder..
if exist ( H_path ( 'temp' ), 'dir' ), rmdir ( H_path ( 'temp' ), 's' ); end

% Gets the variable information to check its completitude.
meta     = whos ( '-file', filename );
matrixes = strcmp ( { meta.class }, 'double' ) | strcmp ( { meta.class }, 'single' );
sizes    = reshape ( [ meta( matrixes ).size ], [], sum ( matrixes ) )';

% If the structure is not consistent, data is marked as corrupt.
if ~any ( strcmp ( { meta.name }, 'project' ) ),                                project = noHER; return, end
if ~strcmp ( meta ( strcmp ( { meta.name }, 'project' ) ).class, 'struct' ),    project = noHER; return, end
if isempty ( sizes ) || size ( unique ( sizes ( :, 1: 2 ), 'rows' ), 1 ) ~= 1, project = noHER; return, end

% Loads the project from the exported file.
project = struct2array ( load ( '-mat', filename, 'project' ) );

% For outdated project versions, call the specific function.
if H_version ( project, 'decimal' ) ~= H_version ( [], 'decimal' )
    if H_version ( project, 'decimal' ) < H_version ( [], 'decimal' )
        project = H_HERimportLegacy ( filename );
    end
    
    if H_version ( project, 'decimal' ) > H_version ( [], 'decimal' )
        text = 'The version of the HER file you are trying to import (%s) is newer than the current one (%s).\n\nPlease, download the last version of HERMES to open it.';
        text = sprintf ( text, project.version, H_version );
        
        errordlg ( text, 'HERMES - Importation error' )
        project = [];
    end
    
    return
end

% Checks if there is an older project with a similar name.
if exist ( H_path ( 'Projects', project.filename ), 'dir' )
    
    % Gets the old project name.
    old_project = H_load ( project.filename );
    
    % Asks the user if he wants to replace the project.
    if isstruct ( old_project )
        text = 'There already exists a project (%s) with a name similar to the one you are trying to import (%s).\n\nDo you want to replace it?';
        text = sprintf ( text, old_project.name, project.name );
        
        if ~strcmp ( questdlg ( text, 'HERMES - Importation question', 'Yes', 'No', options ), 'Yes' )
            project = [];
            return
        end    
    end
    
    rmdir ( H_path ( 'Projects', project.filename ), 's' )
end


% Creates the waitbar.
waitbar.start    = clock;
waitbar.handle   = [];
waitbar.progress = [ 0 1 ];
waitbar.title    = 'HERMES - Import project';
waitbar.message  = 'Checking data completitude...';
waitbar.tic      = clock;
waitbar = H_waitbar ( waitbar );

% Creates the temporal folders for the project.
if exist ( H_path ( 'temp' ), 'dir' )
    rmdir ( H_path ( 'temp' ), 's' );
end

mkdir ( H_path ( 'temp' ) );
mkdir ( H_path ( 'temp', 'data' ) );

mkdir ( fileparts ( H_path ( 'temp', 'logs' ) ) );
mkdir ( fileparts ( H_path ( 'temp', 'indexes' ) ) );
mkdir ( fileparts ( H_path ( 'temp', 'statistics' ) ) );


% Updates the waitbar.
waitbar.message      = 'Loading the subject''s data...';
waitbar.progress (1) = 0;
waitbar.progress (2) = numel ( project.subjects ) * numel ( project.conditions );
waitbar = H_waitbar ( waitbar );

% Saves the subjects data.
for subject = 1: numel ( project.subjects )
    
    % Creates the directory for the current subject.
    mkdir ( fileparts ( H_path ( 'temp', subject, 1 ) ) );
    
    % Goes through all the conditions.
    for condition = 1: numel ( project.conditions )
        
        % Loads the subject data from the HER file.
        varname = sprintf ( 'subject%gcondition%g', subject, condition );
        
        if any ( strcmp ( varname, { meta.name } ) )
            data = struct2array ( load ( '-mat', filename, varname ) );
        else
            data = [];
        end
        
        % Checks the integrity of the matrix.
        checksum = H_checksum ( data ); %#ok<NASGU>
        
        % Saves the data.
        save ( '-mat', '-v6', H_path ( 'temp', subject, condition ), 'data' );
        
        % Updates the waitbar.
        waitbar.progress (1) = ( subject - 1 ) * numel ( project.conditions ) + condition;
        waitbar = H_waitbar ( waitbar );
    end
end


% Checks for calculated indexes.
if prod ( meta ( strcmp ( { meta.name }, 'indexes' ) ).size )
    
    % Loads the indexes metadata.
    indexes = struct2array ( load ( '-mat', filename, 'indexes' ) );
    
    % Updates the waitbar.
    waitbar.message      = 'Loading the calculated indexes...';
    waitbar.progress (1) = 0;
    waitbar.progress (2) = numel ( indexes );
    waitbar = H_waitbar ( waitbar );
    
    % Saves the indexes data.
    for run = 1: numel ( indexes )
        data = struct2array ( load ( '-mat', filename, indexes ( run ).varname ) ); %#ok<NASGU>
        save ( '-mat', '-v6', H_path ( 'temp', 'indexes', indexes ( run ).filename ), '-struct', 'data' );
        
        % Updates the waitbar.
        waitbar.progress (1) = run;
        waitbar = H_waitbar ( waitbar );
    end
    
    % Saves the indexes metadata.
    indexes = rmfield ( indexes, 'varname' ); %#ok<NASGU>
    save ( '-mat', '-v6', H_path ( 'temp', 'indexes' ), 'indexes' );
end


% Checks for calculated indexes.
if prod ( meta ( strcmp ( { meta.name }, 'statistics' ) ).size )
    
    % Loads the statistics metadata.
    statistics = struct2array ( load ( '-mat', filename, 'statistics' ) );
    
    % Updates the waitbar.
    waitbar.message      = 'Loading the calculated indexes...';
    waitbar.progress (1) = 0;
    waitbar.progress (2) = numel ( statistics );
    waitbar = H_waitbar ( waitbar );
    
    % Saves the indexes data.
    for run = 1: numel ( statistics )
        data = struct ( 'statsitics', struct2array ( load ( '-mat', filename, statistics ( run ).varname ) ) ); %#ok<NASGU>
        save ( '-mat', '-v6', H_path ( 'temp', 'statistics', statistics ( run ).filename ), '-struct', 'data' );
        
        % Updates the waitbar.
        waitbar.progress (1) = run;
        waitbar = H_waitbar ( waitbar );
    end
    
    % Saves the indexes metadata.
    statistics = rmfield ( statistics, 'varname' ); %#ok<NASGU>
    save ( '-mat', '-v6', H_path ( 'temp', 'statistics' ), 'statistics' );
end


% Checks for calculated indexes.
if prod ( meta ( strcmp ( { meta.name }, 'logs' ) ).size )
    
    % Loads the logs metadata.
    logs = struct2array ( load ( '-mat', filename, 'logs' ) );
    
    % Updates the waitbar.
    waitbar.message      = 'Loading the calculated indexes...';
    waitbar.progress (1) = 0;
    waitbar.progress (2) = numel ( logs );
    waitbar = H_waitbar ( waitbar );
    
    % Saves the logs.
    for run = 1: numel ( logs )
        data = struct2array ( load ( '-mat', filename, logs ( run ).varname ) );
        
        fid = fopen ( H_path ( 'temp', 'logs', logs ( run ).filename ), 'w' );
        fprintf ( fid, '%s', data );
        fclose ( fid );
        
        % Updates the waitbar.
        waitbar.progress (1) = run;
        waitbar = H_waitbar ( waitbar );
    end
    
    % Saves the logs metadata.
    logs = rmfield ( logs, 'varname' ); %#ok<NASGU>
    save ( '-mat', '-v6', H_path ( 'temp', 'logs' ), 'logs' );
end

% Moves the file to the projects folder.
waitbar.message = 'Moving project to its definitive location...';
waitbar = H_waitbar ( waitbar );

movefile ( H_path ( 'temp' ), H_path ( 'Projects', project ) )


% Updates the waitbar.
waitbar.message = 'Importing project metadata...';
waitbar = H_waitbar ( waitbar );

% Checks for the defaults field or creates it.
if ~isfield ( project, 'defaults' ), project.defaults = []; end

% Calculates the whole window autocorrelation time, if needed.
if ~isfield ( project.defaults, 'act' ), project.defaults.act = H_GSdefaults ( project ); end

% Saves the project metadata.
save ( '-mat', '-v6', H_path ( 'Projects', project, 'project' ), 'project' );


% Deletes the waitbar.
delete ( waitbar.handle );

% Promts a message if everything went OK.
text = 'Project succesfully imported';
msgbox ( text, 'HERMES - Export project', options )


function empty = noHER
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Deletes the waitbar and the temporal folder.
delete ( findobj ( 'tag', 'H_waitbar' ) );
if exist ( H_path ( 'temp' ), 'dir' ), rmdir ( H_path ( 'temp' ), 's' ); end

% Promts an error.
text = 'The selected file is not a valid HERMES project.';
errordlg ( text, 'HERMES - Project importation error', options )

empty = [];