function output = inputdlg ( text, title, lines, default, options )
%INPUTDLG Input dialog box.
%
%  ANSWER = INPUTDLG(PROMPT) creates a modal dialog box that returns user
%  input in the string ANSWER. PROMPT string containing the PROMPT to show.
%
%  INPUTDLG uses UIWAIT to suspend execution until the user responds.
%
%  ANSWER = INPUTDLG(PROMPT,NAME) specifies the title for the dialog.
%  
%  This function improoves the Matlab original one by confirming the input
%  at the pressing of the 'Return' key. Pressing the 'Escape' key will
%  cancel the input.
%  
%  Unlike the original function, this one does only accept one prompt line
%  and gives one answer string.
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


% erropts  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );
% answer = inputdlg ( text, 'HERMES - Importing question', 1, { '' }, erropts );

% Generates an error if the number of arguments is incorrect.
error ( nargchk    ( 0, 5, nargin  ) );
error ( nargoutchk ( 0, 1, nargout ) );

% Fulfills the arguments.
if nargin < 5, options = struct (); end
if nargin < 4, default = '';        end
if nargin < 3, lines = 1;           end
if nargin < 2, title = '';          end
if nargin < 1, text = 'Input:';     end

% Checks the options.
if ischar ( options ), options = struct ( 'Resize', options ); end

% Checks the arguments.
if ~ischar ( text ),      error ( 'This function only accepts strings as its first parameter.' ),             end
if ~ischar ( title ),     error ( 'This function only accepts strings as its second parameter.' ),            end
if ~isstruct ( options ), error ( 'This function only accepts strings or structs as its fourth parameter.' ), end

% Fulfills the options.
if ~isfield ( options, 'Resize' ),      options.Resize =      'off';    end
if ~isfield ( options, 'WindowStyle' ), options.WindowStyle = 'normal'; end
if ~isfield ( options, 'Interpreter' ), options.Interpreter = 'none';   end

% Initializes the output.
handles.output = {};

% Creates the objects.
handles.dialog = figure ( ...
    'Units', 'pixels', ...
    'Position', [ 597 455 175 87 ], ...
    'Color', [ 0.9 0.9 0.9 ], ...
    'Menubar', 'none', ...
    'Numbertitle', 'off', ...
    'Name', title, ...
    'CloseRequestFcn', 'uiresume', ...
    'Resize', options.Resize, ...
    'WindowStyle', options.WindowStyle, ...
    'Visible', 'off' );

handles.text = uicontrol ( ...
    'Style', 'text', ...
    'Units', 'pixels', ...
    'Position', [ 5 62 165 15 ], ...
    'HorizontalAlignment', 'left', ...
    'String', text );

handles.edit = uicontrol ( ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    'Max', lines, ...
    'Position', [ 5 38 165 8 ] + [ 0 0 0 16 ] * lines, ...
    'BackgroundColor', [ 1 1 1 ], ...
    'String', default );

handles.ok = uicontrol ( ...
    'Style', 'pushbutton', ...
    'Units', 'pixels', ...
    'Position', [ 57 5 54 28 ], ...
    'String', 'OK' );

handles.cancel = uicontrol ( ...
    'Style', 'pushbutton', ...
    'Units', 'pixels', ...
    'Position', [ 116 5 54 28 ], ...
    'String', 'Cancel', ...
    'Callback', 'uiresume' );


% Gets the original position of the uicontrols.
windowpos = get ( 0, 'ScreenSize' );
dialogpos = get ( handles.dialog, 'Position' );
editpos =   get ( handles.edit, 'Position' );
okpos =     get ( handles.ok, 'Position' );
cancelpos = get ( handles.cancel, 'Position' );

% Gets the recomended size of the text.
[ text, textpos ] = textwrap ( handles.text, { text }, numel ( text ) + 1 );
set ( handles.text, 'String', text );

% Modifies the position of the uicontrols to fit the size of the text.
textpos ( 3 ) = max ( textpos ( 3 ), 165 );
textpos ( 2 ) = editpos ( 4 ) + okpos ( 4 ) + 10;
set ( handles.text, 'Position', textpos );

editpos ( 3 ) = textpos ( 3 );
set ( handles.edit, 'Position', editpos );

okpos ( 1 ) = dialogpos ( 3 ) - cancelpos ( 3 ) - 5 - okpos ( 3 ) - 5;
set ( handles.ok, 'Position', okpos );

cancelpos ( 1 ) = dialogpos ( 3 ) - cancelpos ( 3 ) - 5;
set ( handles.cancel, 'Position', cancelpos );

dialogpos ( 3 ) = textpos ( 3 ) + 10;
dialogpos ( 4 ) = textpos ( 4 ) + editpos ( 4 ) + okpos ( 4 ) + 14;
dialogpos ( 1 ) = ( windowpos ( 3 ) - dialogpos ( 3 ) ) / 2;
dialogpos ( 2 ) = ( windowpos ( 4 ) - dialogpos ( 4 ) ) / 2;
set ( handles.dialog, 'Position', dialogpos );

% Sets the callbacks.
set ( handles.ok,   'Callback',    { @ok_callback } )
set ( handles.edit, 'KeyPressFcn', { @edit_callback ( lines ) } )

guidata ( handles.dialog, handles );

% Shows the dialog.
set ( handles.dialog, 'Visible', 'on' );


% Sets the active field and pauses execution.
uicontrol ( handles.edit )
uiwait ( handles.dialog )

% Loads the stored data.
handles = guidata ( handles.dialog );

% Outputs the string and exits.
output = handles.output;
delete ( handles.dialog );


function ok_callback ( hObject, varargin )

% Gets the handles data.
handles = guidata ( hObject );

% Sets the value for the output and saves it.
handles.output = get ( handles.edit, 'String' );
guidata ( hObject, handles );

% Continues with the execution.
uiresume


function edit_callback ( hObject, eventdata, lines )

% Checks the pressed key.
switch lower ( eventdata.Key )
    
    % If the key is Return, saves.
    case 'return'
        if lines == 1,
            pause ( 5e-2 )
            ok_callback ( hObject )
        end
        
    % If the key is Escape, exits.
    case 'escape'
        uiresume
end
