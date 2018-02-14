function varargout = HERMES_NewProject(varargin)
% HERMES_NewProject M-file for HERMES_NewProject.fig
%      HERMES_NewProject, by itself, creates a new HERMES_NewProject or raises the existing
%      singleton*.
%
%      H = HERMES_NewProject returns the handle to a new HERMES_NewProject or the handle to
%      the existing singleton*.
%
%      HERMES_NewProject('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_NewProject.M with the given input arguments.
%
%      HERMES_NewProject('Property','Value',...) creates a new HERMES_NewProject or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_GSparameters_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_NewProject_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Copyright 2002-2003 The MathWorks, Inc.
% Edit the above text to modify the response to help HERMES_NewProject
% Last Modified by GUIDE v2.5 14-Jun-2012 04:11:59
% Begin initialization code - DO NOT EDIT
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
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_NewProject_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_NewProject_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% Deactivation of the unwanted warnings.
%#ok<*INUSL,*INUSD,*DEFNU,*ST2NM>

function HERMES_NewProject_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

set ( hObject, 'WindowStyle', 'modal' )

handles.output  = [];
handles.project = [];
guidata ( hObject, handles )

set ( hObject, 'WindowStyle', 'normal' )
uiwait ( hObject );


function load_Callback ( hObject, eventdata, handles )

% Deleting of the stop flag.
H_stop (0);

% Requests files selection.
[ files, path ] = uigetfile ( { '*.mat', 'MAT-files (*.mat)'; '*.txt;*.ascii', 'ASCII files (*.txt, *.ascii)' }, 'Selected the file(s) to load', 'MultiSelect', 'on');
if path == 0, return, end

% Checks that all the files have the same origin and dimensions.
filesinfo = H_checkFiles ( strcat ( path, files ) );
if isempty ( filesinfo ), return, end

% Request labelling data or fills with the defaults.
if iscellstr ( files ), labels = HERMES_LabelData ( files );
else                    labels = { files 'Subject' 'Group' 'Condition' };
end
if isempty ( labels ), return, end

% Project creation, data importing and data labelling.
project = H_import ( path, labels, filesinfo );
if ( ~isstruct ( project ) )
                    
    % Deletes the waitbar and exits.
    delete ( findobj ( 'tag', 'H_waitbar' ) );
    return
end

% Sets the number of groups and conditions in the GUI.
if numel ( project.groups ) > 1
    set ( handles.groups_text,     'Enable', 'on' )
    set ( handles.groups,          'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
    
    set ( handles.groups,          'String', numel ( project.groups ) )
else
    set ( handles.groups_text,     'Enable', 'off' )
    set ( handles.groups,          'Enable', 'off' )
    
    set ( handles.groups,          'String', '' )
end
if numel ( project.conditions ) > 1
    set ( handles.conditions_text, 'Enable', 'on' )
    set ( handles.conditions,      'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
    
    set ( handles.conditions,      'String', numel ( project.conditions ) )
else
    set ( handles.conditions_text, 'Enable', 'off' )
    set ( handles.conditions,      'Enable', 'off' )
    
    set ( handles.conditions,      'String', '' )
end

% Sets the project groups of the data in the GUI.
switch project.type 
    case 'continuous'
        set ( handles.type_text,        'Enable', 'on' )
        set ( handles.type,             'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
        set ( handles.prestimulus_text, 'Enable', 'off' )
        set ( handles.prestimulus,      'Enable', 'off' )

        set ( handles.type,             'String', 'Continous data' )
        set ( handles.prestimulus,      'String', '' )
        
    case 'with trials'
        set ( handles.type_text,        'Enable', 'on' )
        set ( handles.type,             'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
        set ( handles.prestimulus_text, 'Enable', 'on' )
        set ( handles.prestimulus,      'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )

        set ( handles.type,             'String', 'Data with trials' )
        set ( handles.prestimulus,      'String', project.baseline )
end

% Sets the data information in the GUI.
set ( handles.subjects_text, 'Enable', 'on' )
set ( handles.subjects,      'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
set ( handles.channels_text, 'Enable', 'on' )
set ( handles.channels,      'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
set ( handles.fs_text,       'Enable', 'on' )
set ( handles.fs,            'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )
set ( handles.length_text,   'Enable', 'on' )
set ( handles.length,        'Enable', 'inactive', 'BackgroundColor', [ .9 .9 .9 ] )

set ( handles.subjects,      'String', numel ( project.subjects ) );
set ( handles.channels,      'String', project.channels );
set ( handles.fs,            'String', project.fs );
set ( handles.length,        'String', 1000 * project.samples / project.fs );

% Stores the project.
handles.project = project;
guidata ( hObject, handles );

% Calls the name text box callback.
name_Callback ( handles.name, eventdata, handles )


function name_Callback ( hObject, eventdata, handles )

% Checks if all fields are fulfilled and enables the OK button.
if isempty ( get ( hObject, 'string' ) ), set ( handles.OK, 'Enable', 'off' )
elseif ~isempty ( handles.project )     , set ( handles.OK, 'Enable', 'on' )
end


function OK_Callback ( hObject, eventdata, handles )
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Replace' );

filename = regexprep ( get ( handles.name, 'String' ), '[/\\?%*:|"<> ]', '_' );

% Checks if theproject has been created by loading data files.
if ~isfield ( handles, 'project' )
    
    text = 'No files have been loaded.';
    errordlg ( text, 'HERMES - Project creation error', options )
    
    return
end

% Checks if has been provided a name for the project.
if isempty ( get ( handles.name, 'String' ) )
    
    text = 'The project can not be created without a title.';
    errordlg ( text, 'HERMES - Project creation error', options )
    
    return
end

% Checks if the project name is avaliable.
if exist ( H_path ( 'Projects', filename ), 'dir' )
    
    text = 'There already exists a project with the same or a very similar name.';
    errordlg ( text, 'HERMES - Project creation error', options )
    
    return
end

% Saves the configuration.
project = handles.project;

project.name        = get ( handles.name,        'String' );
project.description = get ( handles.description, 'String' );
project.filename    = filename;

% Creates the project folder and moves the data.
mkdir ( H_path ( 'Projects', filename ) );
movefile ( H_path ( 'temp', '*' ), H_path ( 'Projects', filename ) );
rmdir ( H_path ( 'temp' ), 's' )

% Calculates the whole window autocorrelation time.
project.defaults.act = H_GSdefaults ( project );

% Saves the project file.
save ( '-mat', '-v6', H_path ( 'Projects', project, 'project' ), 'project' );

% If everying went OK, exits.
handles.output = project;
guidata ( hObject, handles )
uiresume


function cancel_Callback ( hObject, eventdata, handles )
% Deletes the temporal folder.
if exist ( H_path ( 'temp' ), 'dir' ), rmdir ( H_path ( 'temp' ), 's' ); end

uiresume


function NewProject_CloseRequestFcn ( hObject, eventdata, handles ), uiresume


function NewProject_WindowKeyPressFcn ( hObject, eventdata, handles )
if strcmp ( eventdata.Key, 'escape' ), uiresume, end


function varargout = HERMES_NewProject_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;
delete ( hObject )
