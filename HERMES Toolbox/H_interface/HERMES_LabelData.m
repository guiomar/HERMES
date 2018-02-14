function varargout = HERMES_LabelData(varargin)
% HERMES_LABELDATA M-file for HERMES_LabelData.fig
%      HERMES_LABELDATA, by itself, creates a new HERMES_LABELDATA or raises the existing
%      singleton*.
%
%      H = HERMES_LABELDATA returns the handle to a new HERMES_LABELDATA or the handle to
%      the existing singleton*.
%
%      HERMES_LABELDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_LABELDATA.M with the given input arguments.
%
%      HERMES_LABELDATA('Property','Value',...) creates a new HERMES_LABELDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_LabelData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_LabelData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% edit_groups the above text to modify the response to help HERMES_LabelData
%
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


% Begin initialization code - DO NOT EDIT_GROUPS
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_LabelData_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_LabelData_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
% end

% If no input, exits.
elseif ~nargin || ~numel ( varargin {1} )  || ~iscellstr ( varargin {1} )
    return
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT_GROUPS

% Deactivation of the unwanted warnings.
%#ok<*INUSL,*INUSD,*DEFNU,*ST2NM>


% --- Executes just before HERMES_LabelData is made visible.
function HERMES_LabelData_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Gets the filenames.
handles.data.filenames = varargin {1};

% Initializes the labels.
handles.data.subjects   = {};
handles.data.groups     = {};
handles.data.conditions = {};

% Clear the data in the tables.
set ( handles.groups_table, 'Data', {} )
set ( handles.files_table,  'Data', {} )

% Choose default command line output for HERMES_LabelData
handles.output = [];

% Update handles structure
guidata ( hObject, handles );
uiwait ( hObject )


function subjects_auto_Callback ( hObject, eventdata, handles )

% Creates the option variables.
erropts = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );
subjects  = 0;

% Gets the number of groups.
while H_checkOR ( subjects, '~real', '~int', 'NaN', 'Inf', 'lt1' )
    
    text = 'Number of subjects:';
    answer = inputdlg ( text, 'HERMES - Data labelling question', 1, { '' }, erropts );
    subjects = str2double ( answer );
    
    if isempty ( answer ), return, end
end

% Creates and sets the labels.
labels = autolabel ( 'Subject', subjects );
set ( handles.subjects, 'String', labels );


function groups_auto_Callback ( hObject, eventdata, handles )

% Creates the option variables.
erropts = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );
groups  = 0;

% Gets the number of groups.
while H_checkOR ( groups, '~real', '~int', 'NaN', 'Inf', 'lt1' )
    
    text = 'Number of groups:';
    answer = inputdlg ( text, 'HERMES - Data labelling question', 1, { '' }, erropts );
    groups = str2double ( answer );
    
    if isempty ( answer ), return, end
end

% Creates and sets the labels.
labels = autolabel ( 'Group', groups );
set ( handles.groups, 'String', labels );


function conditions_auto_Callback ( hObject, eventdata, handles )

% Creates the option variables.
erropts = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );
conditions  = 0;

% Gets the number of groups.
while H_checkOR ( conditions, '~real', '~int', 'NaN', 'Inf', 'lt1' )
    
    text = 'Number of conditions:';
    answer = inputdlg ( text, 'HERMES - Data labelling question', 1, { '' }, erropts );
    conditions = str2double ( answer );
    
    if isempty ( answer ), return, end
end

% Creates and sets the labels.
labels = autolabel ( 'Condition', conditions );
set ( handles.conditions, 'String', labels );


function save_labels_Callback ( hObject, eventdata, handles )
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );

% Gets the labels.
handles.data.subjects   = strtrim ( regexp ( get ( handles.subjects,   'String' ), ',', 'split' ) );
handles.data.groups     = strtrim ( regexp ( get ( handles.groups,     'String' ), ',', 'split' ) );
handles.data.conditions = strtrim ( regexp ( get ( handles.conditions, 'String' ), ',', 'split' ) );

% Deletes the empty string and the repeated values.
handles.data.subjects   = unique ( handles.data.subjects   ( ~strcmp ( handles.data.subjects,   '' ) ) );
handles.data.groups     = unique ( handles.data.groups     ( ~strcmp ( handles.data.groups,     '' ) ) );
handles.data.conditions = unique ( handles.data.conditions ( ~strcmp ( handles.data.conditions, '' ) ) );

% If there is no values for some field, sets it to autofill.
if isempty ( handles.data.subjects ),   handles.data.subjects   = { 'Subject'   }; end
if isempty ( handles.data.groups ),     handles.data.groups     = { 'Group'     }; end
if isempty ( handles.data.conditions ), handles.data.conditions = { 'Condition' }; end

% Checks that the number of files is equal or greater to the total.
if numel ( handles.data.filenames ) < numel ( handles.data.subjects ) * numel ( handles.data.conditions )
    text = [
        'The combinations of subject and condition are greater than the number of files.\n' ...
        'This makes impossible that all subjects have all conditions.' ];
    text = sprintf ( text );
    
    errordlg ( text, 'HERMES - Data labeling error', options )
    return
    
% Checks that the number of subjects is greater or equal that te number of
% groups.
elseif numel ( handles.data.groups ) && numel ( handles.data.groups ) > numel ( handles.data.subjects )
    text = [
        'The number of groups is greater han the number of subjects.\n' ...
        'This makes impossible that all groups have at least one member.' ];
    text = sprintf ( text );
    
    errordlg ( text, 'HERMES - Data labeling error', options )
    return
end

% Disables the labels section.
set ( handles.subjects,    'Enable', 'off' )
set ( handles.groups,      'Enable', 'off' )
set ( handles.conditions,  'Enable', 'off' )
set ( handles.save_labels, 'Enable', 'off' )

set ( handles.edit_labels, 'Enable', 'on' )
set ( handles.saveCSV,     'Enable', 'on' )


% Selects the configuration for the groups table.
table1.editable = false ( 1, 2 );
table1.data     = handles.data.subjects (:);
table1.format   = { 'char' };

if numel ( handles.data.groups ) == 1
    table1.editable (2)      = false;
    table1.data     ( :, 2 ) = handles.data.groups;
    table1.format   {2}      = 'char';
else
    table1.editable (2)      = true;
    table1.data     ( :, 2 ) = { '' };
    table1.format   {2}      = handles.data.groups;
end


% Selects the configuration for the files table.
table2.editable = false;
table2.data     = handles.data.filenames (:);
table2.format   = { 'char' };

if numel ( handles.data.subjects ) == 1
    table2.editable (2)      = false;
    table2.data     ( :, 2 ) = handles.data.subjects;
    table2.format   {2}      = 'char';
else
    table2.editable (2)      = true;
    table2.data     ( :, 2 ) = { '' };
    table2.format   {2}      = handles.data.subjects;
end

if numel ( handles.data.conditions ) == 1
    table2.editable (3)      = false;
    table2.data     ( :, 3 ) = handles.data.conditions;
    table2.format   {3}      = 'char';
else
    table2.editable (3)      = true;
    table2.data     ( :, 3 ) = { '' };
    table2.format   {3}      = handles.data.conditions;
end


% Sets the table configuration.
set ( handles.groups_table, 'Enable', 'on', 'ColumnEditable', table1.editable, 'Data', table1.data, 'ColumnFormat', table1.format )
set ( handles.files_table,  'Enable', 'on', 'ColumnEditable', table2.editable, 'Data', table2.data, 'ColumnFormat', table2.format )

% Update handles structure
guidata ( hObject, handles );


function edit_labels_Callback ( hObject, eventdata, handles )

% Diables the group and condition selection tables.
set ( handles.groups_table, 'Enable', 'off' )
set ( handles.files_table,  'Enable', 'off' )
set ( handles.edit_labels,  'Enable', 'off' )
set ( handles.saveCSV,      'Enable', 'off' )

% Enables the labels section.
set ( handles.subjects,     'Enable', 'on' )
set ( handles.groups,       'Enable', 'on' )
set ( handles.conditions,   'Enable', 'on' )
set ( handles.save_labels,  'Enable', 'on' )

% Clear the data in the tables.
set ( handles.groups_table, 'Data', {} )
set ( handles.files_table,  'Data', {} )


function saveCSV_Callback ( hObject, eventdata, handles )

% Checks that the data is correct.
if ~checkTables ( handles ), return, end

% Asks for the route to the CSV file to write.
[ filename, path ] = uiputfile ( '*.csv', 'Select the file to write', 'labels.csv' );

% If no file selected, exits.
if ~ischar ( filename ), return, end

% Gets the tables.
files_table  = get ( handles.files_table,  'Data' );
groups_table = get ( handles.groups_table, 'Data' );

% Combines both tables.
table = combineTables ( files_table, groups_table );

% Saves the CSV file in the specified location.
writeTable ( table, strcat ( path, filename ) )


function loadCSV_Callback ( hObject, eventdata, handles )
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );

% Asks for the route to the CSV file.
[ filename, path ] = uigetfile ( '*.csv', 'Select the file to read' );

% If no file selected, exits.
if ~ischar ( filename ), return, end

% Loads the table from the file.
table = readTable ( strcat ( path, filename ) );
if isempty ( table ), return, end

% Gets the labels.
filenames  = unique ( table ( :, 1 ) );
subjects   = unique ( table ( :, 2 ) );
groups     = unique ( table ( :, 3 ) );
conditions = unique ( table ( :, 4 ) );

% Separates the tables.
[ files_table, groups_table ] = separateTables ( table );

% Checks that the filenames are the same as defined.
if numel ( setxor ( filenames, handles.data.filenames ) )
    text = [
        'The file names from the CSV and the selected in the previous step are not the same.\n\n' ...
        'Please, review your CSV file.' ];
    text = sprintf ( text );
    
    errordlg ( text, 'HERMES - Data labeling error', options )
    return
end

% Fills the labels.
subjects   = sprintf ( '%s, ', subjects   {:} );
groups     = sprintf ( '%s, ', groups     {:} );
conditions = sprintf ( '%s, ', conditions {:} );

set ( handles.subjects,   'String', subjects   ( 1: end - 2 ) )
set ( handles.groups,     'String', groups     ( 1: end - 2 ) )
set ( handles.conditions, 'String', conditions ( 1: end - 2 ) )

% Enables the tables.
save_labels_Callback ( handles.save_labels, eventdata, handles )

% Fills the tables.
set ( handles.files_table,  'Data', files_table )
set ( handles.groups_table, 'Data', groups_table )


function OK_Callback ( hObject, eventdata, handles )

% Checks that the data is correct.
if ~checkTables ( handles ), return, end

% Gets the tables.
files_table  = get ( handles.files_table,  'Data' );
groups_table = get ( handles.groups_table, 'Data' );

% Combines both tables.
handles.output = combineTables ( files_table, groups_table );

guidata ( hObject, handles );
uiresume


function Cancel_Callback           ( hObject, eventdata, handles ), uiresume
function LabelData_CloseRequestFcn ( hObject, eventdata, handles ), uiresume


function varargout = HERMES_LabelData_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;

delete ( hObject );





function output_table = combineTables ( files_table, groups_table )

% Fills the last dimension with the group of the subject.
for file = 1: size ( files_table, 1 )
    files_table ( file, 4 ) = groups_table ( strcmp ( groups_table ( :, 1 ), files_table ( file, 2 ) ), 2 );
end

% Permutes last two dimensions.
output_table = files_table ( :, [ 1 2 4 3 ] );


function [ files_table, groups_table ] = separateTables ( input_table )
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );

% Gets the files table by discarding the third column.
files_table  = input_table ( :, [ 1 2 4 ] );

% Initializes the groups table.
subjects     = unique ( input_table ( :, 2 ) );
groups_table = subjects;

% Goes through each subject.
for subject = 1: numel ( subjects )
    
    % Checks that the subject has allways the same group.
    group = unique ( input_table ( strcmp ( subjects { subject }, input_table ( :, 2 ) ), 3 ) );
    if numel ( group ) > 1
        text = [
            'At least one subject in the CSV file is assigned to more than one group.\n\n' ...
            'Please, review your CSV file.' ];
        text = sprintf ( text );
        
        errordlg ( text, 'HERMES - Data labeling error', options )
        return
    end
    
    % If everything is correct, saves the subject's group.
    groups_table ( subject, 2 ) = group;
end


function writeTable ( table, file )

% Opens the file to write.
fid = fopen ( file, 'w' );

% Goes through each row of data.
for row = 1: size ( table, 1 )
    
    % Set the string as CSV and deletes last comma.
    string = sprintf ( '%s, ', table { row, : } );
    string = string ( 1: end - 2 );
    
    % Writes out the table to a CSV file.
    fprintf ( fid, '%s\n', string );
end

% Closes the file.
fclose ( fid );


function table = readTable ( file )

% Opens the file to read.
fid = fopen ( file, 'r' );

% Reads the file into the table.
text  = textscan ( fid, '%s', 'delimiter', { ', ' } );
table = text {1};

% Checks that the tables has a multiple of 4 entries.
if rem ( numel ( table ), 4 ), table = {}; return, end

% Reshapes the table as an n x 4 cell array.
table = reshape ( table, 4, [] )';

% Closes the file.
fclose ( fid );


function output = checkTables ( handles )
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Initializes the output.
output = false;

% Gets the tables.
files_table  = get ( handles.files_table,  'Data' );
groups_table = get ( handles.groups_table, 'Data' );

% Checks if the labels are defined.
if strcmp ( get ( handles.files_table, 'Enable' ), 'off' )
    text = 'The labels are not correctly defined.';
    text = sprintf ( text );
    
    errordlg ( text, 'HERMES - Data labeling error', options )
    return
end

% Checks if all the possible data is fulfilled.
if any ( strcmp ( groups_table (:), '' ) ) || any ( strcmp ( files_table (:), '' ) )
    text = [
        'Not all the fields in the files table are filled.\n\n' ...
        'All fields must be filled.' ];
    text = sprintf ( text );
    
    errordlg ( text, 'HERMES - Data labeling error', options )
    return
    
end

% Checks that all subjects are used.
if ~all ( ismember ( handles.data.subjects, files_table ( :, 2 ) ) )
    text = [
        'One or more subjects has no files assigned to it.\n\n' ...
        'Is this correct? If you decide to continue, this subjects will be removed.' ];
    text = sprintf ( text );

    if ~strcmp ( questdlg ( text, 'HERMES - Data labeling question', 'Yes', 'No', options ), 'Yes' )
        return
    end
end

% Checks that all groups are used.
if ~all ( ismember ( handles.data.groups, groups_table ( :, 2 ) ) )
    text = [
        'One or more groups are empty (there are no subjects assigned to them).\n\n' ...
        'Is this correct? If you decide to continue, this groups will be removed.' ];
    text = sprintf ( text );
    
    if ~strcmp ( questdlg ( text, 'HERMES - Data labeling question', 'Yes', 'No', options ), 'Yes' )
        return
    end
end

% Checks if all groups have a similar number of subjects.
% TO-DO

% Checks that all conditions are used.
if ~all ( ismember ( handles.data.conditions, files_table ( :, 3 ) ) )
    text = [
        'One or more conditions has no files assigned to it.\n\n' ...
        'Is this correct? If you decide to continue, this conditions will be removed.' ];
    text = sprintf ( text );
    
    if ~strcmp ( questdlg ( text, 'HERMES - Data labeling question', 'Yes', 'No', options ), 'Yes' )
        return
    end
end

% Checks if all subjects have all conditions.
for subject = 1: numel ( handles.data.subjects )
    for condition = 1: numel ( handles.data.conditions )
        if ~any ( strcmp ( files_table ( :, 3 ), handles.data.conditions { condition } ) & strcmp ( files_table ( :, 2 ), handles.data.subjects { subject } ) )
            text = [
                'No file is asigned to the subject %s in the condition %s.\n\n' ...
                'Is this correct? Remember that this could cause some problems while performing statistical analyses.' ];
            text = sprintf ( text, handles.data.subjects { subject }, handles.data.conditions { condition } );
            
            if ~strcmp ( questdlg ( text, 'HERMES - Data labeling question', 'Yes', 'No', options ), 'Yes' )
                return
            end
        end
    end
end

% Checks if a subject/condition combination is splitted into several files.
if numel ( strcat ( files_table ( :, 2 ), ',', files_table ( :, 3 ) ) ) ~= numel ( unique ( strcat ( files_table ( :, 2 ), ',', files_table ( :, 3 ) ) ) )
    text = [
        'Some combinations of subject and condition seem to be splitted in two or more files.\n\n' ...
        'Is this correct?' ];
    text = sprintf ( text );

    if ~strcmp ( questdlg ( text, 'HERMES - Data labeling question', 'Yes', 'No', options ), 'Yes' )
        return
    end
end

% Sets the output.
output = true;
