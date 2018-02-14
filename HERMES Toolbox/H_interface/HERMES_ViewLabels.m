function varargout = HERMES_ViewLabels(varargin)
% HERMES_VIEWLABELS M-file for HERMES_ViewLabels.fig
%      HERMES_VIEWLABELS, by itself, creates a new HERMES_VIEWLABELS or raises the existing
%      singleton*.
%
%      H = HERMES_VIEWLABELS returns the handle to a new HERMES_VIEWLABELS or the handle to
%      the existing singleton*.
%
%      HERMES_VIEWLABELS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_VIEWLABELS.M with the given input arguments.
%
%      HERMES_VIEWLABELS('Property','Value',...) creates a new HERMES_VIEWLABELS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_ViewLabels_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_ViewLabels_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% edit_groups the above text to modify the response to help HERMES_ViewLabels
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
% Authors:  Guiomar Niso, Ricardo Bruna, 2012
%


% Begin initialization code - DO NOT EDIT_GROUPS
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_ViewLabels_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_ViewLabels_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
% end

% If no input, exits.
elseif ~nargin || ~numel ( varargin {1} ) || ~isstruct ( varargin {1} )
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


function HERMES_ViewLabels_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Gets the project data.
project = varargin { 1 };

% Gets the list of subjects, groups and conditions.
subjects   = sprintf ( '%s, ', project.subjects   {:} );
groups     = sprintf ( '%s, ', project.groups     {:} );
conditions = sprintf ( '%s, ', project.conditions {:} );

% Fills the labels list.
set ( handles.subjects,   'String', subjects   ( 1: end - 2 ) );
set ( handles.groups,     'String', groups     ( 1: end - 2 ) );
set ( handles.conditions, 'String', conditions ( 1: end - 2 ) );

% Sets the groups table.
groups_table ( :, 1 ) = project.subjects;
groups_table ( :, 2 ) = project.groups ( [ project.statistical.group ]' );
set ( handles.groups_table, 'Data', groups_table );

% Sets the files table.
files_table ( :, 1 ) = basename ( { project.origindata.filename } );
files_table ( :, 2 ) = project.subjects ( [ project.origindata.subject ] );
files_table ( :, 3 ) = project.conditions ( [ project.origindata.condition ] );
set ( handles.files_table, 'Data', files_table );

uiwait


function OK_Callback                 ( hObject, eventdata, handles ), uiresume
function Cancel_Callback             ( hObject, eventdata, handles ), uiresume
function ViewLabels_CloseRequestFcn  ( hObject, eventdata, handles ), uiresume

function HERMES_ViewLabels_OutputFcn ( hObject, eventdata, handles ), delete ( hObject );



function output = basename ( fullname )

% If only one input, gets the base name.
if ischar ( fullname )
    [ tmp, filename, extension ] = fileparts ( fullname );
    output = strcat ( filename, extension );
    
% Otherwise goes through all the names.
elseif iscellstr ( fullname )
    
    % Reserves memory.
    output = cell ( size ( fullname ) );
    
    for file = 1: numel ( fullname )
        
        % Gets the base name.
        [ tmp, filename, extension ] = fileparts ( fullname { file } );
        output { file } = strcat ( filename, extension );
    end
else output = [];
end