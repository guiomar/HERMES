function filesinfo = H_checkFiles ( files )
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
% Authors:  Guiomar Niso, Ricardo Bruna, 2013
%


% Deleting of the stop flag.
H_stop (0);

% Puts the one single file in cell form.
if ischar ( files ), files = { files }; end

% Creates the error options variable.
erropts  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' ,'Color', [ .9 .9 .9 ]);

% Creates the output array of structures.
filesinfo = struct ( 'filename', files, 'source', '', 'label', '', 'dimensions', [], 'type', [], 'fs', [], 'baseline', [] );

% Creates the waitbar.
waitbar.start    = clock;
waitbar.handle   = [];
waitbar.title    = 'HERMES - New project';
waitbar.message  = 'Checking data integrity...';
waitbar.tic      = clock;
waitbar.progress = [ 0 numel( files ) ];
waitbar = H_waitbar ( waitbar );

% Goes through all files.
for file = 1: numel ( files )
    
    % Loads the file.
    [ data, separator ] = importdata ( files { file } );
    
    % If the file contains a FieldTrip structure.
    if is_ft ( data )
        
        % Chechs that all the trials has the same size.
        if any ( std ( cell2mat ( cellfun ( @size, data.trial, 'UniformOutput', false )' ), 0, 1 ) > 1e-10 )
            
            text = 'Not all the trials in the file %s are equal.';
            text = sprintf ( text, files { file } );
            errordlg ( text, 'HERMES - Importing error', erropts )
            
            filesinfo = [];
            delete ( waitbar.handle );
            return
        end
        
        % Gets the data matrix and the time labels.
        matrix = cell2mat ( permute ( data.trial, [ 1 3 2 ] ) );
        time   = cell2mat ( permute ( data.time,  [ 2 1 ] ) );
        
        % Checks that all the trials have the same time labels.
        if ~isequal ( data.time {:} )
            
            text = 'Not all the trials in the file %s are equal.';
            text = sprintf ( text, files { file } );
            errordlg ( text, 'HERMES - Importing error', erropts )
            
            filesinfo = [];
            delete ( waitbar.handle );
            return
        end
        
        
        % Sets the origin of the file.
        filesinfo ( file ).source     = 'FieldTrip files';
        
        % Gets the data dimensions.
        filesinfo ( file ).type       = H_size ( matrix, 3 ) > 1;
        filesinfo ( file ).dimensions = H_size ( matrix, 1: 2 );
        
        % Gets the channel labels and the sampling frequency.
        filesinfo ( file ).label      = data.label;
        filesinfo ( file ).fs         = data.fsample;
        
        % Gets the baseline length (in milliseconds) from the first trial.
%         filesinfo ( file ).baseline   = 1000 * sum ( time ( 1, : ) < 0 ) / filesinfo ( file ).fs;
        filesinfo ( file ).baseline   = 1000 * sum ( data.time {1} < 0 ) / filesinfo ( file ).fs;
        
    % If the file contains a matrix.
    elseif isnumeric ( data )
        
        % Checks that the matrix has 2 or 3 dimensions.
        if numel ( size ( data ) > 1 ) < 2
            text = [
                'Wrong data dimensions. Data matrix has only one dimension.\n\n' ...
                'It is not possible to perform a connectivity analysis with only one vector.' ];
            text = sprintf ( text );
            errordlg ( text, 'HERMES - Importing error', erropts )
            
            filesinfo = [];
            delete ( waitbar.handle );
            return
            
        elseif ndims ( data ) > 3
            text = [
                'Wrong data dimensions. Data matrix has more than three dimensions.\n\n' ...
                'The structure of data matrix must be samples x channels x trials.' ];
            text = sprintf ( text );
            errordlg ( text, 'HERMES - Importing error', erropts )
            
            filesinfo = [];
            delete ( waitbar.handle );
            return
        end
        
        
        % Sets the origin of the file.
        if isnan ( separator ), filesinfo ( file ).source = 'MAT raw files';
        else                    filesinfo ( file ).source = 'ASCII files';
        end
        
        % Gets the data dimensions.
        filesinfo ( file ).type       = H_size ( data, 3 ) > 1;
        filesinfo ( file ).dimensions = H_size ( data, 1: 2 );
        
        % If the type is continous sets the baseline to 0.
        if ~filesinfo ( file ).type, filesinfo ( file ).baseline = 0;
        end
        
    % Otherwise exits.
    else
        [ tmp, basename, ext ] = fileparts  ( files { file } );
        
        text = 'The data type of at least one of the selected files (%s) is unknown.';
        text = sprintf ( text, strcat ( basename, ext ) );
        errordlg ( text, 'HERMES - Importing error', erropts )
        
        filesinfo = [];
        delete ( waitbar.handle );
        return
    end
    
    % Checks for user cancelation.
    if ( H_stop ), filesinfo = []; return, end
    
    % Updates the waitbar.
    waitbar.progress (1) = file;
    waitbar = H_waitbar ( waitbar );
end


% Updates the waitbar.
waitbar.message  = 'Checking that all the data files has the same properties...';
waitbar = H_waitbar ( waitbar );

% Checks that all the files have the same source.
if numel ( filesinfo ) > 1 && ~isequal ( filesinfo.source )
    
    text = 'Not all the data files have the same source.';
    text = sprintf ( text, files { file } );
    errordlg ( text, 'HERMES - Importing error', erropts )
    
    filesinfo = [];
    delete ( waitbar.handle );
    return
end

% Checks that all the files have the same dimensions.
if numel ( filesinfo ) > 1 && ~isequal ( filesinfo.dimensions )
    
    text = 'Not all the data files have the same dimensions.';
    text = sprintf ( text, files { file } );
    errordlg ( text, 'HERMES - Importing error', erropts )
    
    filesinfo = [];
    delete ( waitbar.handle );
    return
end

% Checks that all the files have the same channel labels.
if numel ( filesinfo ) > 1 && ~isequal ( filesinfo.label )
    
    text = 'Not all the data files have the same set of channels.';
    text = sprintf ( text, files { file } );
    errordlg ( text, 'HERMES - Importing error', erropts )
    
    filesinfo = [];
    delete ( waitbar.handle );
    return
end

% Checks that all the files have the same baseline length.
if numel ( filesinfo ) > 1 && ~isequal ( filesinfo.baseline )
    
    text = 'Not all the data files have the same baseline length.';
    text = sprintf ( text, files { file } );
    errordlg ( text, 'HERMES - Importing error', erropts )
    
    filesinfo = [];
    delete ( waitbar.handle );
    return
end

% Checks that all the files have the same type.
if numel ( filesinfo ) > 1 && ~isequal ( filesinfo.type )
    
    text = 'Some of the data files have trials and some of them not.';
    text = sprintf ( text, files { file } );
    errordlg ( text, 'HERMES - Importing error', erropts )
    
    filesinfo = [];
    delete ( waitbar.handle );
    return
end

% Checks that all the files have the same samplaing rate.
if numel ( filesinfo ) > 1 && ~isequal ( filesinfo.fs )
    
    text = 'Not all the data files have the same sampling rate.';
    text = sprintf ( text, files { file } );
    errordlg ( text, 'HERMES - Importing error', erropts )
    
    filesinfo = [];
    delete ( waitbar.handle );
    return
end

% Sets to NaN the empty values.
if isempty ( [ filesinfo.fs ] ),       [ filesinfo.fs ]       = deal ( nan ); end
if isempty ( [ filesinfo.baseline ] ), [ filesinfo.baseline ] = deal ( nan ); end

% Deletes the waitbar.
delete ( waitbar.handle );


function output = is_ft ( input )

% Initializes the output.
output = false;

% If the input is not an structure, exits.
if ~isstruct ( input ), return, end

% Checks that the structure has all the required fields.
if ~isfield ( input, 'label' ),   return, end
if ~isfield ( input, 'trial' ),   return, end
if ~isfield ( input, 'time' ),    return, end
if ~isfield ( input, 'fsample' ), return, end

% Checks that there is as many time cells as trial cells.
if numel ( input.time ) ~= numel ( input.trial ), return, end

output = true;