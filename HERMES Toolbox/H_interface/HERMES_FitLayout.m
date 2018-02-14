function varargout = HERMES_FitLayout(varargin)
% HERMES_FITLAYOUT M-file for HERMES_FitLayout.fig
%      HERMES_FITLAYOUT, by itself, creates a new HERMES_FITLAYOUT or raises the existing
%      singleton*.
%
%      H = HERMES_FITLAYOUT returns the handle to a new HERMES_FITLAYOUT or the handle to
%      the existing singleton*.
%
%      HERMES_FITLAYOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_FITLAYOUT.M with the given input arguments.
%
%      HERMES_FITLAYOUT('Property','Value',...) creates a new HERMES_FITLAYOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_FitLayout_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_FitLayout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help HERMES_FitLayout
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


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_FitLayout_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_FitLayout_OutputFcn, ...
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


function HERMES_FitLayout_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Gets the selected layout and the number of channels in the dataset.
layout  = varargin {1};
dataset = varargin {2};

% Creates the original labels list as Channel_XXX if needed.
if isnumeric ( dataset )
    format  = repmat ( { sprintf( '%%0%0.0f.0f \t', ceil ( log10 ( dataset ) ) ) }, dataset, 1 );
    dataset = strcat ( 'Channel_', cellfun ( @num2str, num2cell ( 1: dataset )', format, 'UniformOutput', 0 ) );
elseif ~iscellstr ( dataset )
    return
end

% Creates the empty transformation matrix.
handles.transformation = zeros ( size ( dataset ) );

% Fulfills both lists.
set ( handles.dataset, 'String',   dataset );
set ( handles.dataset, 'UserData', dataset );
set ( handles.layout,  'String',   layout );
set ( handles.layout,  'UserData', layout );

handles.output = [];

% Update handles structure
guidata(hObject, handles);

uiwait


function layout_Callback ( hObject, eventdata, handles )

% If double click and no previous assignation, calls deal callback.
if strcmp ( get ( handles.FitLayout, 'SelectionType' ), 'open' ) && handles.transformation ( get ( handles.dataset, 'Value' ) ) == 0
    deal_Callback ( handles.deal, eventdata, handles );
    
end


function dataset_Callback ( hObject, eventdata, handles )

% If double click, calls deal callback.
if strcmp ( get ( handles.FitLayout, 'SelectionType' ), 'open' )
    deal_Callback ( handles.deal, eventdata, handles );

% Else sets the direction depending if the channel is labeled or not.
else
    if handles.transformation ( get ( handles.dataset, 'Value' ) )
        set ( handles.deal, 'String', '<<' )
        set ( handles.deal, 'Enable', 'on' )
        
    elseif numel ( get ( handles.layout, 'String' ) )
        set ( handles.deal, 'String', '>>' )
        set ( handles.deal, 'Enable', 'on' )
        
    else
        set ( handles.deal, 'Enable', 'off' )
    end
end


function deal_Callback ( hObject, eventdata, handles )

% Gets the labels of the dataset and the layout.
layout  = get ( handles.layout,  'UserData' );
dataset = get ( handles.dataset, 'UserData' );

% Gets the lists contents.
free      = get ( handles.layout,  'String' );
relations = get ( handles.dataset, 'String' );

% Gets the transformation matrix.
transformation = handles.transformation;

% Gets the destination of the asignation.
destination = get ( handles.dataset, 'Value' );

% If the transformation is already sets, frees it.
if handles.transformation ( destination )
    
    % Deletes the label asignation and the transformation entry.
    relations ( destination ) = dataset ( destination );
    transformation ( destination ) = 0;
    
elseif get ( handles.layout, 'Value' ) ~= 0
    
    % Gets the layout label origin.
    origin = find ( strcmp ( layout, free ( get ( handles.layout, 'Value' ) ) ) );
    
    % Sets the label asignation and the transformation entry.
    relations { destination } = cat ( 2, dataset { destination }, ' -> ', layout { origin } );
    transformation ( destination ) = origin;
    
    % Goes to the next channel, if possible.
    if ( destination ) < numel ( dataset ), set ( handles.dataset, 'Value', destination + 1 ); end
    
else return
end

% Sets the layout labels.
layout ( transformation ( transformation ~= 0 ) ) = [];

% Corrects the selected item in the layout list if needed.
if get ( handles.layout, 'Value' ) > numel ( layout ) || numel ( layout ) == 1, set ( handles.layout, 'Value', numel ( layout ) ); end

% Sets the labels of the dataset and the layout.
set ( handles.layout,  'String',   layout );
set ( handles.dataset, 'UserData', dataset );
set ( handles.dataset, 'String',   relations );

% Sets the transformation matrix.
handles.transformation = transformation;

% Update handles structure
guidata(hObject, handles);


% Sets the direction depending if the channel is labeled or not.
if handles.transformation ( get ( handles.dataset, 'Value' ) )
    set ( handles.deal, 'String', '<<' )
elseif numel ( layout )
    set ( handles.deal, 'String', '>>' )
else
    set ( handles.deal, 'Enable', 'off' )
end


function OK_Callback ( hObject, eventdata, handles )

% Gets the transformation matrix.
transformation = handles.transformation;

% Checks that there is at least two selected channels.
if sum ( transformation ~= 0 ) < 2
    text = 'At least two channels must be selected.\nSynchronization measures has no sense otherwise';
    text = sprintf ( text );

    errordlg ( text, 'HERMES - Layout selecting error' )
    return
end

% Constructs the order matrix from the transformation matrix.
hits  = find ( transformation );
order = zeros ( size ( transformation ) );
order ( transformation ( hits ) ) = hits;

% Sets the output.
handles.output = order;

% Update handles structure
guidata ( hObject, handles );

uiresume


function Cancel_Callback ( hObject, eventdata, handles ), FitLayout_CloseRequestFcn ( get ( hObject, 'Parent' ), eventdata, handles )


function varargout = HERMES_FitLayout_OutputFcn ( hObject, eventdata, handles ) 
varargout {1} = handles.output;
delete ( hObject )


function FitLayout_CloseRequestFcn ( hObject, eventdata, handles )
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );

% Asks if the user really wants to continue without layout.
text = [
    'Do you really want to continue without a layout?\n\n' ...
    'Remember that you won''t be able to select a layout later, nor accuratly represent the connectivity.\n' ...
    'In addition, some statistics could throw wrong results due to not being able to detect near sensors.' ];
text = sprintf ( text );

if strcmp ( questdlg ( text, 'HERMES - Layout selecting question', 'Yes', 'No', options ), 'Yes' ), uiresume, end
