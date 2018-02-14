function varargout = HERMES_statistics(varargin)

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
% Last Modified by GUIDE v2.5 16-Oct-2015 17:23:41

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
% Niso G, Bruna R, Pereda E, Guti�rrez R, Bajo R., Maest� F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, Ricardo Bruna, 2012
%


% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_statistics_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_statistics_OutputFcn, ...
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

function HERMES_statistics_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

handles.output       = varargin {1};
handles.data.project = varargin {2};

handles.set.tests    = { 'wilcoxon' 'ttest' };

% Initializes the fields.
set ( handles.test,         'Value',  find ( strcmp ( handles.output.test, handles.set.tests ) ) )
set ( handles.alpha,        'String', handles.output.alpha )

set ( handles.FDRq,         'String', handles.output.FDRq )
set ( handles.FDRtype,      'Value',  handles.output.FDRtype )

set ( handles.permutations, 'String', handles.output.Nperm )
set ( handles.maxDist,      'String', handles.output.MaxDist )
set ( handles.clusters,     'String', handles.output.Nclusters )

guidata ( hObject, handles )
uiwait ( handles.HERMES_statistics )


function test_Callback    ( hObject, eventdata, handles )


function alpha_Callback   ( hObject, eventdata, handles )
minvalue = 0.001;
maxvalue = 0.1;
optvalue = 0.05;

H_checkLIM ( hObject, minvalue, maxvalue, optvalue, 'CBPT paramenters warning', 'Alpha', 0 );


function FDRtype_Callback ( hObject, eventdata, handles )


function FDRq_Callback    ( hObject, eventdata, handles )
minvalue = 0.01;
maxvalue = 0.4;
optvalue = 0.2;

str1 = 'FDR paramenters warning';
str2 = 'q';

H_checkLIM ( hObject, minvalue, maxvalue, optvalue, str1, str2, 0 );


function maxDist_Callback ( hObject, eventdata, handles )
minvalue = 1;
maxvalue = 3;
optvalue = 1.5;

H_checkLIM ( hObject, minvalue, maxvalue, optvalue, 'CBPT paramenters warning', 'Max. distance', 0 );


function clusters_Callback ( hObject, eventdata, handles )
minvalue = 1;
maxvalue = 10;
optvalue = 10;

H_checkLIM ( hObject, minvalue, maxvalue, optvalue, 'CBPT paramenters warning', 'Number of clusters', 1 );


function permutations_Callback ( hObject, eventdata, handles )
minvalue = 20;
maxvalue = 10000;
optvalue = 20;

H_checkLIM ( hObject, minvalue, maxvalue, optvalue, 'CBPT paramenters warning', 'Number of permutations', 1 );



function OK_Callback ( hObject, eventdata, handles )

% If everything is OK, the configurations is saved.
handles.output.test      = handles.set.tests { get ( handles.test, 'Value' ) };
handles.output.alpha     = str2double ( get ( handles.alpha,        'String' ) );
handles.output.FDRq      = str2double ( get ( handles.FDRq,         'String' ) );
handles.output.FDRtype   = get ( handles.FDRtype, 'Value' );
handles.output.Nperm     = str2double ( get ( handles.permutations, 'String' ) );
handles.output.MaxDist   = str2double ( get ( handles.maxDist,      'String' ) );
handles.output.Nclusters = str2double ( get ( handles.clusters,     'String' ) );

guidata ( hObject, handles )
uiresume


function varargout = HERMES_statistics_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;

delete ( hObject )


function Cancel_Callback ( hObject, eventdata, handles ), uiresume

function HERMES_statistics_CloseRequestFcn ( hObject, eventdata, handles ), uiresume

function HERMES_statistics_WindowKeyPressFcn ( hObject, eventdata, handles )
if strcmp ( eventdata.Key, 'escape' ), uiresume, end
