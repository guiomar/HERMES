function project = H_import ( path, labels, filesinfo )
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


% Creates the option variables.
erropts  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' ,'Color', [ .9 .9 .9 ]);
traspose = true;
flatOK   = false;

% Creates the project.
project = struct;

project.version     = H_version;
project.name        = '';
project.filename    = '';
project.description = '';

project.source      = [];
project.origindata  = struct ( 'filename', {}, 'subject', {}, 'condition', {}, 'file', {}, 'dimensions', {}, 'orig', {} );

project.date        = clock;
project.type        = [];

project.subjects    = unique ( labels ( :, 2 ) );
project.groups      = unique ( labels ( :, 3 ) );
project.conditions  = unique ( labels ( :, 4 ) );
project.statistical = struct ( 'group', {}, 'trials', {}, 'check', {} );

project.baseline    = [];
project.samples     = [];
project.time        = [];
project.fs          = 0;

project.channels    = [];
project.sensors     = [];

% Creates the waitbar.
waitbar.start    = clock;
waitbar.handle   = [];
waitbar.title    = 'HERMES - New project';
waitbar.message  = 'Importing data...';
waitbar.tic      = clock;
waitbar.progress = [ 0 size( labels, 1 ) ];
waitbar = H_waitbar ( waitbar );

% % Checks if the data is provided in separated files or in a cell.
% if ischar ( files )
%     data = importdata ( files );
%     
%     if isnumeric ( data ) || isstruct ( data ), files = { data };
%     elseif iscell ( data ),                     files = data;
%     else project = []; return
%     end
% end

% Creates the temporal folders.
if exist ( H_path ( 'temp' ), 'dir' ), rmdir ( H_path ( 'temp' ), 's' ), end

mkdir ( H_path ( 'temp' ) );
mkdir ( H_path ( 'temp', 'data' ) );

mkdir ( fileparts ( H_path ( 'temp', 'logs' ) ) );
mkdir ( fileparts ( H_path ( 'temp', 'indexes' ) ) );
mkdir ( fileparts ( H_path ( 'temp', 'statistics' ) ) );

% Goes through all subjects and conditions.
for subject = 1: numel ( project.subjects )
    
    % Adds the data of the subject.
    project.statistical ( subject ).group = unique ( labels ( strcmp ( labels ( :, 2 ), project.subjects { subject } ), 3 ) );
    if numel ( project.statistical ( subject ).group ) ~= 1
        project = [];

        text = 'There is at least one subject with more than one assigned groups.';
        errordlg ( text, 'HERMES - Importing error', erropts )
        return
        
    else
        project.statistical ( subject ).group = find ( strcmp ( project.statistical ( subject ).group, project.groups ) );
    end
    
    % Creates the temporal folder for the data of this subject.
    mkdir ( fileparts ( H_path ( 'temp', subject, 1 ) ) );
    
    % Creates the metadata matrixes.
    project.statistical ( subject ).trials = zeros ( numel ( project.conditions ), 1 );
    project.statistical ( subject ).check  = zeros ( numel ( project.conditions ), 2 );
    
    
    for condition = 1: numel ( project.conditions )
        
        % Get the files to load for this subject and condition.
        files = strcmp ( labels ( :, 2 ), project.subjects { subject } ) & strcmp ( labels ( :, 4 ), project.conditions { condition } );
        files = strcat ( path, labels ( files, 1 ) );
        
        data = [];
        
        % If there are several files, combines their trials.
        for file = 1: numel ( files )
            
            % Gets the file index from the files information structure.
            index = find ( strcmp ( files { file }, { filesinfo.filename } ) );
            
            % Gets the file information.
            fileinfo = filesinfo ( index );
            
            % Fulfulls the origin data for the record.
            project.origindata ( index ).filename  = files { file };
            project.origindata ( index ).subject   = subject;
            project.origindata ( index ).condition = condition;
            project.origindata ( index ).file      = file;
            
            % Loads the data depending on its origin.
            switch fileinfo.source
                
                % Raw MAT file.
                case { 'MAT raw files' 'ASCII files' }
                    
                    % Loads the data matrix.
                    filedata = importdata ( files { file } );
                
                    % Checks the shape of the matrix (samples x channels x trials).
                    if size ( filedata, 2 ) > size ( filedata, 1 )
                        if traspose
                            filedata = permute ( filedata, [ 2 1 3 ] );
                            
                        else
                            options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Transpose' );
                            
                            text = [
                                'The number of channels (%s) is bigger than the number of samples per channel (%s).\n' ...
                                'This can happen if time and channel dimensions are interchanged.\n\n' ...
                                'Is this correct, or should data matrix be transposed?' ];
                            text = sprintf ( text, size ( filedata, 2 ), size ( filedata, 1 ) );
                            answer = questdlg ( text, 'HERMES - Importing question', 'Keep it', 'Transpose', 'Transpose all', options );
                            
                            if strcmp ( answer, 'Transpose' ), filedata = permute ( filedata, [ 2 1 3 ] );
                            elseif strcmp ( answer, 'Transpose all' ), filedata = permute ( filedata, [ 2 1 3 ] ); traspose = true;
                            end
                        end
                    end
                    
                % FieldTrip structure
                case 'FieldTrip files'
                    
                    % Loads the data structure.
                    ft_data  = importdata ( files { file } );
                    
                    % Extracts the data matrix and trasposes it.
                    filedata = cell2mat ( permute ( ft_data.trial, [ 1 3 2 ] ) );
                    filedata = permute ( filedata, [ 2 1 3 ] );
                
                    % Stores the metadata in the field orig.
                    if isfield ( ft_data, 'hdr' ) && isfield ( ft_data.hdr, 'orig' )
                        project.origindata ( index ).orig = ft_data.hdr.orig;
                    end
                    
                    % Gets the sensors structure from grad or elec.
                    if isfield ( ft_data, 'grad' ),     sensors = ft_data.grad;
                    elseif isfield ( ft_data, 'elec' ), sensors = ft_data.elec;
                    else                                sensors = [];
                    end
                    
                    if isstruct ( sensors )
                        % Adds the non-present channels position as [ 0 0 0 ].
                        xlabel   = setdiff ( ft_data.label, sensors.label );
                        xchanpos = zeros ( numel ( xlabel ), 3 );
                        
                        sensors.label   = [ sensors.label;   xlabel   ];
                        sensors.chanpos = [ sensors.chanpos; xchanpos ];
                        
                        % Gets the position of all the channels.
                        [ ~, ~, indexes ]        = intersect ( ft_data.label, sensors.label );
                        project.sensors.position = sensors.chanpos ( indexes );
                        project.sensors.unit     = sensors.unit;
                    end
                    
                % If no recogniced format, creates an error.    
                otherwise
                    text = 'Data type of some of the selected files is unknown';
                    errordlg ( text, 'HERMES - Importing error', erropts )
                    
                    project = [];
                    return
            end
        
            % Checks if there is any flat channel.
            if any ( std ( filedata ( :, : ) ) == 0 ) && ~flatOK
                options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Continue this time' );
                
                text = [
                    'At least one channel in the file ''%s'' is flat.\n\n' ...
                    'How do you want to proceed?' ];
                text = sprintf ( text, files { file } );
                
                answer = questdlg ( text, 'HERMES - Importing question', 'Continue this time', 'Ignore all', 'Cancel', options );
                
                if strcmp ( answer, 'Ignore all' ), flatOK = true;
                elseif strcmp ( answer, 'Cancel' ), H_stop ( true );
                end
            end
            
            % Fulfulls the size data for the record.
            project.origindata ( index ).dimensions = size ( filedata );
            
            % Adds the new group of trials to the matrix.
            data = cat ( 3, data, filedata );
        end
        
        % Stores the information and check data for the subject.
        project.statistical ( subject ).trials ( condition ) = size ( data, 3 );
        project.statistical ( subject ).check ( condition, [ 1 2 ] ) = H_checksum ( data, project.version );
        
        % Saves the data without compression.
        save ( '-mat', '-v6', H_path ( 'temp', subject, condition ), 'data'  );
        
        % Checks for user cancelation.
        if ( H_stop ), project = []; return, end
        
        % Updates the waitbar.
        waitbar.progress (1) = index;
        waitbar = H_waitbar ( waitbar );
    end
end

% Deletes the waitbar.
delete ( waitbar.handle );

% Fills the data information.
project.samples  = size ( data, 1 );
project.channels = size ( data, 2 );

% Fills the project metadata with the first file information.
project.source   = filesinfo (1).source;
project.fs       = filesinfo (1).fs;
project.baseline = filesinfo (1).baseline;

if filesinfo (1).type, project.type = 'with trials';
else                   project.type = 'continuous';
end


% Sets the channels labels, if not defined.
project.sensors.label    = filesinfo (1).label;
project.sensors.labelled = ~isempty ( project.sensors.label );
if isempty ( project.sensors.label )
    project.sensors.label = cellfun ( @sprintf, repmat ( { 'ch%03g' }, project.channels, 1 ), num2cell ( ( 1: project.channels )' ), 'UniformOutput', false );
end


% Gets the sampling rate, if needed.
while isnan ( project.fs ) || ~isreal ( project.fs ) || project.fs <= 0
    
    text = 'Sampling rate (Hz):';
    answer = inputdlg ( text, 'HERMES - Importing question', 1, { '' }, erropts );
    project.fs = str2double ( answer );
    
    if isempty ( answer )
        project = [];
        return
    end
end

% Gets the baseline duration, if needed.
while isnan ( project.baseline ) || ~isreal ( project.baseline ) || project.baseline < 0
    
    text   = 'Baseline duration (ms):';
    answer = inputdlg ( text, 'HERMES - Importing question', 1, { '' }, erropts );
    project.baseline = str2double ( answer );

    if isempty ( answer )
        project = [];
        return
    end
end

% Builds the time vector.
project.time = ( 0: project.samples - 1 ) / project.fs * 1000 - project.baseline;

% Gets the layout for visualization.
project = H_layout ( project );

% Promts a message indicating the success.
text = 'All files successfully loaded';
warndlg ( text, 'HERMES - New project', erropts )
