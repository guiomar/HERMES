function varargout = HERMES_GSparameters(varargin)
% HERMES_GSparameters M-file for HERMES_GSparameters.fig
%      HERMES_GSparameters, by itself, creates a new HERMES_GSparameters or raises the existing
%      singleton*.
%
%      H = HERMES_GSparameters returns the handle to a new HERMES_GSparameters or the handle to
%      the existing singleton*.
%
%      HERMES_GSparameters('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_GSparameters.M with the given input arguments.
%
%      HERMES_GSparameters('Property','Value',...) creates a new HERMES_GSparameters or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_GSparameters_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_GSparameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Copyright 2002-2003 The MathWorks, Inc.
% Edit the above text to modify the response to help HERMES_GSparameters
% Last Modified by GUIDE v2.5 11-Jan-2013 14:49:25
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
% ** Please cite: ---------------------------------------------------------
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
                   'gui_OpeningFcn', @HERMES_GSparameters_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_GSparameters_OutputFcn, ...
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

function HERMES_GSparameters_OpeningFcn(hObject, eventdata, handles, varargin)

% Sets the default background color.
elements = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

set ( hObject, 'WindowStyle', 'modal' )

handles.output  = varargin {1};
handles.project = varargin {2};

handles.nrec = 10;

if handles.output.statistics
    set ( handles.surrogates,      'Enable', 'on' )
    set ( handles.surrogates_text, 'Enable', 'on' )
end

set ( handles.dimension,  'String', handles.output.EmbDim )
set ( handles.delay,      'String', handles.output.TimeDelay )
set ( handles.neighbours, 'String', handles.output.Nneighbours )
% set ( handles.theiler,    'String', handles.output.Theiler )  
set ( handles.w1_edit,    'String', handles.output.w1 )  %theiler
set ( handles.w2_edit,    'String', handles.output.w2 )
set ( handles.pref_edit,  'String', handles.output.pref )

set ( handles.window,     'String', handles.output.window.length )
set ( handles.overlap,    'String', handles.output.window.overlap )

if strcmp ( handles.output.window.alignment, 'epoch' ),    set ( handles.alignment, 'Value', 1 ), end
if strcmp ( handles.output.window.alignment, 'stimulus' ), set ( handles.alignment, 'Value', 2 ), end

set ( handles.statistics, 'Value',  handles.output.statistics )
set ( handles.surrogates, 'String', handles.output.surrogates )

% Gets the auto-correlation time.
handles.act = handles.project.defaults.act;

% handles.output.w2   = floor ( nrec/handles.output.pref ) + handles.output.w1 -1;

guidata(hObject, handles);
uiwait;


function dimension_Callback(hObject, eventdata, handles)
maxvalue = 10;
minvalue = 2;
optvalue = 3;
str1 = 'GS paramenters warning';
str2 = 'Embeding dimension';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

handles.output.EmbDim = str2double ( get ( handles.dimension,  'String' ) );
guidata(hObject, handles);


function delay_Callback(hObject, eventdata, handles)
maxvalue = 2*handles.act; 
minvalue = 1; 
optvalue = handles.act;
str1 = 'GS paramenters warning';
str2 = 'Embeding delay';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

handles.output.TimeDelay   = str2double ( get ( handles.delay,      'String' ) );
guidata(hObject, handles);


function pref_edit_Callback(hObject, eventdata, handles)
maxvalue = 0.1;
minvalue = 0.01;
optvalue = 0.05;
str1 = 'GS paramenters warning';
str2 = 'pref';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 0);

handles.output.pref     = str2double ( get ( handles.pref_edit,       'String' ) );
set ( handles.w2_edit,  'String', floor ( handles.nrec/handles.output.pref ) + handles.output.w1 -1);
handles.output.w2       = str2double ( get ( handles.w2_edit,         'String' ) );
guidata(hObject, handles);


function w1_edit_Callback(hObject, eventdata, handles)
maxvalue = 2*handles.output.TimeDelay;
minvalue = handles.output.TimeDelay;
optvalue = handles.output.TimeDelay;
str1 = 'GS paramenters warning';
str2 = 'Theiler correction (w1)';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

handles.output.w1       = str2double ( get ( handles.w1_edit,         'String' ) );
set ( handles.w2_edit,  'String', floor ( handles.nrec/handles.output.pref ) + handles.output.w1 -1);
handles.output.w2       = str2double ( get ( handles.w2_edit,         'String' ) );
guidata(hObject, handles);


function w2_edit_Callback(hObject, eventdata, handles)


function window_Callback(hObject, eventdata, handles)
minvalue = 1000 * min (100, handles.project.samples )/ handles.project.fs; % ms

if get ( handles.alignment, 'Value' ) == 1  % epoch
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    
    str1 = 'GS paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

else  % stimulus
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );

    str1 = 'GS paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

end
guidata(hObject, handles);


function overlap_Callback(hObject, eventdata, handles)
maxvalue = 100;
minvalue = 0;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'GS paramenters warning';
str2 = 'Overlap';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);
guidata(hObject, handles);


function alignment_Callback(hObject, eventdata, handles)
maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Change' );

if get ( hObject, 'Value' ) == 2 && str2double ( get ( handles.window, 'String' ) ) > maxvalue
    text = 'Window''s length is greater than post-stimulus period. Do you want to change it to this value (%g ms)?';
    text = sprintf ( text, maxvalue );

    if ~strcmp ( questdlg ( text, 'GS paramenters warning', 'Change', 'Keep epoch alignment', options ), 'Change' )
        set ( hObject, 'Value', 1 );
    else
        set ( handles.window, 'String', maxvalue )
    end
end
guidata(hObject, handles);


function default_Callback(hObject, eventdata, handles)

% Calculates the default values of the parameters.
[ act, dimension ] = H_GSdefaults ( handles.project, true );

handles.output.TimeDelay     = act;
handles.output.w1            = act;
handles.output.w2            = floor ( handles.nrec / handles.output.pref ) + act - 1;

handles.output.EmbDim        = dimension;
handles.output.Nneighbours   = dimension;

set ( handles.delay,     'String', handles.output.TimeDelay )
set ( handles.w1_edit,   'String', handles.output.w1 )
set ( handles.w2_edit,   'String', handles.output.w2 )
set ( handles.dimension, 'String', handles.output.EmbDim )
set ( handles.neighbours,'String', handles.output.Nneighbours )

guidata(hObject, handles);


function neighbours_Callback(hObject, eventdata, handles)
maxvalue = 2*handles.output.EmbDim;
minvalue = handles.output.EmbDim; 
optvalue = handles.output.EmbDim+1;
str1 = 'GS paramenters warning';
str2 = 'Number of neighbours';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);
guidata(hObject, handles);


function statistics_Callback ( hObject, eventdata, handles )
if get ( hObject, 'Value' )
    set ( handles.surrogates,      'Enable', 'on' )
    set ( handles.surrogates_text, 'Enable', 'on' )
else
    set ( handles.surrogates,      'Enable', 'off' )
    set ( handles.surrogates_text, 'Enable', 'off' )
end
guidata(hObject, handles);


function surrogates_Callback ( hObject, eventdata, handles )
maxvalue = 10000;
minvalue = 20;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'GS paramenters warning';
str2 = 'The number of surrogates';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);
guidata(hObject, handles);


function OK_Callback(hObject, eventdata, handles)

handles.output.EmbDim      = str2double ( get ( handles.dimension,  'String' ) );
handles.output.TimeDelay   = str2double ( get ( handles.delay,      'String' ) );
handles.output.w1          = str2double ( get ( handles.w1_edit,    'String' ) );
handles.output.w2          = str2double ( get ( handles.w2_edit,    'String' ) );
handles.output.pref        = str2double ( get ( handles.pref_edit,  'String' ) );
handles.output.Nneighbours = str2double ( get ( handles.neighbours, 'String' ) );

if get ( handles.alignment, 'Value' ) == 1, alignment = 'epoch';    end
if get ( handles.alignment, 'Value' ) == 2, alignment = 'stimulus'; end

handles.output.window.length    = str2double ( get ( handles.window,  'String' ) );
handles.output.window.overlap   = str2double ( get ( handles.overlap, 'String' ) );
handles.output.window.alignment = alignment;

handles.output.statistics  = get ( handles.statistics,              'Value' );
handles.output.surrogates  = str2double ( get ( handles.surrogates, 'String' ) );

guidata ( hObject, handles )
uiresume



function varargout = HERMES_GSparameters_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;
delete ( hObject )

function Cancel_Callback               ( hObject, eventdata, handles ), uiresume
function GS_parameters_CloseRequestFcn ( hObject, eventdata, handles ),uiresume

function GS_parameters_WindowKeyPressFcn ( hObject, eventdata, handles )
if strcmp ( eventdata.Key, 'escape' ), uiresume, end
