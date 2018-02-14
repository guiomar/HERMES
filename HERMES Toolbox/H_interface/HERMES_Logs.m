function varargout = HERMES_Logs(varargin)
% HERMES_LOGS MATLAB code for HERMES_Logs.fig
%      HERMES_LOGS, by itself, creates a new HERMES_LOGS or raises the existing
%      singleton*.
%
%      H = HERMES_LOGS returns the handle to a new HERMES_LOGS or the handle to
%      the existing singleton*.
%
%      HERMES_LOGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_LOGS.M with the given input arguments.
%
%      HERMES_LOGS('Property','Value',...) creates a new HERMES_LOGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_Logs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_Logs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help HERMES_Logs
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
                   'gui_OpeningFcn', @HERMES_Logs_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_Logs_OutputFcn, ...
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


function HERMES_Logs_OpeningFcn(hObject, eventdata, handles, varargin)

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Checks if there is a project.
if nargin < 4, close ( hObject ), return, end
handles.data.project = varargin {1};

handles.data.logs = H_load ( handles.data.project, 'logs' );
handles.data.logs = handles.data.logs ( end: -1: 1 );

handles.data.log = '';

% Fills the list of logs, if any.
if numel ( handles.data.logs )
    
    set ( handles.logs, 'String', { handles.data.logs.description } );
    set ( handles.logs, 'Enable', 'on' );
    
    % Calls the logs list callback to load the last log.
    logs_Callback ( handles.logs, eventdata, handles )
    handles = guidata ( hObject );
end

guidata ( hObject, handles );


function logs_Callback ( hObject, eventdata, handles )

% Loads the project log.
log = H_load ( handles.data.project, 'logs', numel ( get ( hObject, 'String' ) ) - get ( hObject, 'Value' ) + 1 );

% Displays the log and stores it in the handles data.
set ( handles.log, 'String', log );
handles.data.log = log;

set ( handles.toClipboard, 'Enable', 'on' );

guidata ( hObject, handles );


function toClipboard_Callback ( hObject, eventdata, handles )

% Copies the log to the clipboard.
clipboard ( 'copy', handles.data.log );


% --- Outputs from this function are returned to the command line.
function varargout = HERMES_Logs_OutputFcn ( hObject, eventdata, handles )
varargout {1} = [];
