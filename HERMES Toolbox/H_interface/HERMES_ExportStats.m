function varargout = HERMES_ExportStats ( varargin )
% HERMES_EXPORTSTATS M-file for HERMES_ExportStats.fig
%      HERMES_EXPORTSTATS, by itself, creates a new HERMES_EXPORTSTATS or raises the existing
%      singleton*.
%
%      H = HERMES_EXPORTSTATS returns the handle to a new HERMES_EXPORTSTATS or the handle to
%      the existing singleton*.
%
%      HERMES_EXPORTSTATS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_EXPORTSTATS.M with the given input arguments.
%
%      HERMES_EXPORTSTATS('Property','Value',...) creates a new HERMES_EXPORTSTATS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_ExportStats_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_ExportStats_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help HERMES_ExportStats
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
% Authors:  Ricardo Bruna, 2013
%


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_ExportStats_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_ExportStats_OutputFcn, ...
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


function HERMES_ExportStats_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Gets the project information if provided. Exits otherwise.
if nargin < 4, delete ( hObject ), return, end

handles.data.project = varargin {1};
handles.data.runs    = H_load ( handles.data.project, 'statistics' );

if isempty ( handles.data.runs )
    delete ( hObject )
    return
end

% Sets the project information.
info = { ...
    sprintf( 'Project name:\t %s',         handles.data.project.name ) ...
    sprintf( 'Creation date:\t %s at %s',  datestr ( handles.data.project.date, 24 ),  datestr ( handles.data.project.date, 13 ) ) ...
    sprintf( 'Number of subjects:\t %g',   numel ( handles.data.project.subjects ) ) ...
    sprintf( 'Number of groups:\t %g',     numel ( handles.data.project.groups ) ) ...
    sprintf( 'Number of conditions:\t %g', numel ( handles.data.project.conditions ) ) };
set ( handles.information, 'String', info );

% Sets the default indexes filename.
handles.data.filename = H_path ( 'HERMES', 'Output', sprintf ( '%s_stats', handles.data.project.filename ) );

% Replaces the filename for a non-existent one, if needed.
if exist ( sprintf ( '%s.mat', handles.data.filename ), 'file' )
    fileindex = 1;
    while 1
        if ~exist ( sprintf ( '%s (%g).mat', handles.data.filename, fileindex ), 'file' )
            handles.data.filename = sprintf ( '%s (%g).mat', handles.data.filename, fileindex );
            break
        else
            fileindex = fileindex + 1;
        end
    end
else
    handles.data.filename = sprintf ( '%s.mat', handles.data.filename );
end
set ( handles.filename, 'String', handles.data.filename );

% Creates the output directory.
if ~exist ( H_path ( 'HERMES', 'Output' ), 'dir' ), mkdir ( H_path ( 'HERMES', 'Output' ) ), end

% Fills the runs list.
set ( handles.run, 'String', { handles.data.runs.description } );

% Update handles structure
guidata(hObject, handles);

uiwait ( handles.HERMES_ExportIndexes );


function filename_Callback ( hObject, eventdata, handles )

options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Checks if the input is a valid filename.
if ~strcmp ( get ( hObject, 'String' ), regexprep ( get ( hObject, 'String' ), '[?%*:|"<>]', '' ) )
    set ( hObject, 'string', handles.data.filename )
    
    % Promts a message of error.
    text = 'The introduced value is not a valid filename.';
    
    errordlg ( text, 'HERMES - Export indexes error', options )

    return
end

% Changes the output filename.
handles.data.filename = get ( hObject, 'String' );

% Update handles structure
guidata(hObject, handles);


function setFilename_Callback ( hObject, eventdata, handles )

% Changes the current folder to the one selected.
if isdir ( fileparts ( handles.data.filename ) )
    oldpath = cd ( fileparts ( handles.data.filename ) );
else
    oldpath = cd;
end

% Asks for the filename.
[ file, path ] = uiputfile ( '*.mat', 'Save indexes file as...', sprintf ( '%s.mat', handles.data.project.filename ) );

% Restores the current folder.
cd ( oldpath )

% Checks if there was an input.
if path == 0, return, end

% Changes the output filename.
handles.data.filename = sprintf ( '%s%s', path, file );
set ( handles.filename, 'String', handles.data.filename );

% Update handles structure
guidata ( hObject, handles );


function workspace_Callback ( hObject, eventdata, handles )

% Disables or enables the filename box.
if get ( hObject, 'Value' )
    set ( handles.filename,    'Enable', 'off' );
    set ( handles.setFilename, 'Enable', 'off' );
    
else
    set ( handles.filename,    'Enable', 'on' );
    set ( handles.setFilename, 'Enable', 'on' );
end


function OK_Callback ( hObject, eventdata, handles )

% Gets the options.
project  = handles.data.project;
run      = get ( handles.run, 'Value' );
filename = handles.data.filename;

% Marks to export to workspace, if required.
if get ( handles.workspace, 'Value' ), filename = -1; end

% Exports the indexes.
H_exportStats ( project, run, filename )

% Closes the window.
uiresume


function cancel_Callback                      ( hObject, eventdata, handles ), uiresume
function HERMES_ExportIndexes_CloseRequestFcn ( hObject, eventdata, handles ), uiresume
function HERMES_ExportStats_OutputFcn       ( hObject, eventdata, handles ), delete ( hObject )

function HERMES_ExportIndexes_WindowKeyPressFcn ( hObject, eventdata, handles )
if strcmp ( eventdata.Key, 'escape' ), uiresume, end
