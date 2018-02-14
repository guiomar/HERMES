function project = H_HERimportLegacy ( filename )
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

% Resets the cancelation flag.
H_stop (0);
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Gets the variable information to check its completitude.
meta     = whos ( '-file', filename );
matrixes = strcmp ( { meta.class }, 'double' ) | strcmp ( { meta.class }, 'single' );
sizes    = reshape ( [ meta( matrixes ).size ], [], sum ( matrixes ) )';

% If there is no project structure, data is marked as corrupt.
if ~any ( strcmp ( { meta.name }, 'project' ) ),                             project = []; return, end
if ~strcmp ( meta ( strcmp ( { meta.name }, 'project' ) ).class, 'struct' ), project = []; return, end

% If matrixes are not uniform, data is marked as corrupt.
if size ( unique ( sizes ( :, 1: 2 ), 'rows' ), 1 ) ~= 1, project = []; return, end

% Loads the project from the exported file.
project = struct2array ( load ( '-mat', filename, 'project' ) );

% Replaces the spaces for underscores in the project filename.
project.filename = strrep ( project.filename, ' ', '_' );

% Checks if there is an older project with a similar name.
if exist ( H_path ( 'Projects', project.filename ), 'dir' )
    
    % Gets the old project name.
    old_project = H_load ( project.filename );
    
    % Asks the user if he wants to replace the project.
    if isstruct ( old_project )
        text = 'There already exists a project (%s) with a name similar to the one you are trying to import (%s)\n\nDo you want to replace it?';
        text = sprintf ( text, old_project.name, project.name );
        
        if ~strcmp ( questdlg ( text, 'HERMES - Importation question', 'Yes', 'No', options ), 'Yes' )
            project = [];
            H_stop (1);
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

% Loads the logs.
if any ( strcmp ( { meta.name }, 'logs' ) )
    logs = struct2array ( load ( '-mat', filename, 'logs' ) );
else
    logs = [];
end

% Reserves memory for the information structure.
files = struct ( 'filename', '', 'varname', '', 'subject', 0, 'size', repmat ( {0}, numel ( project.subjects ) * numel ( project.conditions ), 1 ) );

% Stablish the names of the variables and the files to store.
for subject = 1: numel ( project.subjects )
    for condition = 1: numel ( project.conditions )
        index = ( subject - 1 ) * numel ( project.conditions ) + condition;
        
        % If the variable has any data its information is stored.
        if project.statistical ( subject ).trials ( condition ) > 0
            files ( index ).filename = H_path ( 'temp', subject, condition );
            files ( index ).varname  = sprintf ( 'subject%gcondition%g', subject, condition );
            files ( index ).subject  = subject;
            
            % Gets the variable information.
            varinfo = meta ( strcmp ( files ( index ).varname, { meta.name } ) );
            if numel ( varinfo.size ) < 3, varinfo.size ( 3 ) = 1; end
            
            % If the variable doesn't exist, data is marked as corrupt.
            if isempty ( varinfo ), project = []; return, end
            
            % If the dimensions are incorrect, data is marked as corrupt.
            if varinfo.size (1) ~= project.samples, project = []; return, end
            if varinfo.size (2) < project.channels, project = []; return, end
            if varinfo.size (3) ~= project.statistical ( subject ).trials ( condition ), project = []; return, end
            
            % The variable size is stored.
            files ( index ).size = meta ( strcmp ( files ( index ).varname, { meta.name } ) ).bytes;
        end
    end
end

% Stablish the progress associated with each file.
filesizes = [ files.size ] / sum ( [ files.size ] );
progress  = cumsum ( filesizes );

% Creates the folders.
mkdir ( H_path ( 'temp' ) );
mkdir ( H_path ( 'temp', 'data' ) );

mkdir ( fileparts ( H_path ( 'temp', 'logs' ) ) );
mkdir ( fileparts ( H_path ( 'temp', 'indexes' ) ) );
mkdir ( fileparts ( H_path ( 'temp', 'statistics' ) ) );

for subject = 1: numel ( project.subjects )
    mkdir ( fileparts ( H_path ( 'temp', subject, 1 ) ) )
end

% Updates the waitbar.
waitbar.message = 'Importing calculated indexes...';
waitbar = H_waitbar ( waitbar );

% For versions before 0.9.1.
if H_version ( project, 'decimal' ) < H_version ( struct ( 'version', 'HERMES v0.9.1' ), 'decimal' )
    
    % If there are calculated indexes, imports them.
    if any ( strcmp ( 'indexes', { meta.name } ) )
        
        % Loads the calculated indexes.
        indexes = struct2array ( load ( '-mat', filename, 'indexes' ) );
        
        % Saves the calculated indexes.
        save ( '-mat', H_path ( 'temp', 'indexes', '001.index' ), '-struct', 'indexes', '-v6' )
        
        % Saves the indexes metadata.
        indexmeta.filename    = '001.index';
        indexmeta.date        = clock * 0;
        indexmeta.description = 'Original run';
        indexmeta.indexes     = fieldnames ( indexes );
        indexmeta.config      = indexes;
        
        for index = 1: numel ( indexmeta.indexes )
            indexmeta.config.( indexmeta.indexes { index } ) = rmfield ( indexmeta.config.( indexmeta.indexes { index } ), { 'dimensions' 'data' } );
        end
        
        save ( '-mat', H_path ( 'temp', 'indexes' ), 'indexmeta', '-v6' )
        clear indexes
    end
    
    % If there are logs, import them.
    if isfield ( project, 'logs' )
        
        % Extracts the logs metadata from the project.
        logs    = project.logs;
        project = rmfield ( project, 'logs' );
        
        % Extracts the logs from the HER file.
        content = struct2array ( load ( '-mat', filename, 'logs' ) );
        [ logs.content ] = content.content;
        
        % Creates the field 'content' and modifies the filename.
        for log = 1: numel ( logs )
            logs ( log ).filename = sprintf ( '%03g.log', log );
        end
        
    else
        logs = [];
    end
else
    
    
end

% Loads from the HER file and saves all data files.
for index = 1: numel ( files )
    
    % If no variable size, skips the variable.
    if files ( index ).size == 0, continue, end
    
    % Updates the waitbar.
    waitbar.message  = sprintf ( 'Importing subject %g data...', files ( index ).subject );
    waitbar          = H_waitbar ( waitbar );
    
    % Loads the data from the project file.
    data = load ( '-mat', filename, files ( index ).varname );
    data = data.( files ( index ).varname ); %#ok<NASGU>
    
    % Checks for cancelation.
    if ( H_stop ), project = []; return, end
    
    % Updates the waitbar.
    waitbar.progress (1) = progress ( index ) - filesizes ( index ) / 2;
    waitbar              = H_waitbar ( waitbar );
    
    % Saves the data in the new project.
    save ( '-mat', files ( index ).filename, 'data', '-v6' );
    
    % Checks for cancelation.
    if ( H_stop ), project = []; return, end
    
    % Updates the waitbar.
    waitbar.progress (1) = progress ( index );
end

% Loads from the HER file all the logs.
if numel ( logs )
    
    for log = 1: numel ( logs )
        fid = fopen ( H_path ( 'temp', 'logs', logs ( log ).filename ), 'w' );
        fprintf ( fid, '%s', logs ( log ).content );
        fclose ( fid );
    end
    
    % Saves the logs metadata.
    logs = rmfield ( logs, 'content' ); %#ok<NASGU>
    save ( H_path ( 'temp', 'logs' ), '-v6', 'logs' );
end

% Moves the file to the projects folder.
waitbar.message = 'Moving project to its definitive location...';
waitbar = H_waitbar ( waitbar );

movefile ( H_path ( 'temp' ), H_path ( 'Projects', project ) )


% Updates the waitbar.
waitbar.message = 'Saving project metadata...';
waitbar = H_waitbar ( waitbar );

% Sets the version of the project as the current one.
project.version = H_version ();

% Creates the defaults field.
project.defaults.act = H_GSdefaults ( project );

% Saves the project structure.
save ( '-mat', '-v6', H_path ( 'Projects', project, 'project' ), 'project' );

% Deletes the waitbar.
delete ( waitbar.handle );

% Promts a message if everything went OK.
text = 'Project succesfully imported';
msgbox ( text, 'HERMES - Export project', options )
