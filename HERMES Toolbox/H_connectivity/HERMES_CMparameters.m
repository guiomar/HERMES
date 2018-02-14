
function varargout = HERMES_CMparameters(varargin)
% HERMES_GCparameters M-file for HERMES_GCparameters.fig
%      HERMES_GCparameters, by itself, creates a new HERMES_GCparameters or raises the existing
%      singleton*.
%
%      H = HERMES_GCparameters returns the handle to a new HERMES_GCparameters or the handle to
%      the existing singleton*.
%
%      HERMES_GCparameters('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_GCparameters.M with the given input arguments.
%
%      HERMES_GCparameters('Property','Value',...) creates a new HERMES_GCparameters or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_GCparameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_GCparameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help HERMES_GCparameters
% Last Modified by GUIDE v2.5 25-Mar-2013 04:32:23
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
                   'gui_OpeningFcn', @HERMES_CMparameters_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_CMparameters_OutputFcn, ...
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

function HERMES_CMparameters_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

set ( hObject, 'WindowStyle', 'modal' )

handles.output  = varargin {1};
handles.project = varargin {2};

if handles.output.statistics
    set ( handles.surrogates,      'Enable', 'on' )
    set ( handles.surrogates_text, 'Enable', 'on' )
end

set ( handles.maxlags, 'String', handles.output.maxlags )

set ( handles.AllF_checkbox,        'Value',   1    )
set ( handles.FreqRange1_edit,      'Enable', 'off' )
set ( handles.FreqRange2_edit,      'Enable', 'off' )
set ( handles.FreqRange_text,       'Enable', 'off' )

set ( handles.window,  'String', handles.output.window.length )
set ( handles.overlap, 'String', handles.output.window.overlap )

if strcmp ( handles.output.window.alignment, 'epoch' ),    set ( handles.alignment, 'Value', 1 ), end
if strcmp ( handles.output.window.alignment, 'stimulus' ), set ( handles.alignment, 'Value', 2 ), end

set ( handles.statistics, 'Value',  handles.output.statistics )
set ( handles.surrogates, 'String', handles.output.surrogates )

guidata ( hObject, handles );
uiwait


function maxlags_Callback(hObject, eventdata, handles)
minvalue = 1;
maxvalue = ceil ( str2double ( get ( handles.window, 'String' ) ) / 5 );
optvalue = ceil ( str2double ( get ( handles.window, 'String' ) ) / 20 );
str1 = 'CM paramenters warning';
str2 = 'Maximum lag';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

function FreqRange1_edit_Callback(hObject, eventdata, handles)
minvalue = 0;
maxvalue = str2double ( get ( handles.FreqRange2_edit, 'String' ) )-1;
optvalue = 0;
str1 = 'CM paramenters warning';
str2 = 'Minimun frequency range (Hz)';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

function FreqRange2_edit_Callback(hObject, eventdata, handles)
minvalue = str2double ( get ( handles.FreqRange1_edit, 'String' ) )+1;
maxvalue = round(handles.project.fs/2);
optvalue = round(handles.project.fs/2);
str1 = 'CM paramenters warning';
str2 = 'Maximun frequency range (Hz)';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

function AllF_checkbox_Callback(hObject, eventdata, handles)

if get ( hObject, 'Value' )
    set ( handles.FreqRange1_edit,   'Enable', 'off' )
    set ( handles.FreqRange2_edit,   'Enable', 'off' )
    set ( handles.FreqRange_text,    'Enable', 'off' )
else
    set ( handles.FreqRange1_edit,   'Enable', 'on' )
    set ( handles.FreqRange2_edit,   'Enable', 'on' )
    set ( handles.FreqRange_text,    'Enable', 'on' )
   
    set ( handles.FreqRange1_edit,   'String', 0 )
    set ( handles.FreqRange2_edit,   'String', round(handles.project.fs/2) )

end

function window_Callback(hObject, eventdata, handles)

minvalue = 1000 * min (100, handles.project.samples )/ handles.project.fs; % ms

if get ( handles.alignment, 'Value' ) == 1  % epoch
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    
    str1 = 'CM paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

else  % stimulus
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );

    str1 = 'CM paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

end

function overlap_Callback(hObject, eventdata, handles)
minvalue = 0;
maxvalue = 100;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'CM paramenters warning';
str2 = 'Overlap';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

function alignment_Callback(hObject, eventdata, handles)
maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Change' );

if get ( hObject, 'Value' ) == 2 && str2double ( get ( handles.window, 'String' ) ) > maxvalue
    text = 'Window''s length is greater than post-stimulus period. Do you want to change it to this value (%g ms)?';
    text = sprintf ( text, maxvalue );

    if ~strcmp ( questdlg ( text, 'CM paramenters warning', 'Change', 'Keep epoch alignment', options ), 'Change' )
        set ( hObject, 'Value', 1 );
    else
        set ( handles.window, 'String', maxvalue )
    end
end

function statistics_Callback ( hObject, eventdata, handles )
if get ( hObject, 'Value' )
    set ( handles.surrogates,      'Enable', 'on' )
    set ( handles.surrogates_text, 'Enable', 'on' )
else
    set ( handles.surrogates,      'Enable', 'off' )
    set ( handles.surrogates_text, 'Enable', 'off' )
end

function surrogates_Callback ( hObject, eventdata, handles )
minvalue = 20;
maxvalue = 10000;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'CM paramenters warning';
str2 = 'The number of surrogates';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);



function OK_Callback ( hObject, eventdata, handles )

% If everything is OK, the configurations is saved.
handles.output.maxlags   = str2double ( get ( handles.maxlags, 'String' ) );

if get ( handles.AllF_checkbox, 'Value' )
    handles.output.freqRange = [];
else
    f1 = str2double ( get ( handles.FreqRange1_edit, 'String' ));
    f2 = str2double ( get ( handles.FreqRange2_edit, 'String' ));
    handles.output.freqRange = [ f1 f2 ]; 
end

if get ( handles.alignment, 'Value' ) == 1, alignment = 'epoch';    end
if get ( handles.alignment, 'Value' ) == 2, alignment = 'stimulus'; end

handles.output.window.length    = str2double ( get ( handles.window,  'String' ) );
handles.output.window.overlap   = str2double ( get ( handles.overlap, 'String' ) );
handles.output.window.alignment = alignment;

handles.output.statistics = get ( handles.statistics,              'Value' );
handles.output.surrogates = str2double ( get ( handles.surrogates, 'String' ) );

guidata ( hObject, handles )
uiresume


function Cancel_Callback ( hObject, eventdata, handles ), uiresume
function CM_parameters_CloseRequestFcn(hObject, eventdata, handles),uiresume


function varargout = HERMES_CMparameters_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;

delete ( hObject )


function CM_parameters_WindowKeyPressFcn(hObject, eventdata, handles)
if strcmp ( eventdata.Key, 'escape' ), uiresume, end
