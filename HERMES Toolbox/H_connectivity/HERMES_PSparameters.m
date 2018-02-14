function varargout = HERMES_PSparameters(varargin)
% HERMES_PSparameters M-file for HERMES_PSparameters.fig
%      HERMES_PSparameters, by itself, creates a new HERMES_PSparameters or raises the existing
%      singleton*.
%
%      H = HERMES_PSparameters returns the handle to a new HERMES_PSparameters or the handle to
%      the existing singleton*.
%
%      HERMES_PSparameters('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_PSparameters.M with the given input arguments.
%
%      HERMES_PSparameters('Property','Value',...) creates a new HERMES_PSparameters or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_PSparameters_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_PSparameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help HERMES_PSparameters
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

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_PSparameters_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_PSparameters_OutputFcn, ...
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

function HERMES_PSparameters_OpeningFcn(hObject, eventdata, handles, varargin)

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

set ( hObject, 'WindowStyle', 'modal' )

handles.output  = varargin {1};
handles.project = varargin {2};

% set ( handles.window_text,    'Enable','on')
% set ( handles.window,         'Enable','on')
% set ( handles.overlap_text,   'Enable','on')
% set ( handles.overlap,        'Enable','on')
% set ( handles.alignment_text, 'Enable','on')
% set ( handles.alignment,      'Enable','on')

if handles.output.statistics
    set ( handles.surrogates,      'Enable', 'on' )
    set ( handles.surrogates_text, 'Enable', 'on' )
end

set ( handles.bandcenter, 'String', num2str ( handles.output.bandcenter ) )
set ( handles.bandwidth,  'String', handles.output.bandwidth )

set ( handles.window,  'String', handles.output.window.length )
set ( handles.overlap, 'String', handles.output.window.overlap )

if strcmp ( handles.output.window.alignment, 'epoch' ),    set ( handles.alignment, 'Value', 1 ), end
if strcmp ( handles.output.window.alignment, 'stimulus' ), set ( handles.alignment, 'Value', 2 ), end

set ( handles.statistics, 'Value',  handles.output.statistics )
set ( handles.surrogates, 'String', handles.output.surrogates )

guidata ( hObject, handles );
uiwait;


function bandcenter_Callback ( hObject, eventdata, handles )

options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );

if any ( isnan ( str2num ( get ( hObject, 'String' ) ) ) ) || isempty ( str2num ( get ( hObject, 'String' ) ) ) || ...
        any ( ~isreal ( str2num ( get ( hObject, 'String' ) ) ) )
    text = {
        'The selected band centers are not valid numbers. It is not possible to use this configuration.';
        '';
        [ 'The value of the center frecuency (' num2str( handles.project.fs / 4 ) ' Hz) has been used insead.' ] };
    
    errordlg ( text, 'PS paramenters error', options )
    set ( hObject, 'String', handles.project.fs / 4 );
    
elseif any ( str2num ( get ( hObject, 'String' ) ) < 0 ) || any ( str2num ( get ( hObject, 'String' ) ) > handles.project.fs / 2 )
    text = { [
        'The passband centers must be between 0 and the Nyquist frequenzy' ...
        '(' num2str( handles.project.fs / 2 ) ' Hz).' ] };
    
    warndlg ( text, 'PS paramenters warning', options )
    
    bandcenters = str2num ( get ( hObject, 'String' ) );
    bandcenters ( bandcenters < 0 ) = 0;
    bandcenters ( bandcenters > handles.project.fs / 2 ) = handles.project.fs / 2;
    set ( hObject, 'String', num2str ( unique ( bandcenters ) ) );
end

bandcenter = unique ( str2num ( get ( hObject, 'String' ) ) );
set ( hObject, 'String', num2str ( unique ( bandcenter ( : )' ) ) );


function bandwidth_Callback ( hObject, eventdata, handles )
maxvalue = floor ( handles.project.fs / 2 );
minvalue = 0.1;
optvalue = 4;
str1 = 'PS paramenters warning';
str2 = 'Bandwidth';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);


function window_Callback ( hObject, eventdata, handles )
minvalue = 1000 * min (100, handles.project.samples )/ handles.project.fs; % ms

if get ( handles.alignment, 'Value' ) == 1  % epoch
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    
    str1 = 'PS paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

else  % stimulus
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );

    str1 = 'PS paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

end


function overlap_Callback ( hObject, eventdata, handles )
maxvalue = 100;
minvalue = 0;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'PS paramenters warning';
str2 = 'Overlap';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);



function alignment_Callback ( hObject, eventdata, handles )
maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Change' );

if get ( hObject, 'Value' ) == 2 && str2double ( get ( handles.window, 'String' ) ) > maxvalue
    text = 'Window''s length is greater than post-stimulus period. Do you want to change it to this value (%g ms)?';
    text = sprintf ( text, maxvalue );

    if ~strcmp ( questdlg ( text, 'PS paramenters warning', 'Change', 'Keep epoch alignment', options ), 'Change' )
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
maxvalue = 10000;
minvalue = 20;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'PS paramenters warning';
str2 = 'Number of surrogates';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);


function OK_Callback ( hObject, eventdata, handles )

% If everything is OK, the configurations is saved.
handles.output.bandcenter = str2num ( get ( handles.bandcenter,   'String' ) );
handles.output.bandwidth  = str2double ( get ( handles.bandwidth, 'String' ) );

if get ( handles.alignment, 'Value' ) == 1, alignment = 'epoch';    end
if get ( handles.alignment, 'Value' ) == 2, alignment = 'stimulus'; end

if get ( handles.MET_popupmenu, 'Value' ) == 1,  handles.output.method = 'ema';    end
if get ( handles.MET_popupmenu, 'Value' ) == 2,  handles.output.method = 'ipa';    end

handles.output.window.length    = str2double ( get ( handles.window,  'String' ) );
handles.output.window.overlap   = str2double ( get ( handles.overlap, 'String' ) );
handles.output.window.alignment = alignment;

handles.output.statistics = get ( handles.statistics,              'Value' );
handles.output.surrogates = str2double ( get ( handles.surrogates, 'String' ) );

guidata ( hObject, handles )
uiresume

function MET_popupmenu_Callback(hObject, eventdata, handles)

% if get ( hObject, 'Value' )==1
%     set ( handles.TAU_edit,     'Enable', 'on' )
%     set ( handles.TAU_text,     'Enable', 'on' )
% elseif get ( hObject, 'Value' )==2
%     set ( handles.TAU_edit,     'Enable', 'off' )
%     set ( handles.TAU_text,     'Enable', 'off' )
% end




function Cancel_Callback ( hObject, eventdata, handles ), uiresume


function varargout = HERMES_PSparameters_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;

delete ( findobj ( 'Tag', 'filtervisualizationtool' ) );
delete ( hObject )


function PS_parameters_CloseRequestFcn ( hObject, eventdata, handles ), uiresume

function PS_parameters_WindowKeyPressFcn ( hObject, eventdata, handles )
if strcmp ( eventdata.Key, 'escape' ), uiresume, end


function MET_popupmenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function view_Callback(hObject, eventdata, handles)
bandcenter = str2num ( get ( handles.bandcenter, 'String' ) );
bandwidth  = str2double ( get ( handles.bandwidth, 'String' ) );
minsamples = handles.project.samples;
filters    = H_filter ( bandcenter * 2 / handles.project.fs, bandwidth * 2 / handles.project.fs, floor ( minsamples / 3 ) - 1 );

for filter = 1: numel ( filters )
    h = fvtool ( filters { filter }, 1, 'Fs', handles.project.fs );
    legend ( h, [ 'Filter with bandwidth ' num2str( bandwidth ) ' Hz and centered in ' num2str( bandcenter ( filter ) ) ' Hz' ] )
end

