function varargout = HERMES_About(varargin)
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
                   'gui_OpeningFcn', @HERMES_About_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_About_OutputFcn, ...
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

function HERMES_About_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Draws the logo.
axes ( handles.logo );
image ( imread ( H_path ( 'img', 'MiniLogo.png' ), 'BackgroundColor', get ( hObject, 'Color' ) ) )
axis off

uiwait


function HERMES_About_OutputFcn  ( hObject, eventdata, handles ), uiresume

function HERMES_About_KeyPressFcn ( hObject, eventdata, handles )
if strcmp ( eventdata.Key, 'escape' ), closereq, end
