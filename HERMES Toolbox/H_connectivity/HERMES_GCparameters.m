function varargout = HERMES_GCparameters(varargin)
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
% Last Modified by GUIDE v2.5 22-Mar-2013 13:12:01
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
                   'gui_OpeningFcn', @HERMES_GCparameters_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_GCparameters_OutputFcn, ...
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

function HERMES_GCparameters_OpeningFcn ( hObject, eventdata, handles, varargin )

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

set ( handles.orderAR,  'String', handles.output.orderAR )
set ( handles.orderMAR, 'String', handles.output.orderMAR )

set ( handles.window,  'String', handles.output.window.length )
set ( handles.overlap, 'String', handles.output.window.overlap )

if strcmp ( handles.output.window.alignment, 'epoch' ),    set ( handles.alignment, 'Value', 1 ), end
if strcmp ( handles.output.window.alignment, 'stimulus' ), set ( handles.alignment, 'Value', 2 ), end

set ( handles.statistics, 'Value',  handles.output.statistics )
set ( handles.surrogates, 'String', handles.output.surrogates )

% Checks if it's possible to calculate PDF and DTF indexes.
MARmin = 3;
winmin = ceil ( 1000 * ( ( MARmin * handles.project.channels + 1 ) / min ( min ( [ handles.project.statistical.trials ] ) ) + MARmin ) / handles.project.fs );
if handles.output.window.length < winmin, set ( handles.orderMAR, 'Enable', 'off' ); end

guidata ( hObject, handles );
uiwait;


function orderAR_Callback ( hObject, eventdata, handles )
maxvalue = floor ( str2double ( get ( handles.window, 'String' ) ) / 1000 * handles.project.fs - 1 );
minvalue = 3;
optvalue = min ( max ( ceil ( str2double ( get ( handles.orderAR, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'GC paramenters warning';
str2 = 'The order of the autorregressive model';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);


function estimateAR_Callback ( hObject, eventdata, handles )
options   = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );
winlength = floor ( str2double ( get ( handles.window, 'String' ) ) / 1000 * handles.project.fs - 1 );
maxvalue  = min ( floor ( winlength / 3 ), 25 );

% Estimates the optimal order.
estimation = H_GCdefaults ( handles.project, winlength, maxvalue );

% Sets the calculated order, if any.
if ~isnan ( estimation.order )
    set ( handles.orderAR, 'String', estimation.order );
    
% Otherwise rises an error.
else
    text = [
        'The selected configuration doesn''t seem to allow the use of Granger Causality. You can try again after increasing the window length.\n\n' ...
        'If you decide to ignore this error and manually set a value for the order, remember that the results won''t be accurate. Do it at your own risk.' ];
    text = sprintf ( text );
    
    errordlg ( text, 'GC paramenters error', options );
    return
end

% If more than 20% of the vectors overflow, rises a warning.
if estimation.overflow > .2
    text = [ 'More than 20%% of the randomly selected vectors require an order greater than the maximum allowed by the program (%d).\n' ...
        'The estimated value for the order (%d) could be inaccurate.\n\n' ...
        'Consider reducing the window length and reapeating the estimation.' ];
    text = sprintf ( text, maxvalue, estimation.order );
    
    warndlg ( text, 'GC paramenters warning', options );
end


function orderMAR_Callback ( hObject, eventdata, handles )
maxvalue = ceil ( ( min ( min ( [ handles.project.statistical.trials ] ) ) * str2double ( get ( handles.window, 'String' ) ) / 1000 * handles.project.fs - 1 ) / ( handles.project.channels + min ( min ( [ handles.project.statistical.trials ] ) ) ) ) - 1;
minvalue = 3;
optvalue = min ( max ( ceil ( str2double ( get ( handles.orderMAR, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'GC paramenters warning';
str2 = 'The order of the multivariated autorregressive model';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);


function estimateMAR_Callback ( hObject, eventdata, handles )
maxvalue  = ceil ( ( min ( min ( [ handles.project.statistical.trials ] ) ) * str2double ( get ( handles.window, 'String' ) ) - 1 ) / ( handles.project.channels + min ( min ( [ handles.project.statistical.trials ] ) ) ) ) - 1;
winlength = floor ( str2double ( get ( handles.window, 'String' ) ) / 1000 * handles.project.fs - 1 );
options   = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );

% Estimates the optimal order.
estimation = H_PDCdefaults ( handles.project, winlength, maxvalue );

% Sets the calculated order, if any.
if ~isnan ( estimation.order )
    set ( handles.orderMAR, 'String', estimation.order );
    
% Otherwise rises an error.
else
    text = [
        'The selected configuration doesn''t seem to allow the use of Partial Directed Coherence. You can try again after increasing the window length.\n\n' ...
        'If you decide to ignore this error and manually set a value for the order, remember that the results won''t be accurate. Do it at your own risk.' ];
    text = sprintf ( text );
    
    errordlg ( text, 'GC paramenters error', options );
    return
end

% If more than 20% of the vectors overflow, rises a warning.
if estimation.overflow > .2
    text = [ 'More than 20%% of the randomly selected vectors require an order greater than the maximum allowed by the program (%d).\n' ...
        'The estimated value for the order (%d) could be inaccurate.\n\n' ...
        'Consider reducing the window length and reapeating the estimation.' ];
    text = sprintf ( text, maxvalue, estimation.order );
    
    warndlg ( text, 'GC paramenters warning', options );
end


function window_Callback ( hObject, eventdata, handles )
minvalue = 1000 * min (100, handles.project.samples )/ handles.project.fs; % ms

if get ( handles.alignment, 'Value' ) == 1  % epoch
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    
    str1 = 'GC paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

else  % stimulus
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
    optvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );

    str1 = 'GC paramenters warning';
    str2 = 'Window''s length (ms)';
    H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);

end


function overlap_Callback ( hObject, eventdata, handles )
maxvalue = 100;
minvalue = 0;
optvalue = min ( max ( ceil ( str2double ( get ( hObject, 'String' ) ) ), minvalue ), maxvalue );
str1 = 'GC paramenters warning';
str2 = 'Overlap';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);


function alignment_Callback ( hObject, eventdata, handles )
maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Change' );

if get ( hObject, 'Value' ) == 2 && str2double ( get ( handles.window, 'String' ) ) > maxvalue
    text = 'Window''s length is greater than post-stimulus period. Do you want to change it to this value (%g ms)?';
    text = sprintf ( text, maxvalue );

    if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Change', 'Keep epoch alignment', options ), 'Change' )
        set ( hObject, 'Value', 1 );
    else
        set ( handles.window, 'String', maxvalue )
    end
end

%QUITAR!!!!!!!!!!!!!!!!!!!!!
function nfft_Callback ( hObject, eventdata, handles )
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Replace' );
maxvalue = 2048;
minvalue = str2double ( get ( handles.orderAR, 'String' ) );
optvalue = pow2 ( nextpow2 ( min ( max ( str2double ( get ( hObject, 'String' ) ), minvalue ), maxvalue ) ) );

if H_checkOR ( str2double ( get ( hObject, 'String' ) ), 'nan', '~real', 'inf', '~int', '~pow2', [ 'lt' num2str( minvalue ) ], [ 'gt' num2str( maxvalue ) ] )
    text = 'The length of the Fourier transform must be a power of two between the order of the auto-regresive model (%g) and %g.';
    text = sprintf ( text, minvalue, maxvalue );
    
    warndlg ( text, 'GC paramenters warning', options )
    set ( hObject, 'String', optvalue );
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
str1 = 'GC paramenters warning';
str2 = 'The number of surrogates';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 1);


function OK_Callback ( hObject, eventdata, handles )
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Replace' );

% This should never be used, but it is here as a precaution.

% Checks the window length.
minvalue = round ( 1000 * 25 / handles.project.fs );

if get ( handles.alignment, 'Value' ) == 1
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs );
    optvalue = min ( max ( ceil ( str2double ( get ( handles.window, 'String' ) ) ), minvalue ), maxvalue );

    if H_checkOR ( str2double ( get ( handles.window, 'String' ) ), 'nan', '~real', 'inf', '~int', [ 'lt' num2str( minvalue ) ], [ 'gt' num2str( maxvalue ) ] )
        text = [
            'Window''s length must be a natural number between 25 samples (%g ms) and the signal''s length (set to %g ms).\n\n' ...
            'Do you want to replace it for the nearest allowed value (%g ms)?' ];
        text = sprintf ( text, minvalue, maxvalue, optvalue );

        if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
        else set ( handles.window, 'String', optvalue );
        end
    end
    
else
    maxvalue = round ( 1000 * handles.project.samples / handles.project.fs - handles.project.baseline );
    optvalue = min ( max ( ceil ( str2double ( get ( handles.window, 'String' ) ) ), minvalue ), maxvalue );

    if H_checkOR ( str2double ( get ( handles.window, 'String' ) ), 'nan', '~real', 'inf', '~int', [ 'lt' num2str( minvalue ) ], [ 'gt' num2str( maxvalue ) ] )
        text = [
            'When with the stimulus alignment is selected, window''s length must be ' ...
            'a natural number between 25 samples (%g ms) and the post-stimulus time (%g ms).\n\n' ...
            'Do you want to replace it for the nearest allowed value (%g ms)?' ];
        text = sprintf ( text, minvalue, maxvalue, optvalue );

        if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
        else set ( handles.window, 'String', optvalue );
        end
    end
end

% Checks the window overlap.
maxvalue = 100;
minvalue = 0;
optvalue = min ( max ( ceil ( str2double ( get ( handles.overlap, 'String' ) ) ), minvalue ), maxvalue );

if H_checkOR ( str2double ( get ( handles.overlap, 'String' ) ), 'nan', '~real', 'lt0', 'gt100' )
    text = 'The overlap must be a real number between %g and %g.\n\nDo you want to replace it for the nearest allowed value (%g)?';
    text = sprintf ( text, minvalue, maxvalue, optvalue );
    
    if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
    else set ( handles.overlap, 'String', optvalue );
    end
end

% Checks the orderAR of the AR model.
maxvalue = floor ( str2double ( get ( handles.window, 'String' ) ) / 1000 * handles.project.fs );
minvalue = 3;
optvalue = min ( max ( ceil ( str2double ( get ( handles.orderAR, 'String' ) ) ), minvalue ), maxvalue );

if H_checkOR ( str2double ( get ( handles.orderAR, 'String' ) ), 'nan', '~real', 'inf', '~int', [ 'lt' num2str( minvalue ) ], [ 'gt' num2str( maxvalue ) ] )
    text = [
        'The order of the auto-regresive model must be a natural number between %g and the number of samples of the sliding window (%g).\n\n' ...
        'Do you want to replace it for the nearest allowed value (%g)?' ];
    text = sprintf ( text, minvalue, maxvalue, optvalue );
    
    if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
    else set ( handles.orderAR, 'String', optvalue );
    end
end

% % Checks the orderMAR of the MAR model.
% maxvalue = ceil ( ( min ( min ( [ handles.project.statistical.trials ] ) ) * str2double ( get ( handles.window, 'String' ) ) - 1 ) / ( handles.project.channels + min ( min ( [ handles.project.statistical.trials ] ) ) ) ) - 1;
% minvalue = 3;
% optvalue = min ( max ( ceil ( str2double ( get ( handles.orderMAR, 'String' ) ) ), minvalue ), maxvalue );
% 
% if H_checkOR ( str2double ( get ( handles.orderMAR, 'String' ) ), 'nan', '~real', 'inf', '~int', [ 'lt' num2str( minvalue ) ], [ 'gt' num2str( maxvalue ) ] )
%     text = [
%         'The order of the multivariated auto-regresive model must be a natural number between %g and the maximum allowed for the ARfit algorithm for this combination of samples, channels and trials (%g).\n\n' ...
%         'Do you want to replace it for the nearest allowed value (%g)?' ];
%     text = sprintf ( text, minvalue, maxvalue, optvalue );
%     
%     if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
%     else set ( handles.orderMAR, 'String', optvalue );
%     end
% end


% % Checks the length of the FFT.
% minvalue = str2double ( get ( handles.orderAR, 'String' ) );
% optvalue = pow2 ( nextpow2 ( max ( str2double ( get ( handles.nfft, 'String' ) ), minvalue ) ) );
% 
% if H_checkOR ( str2double ( get ( handles.nfft, 'String' ) ), 'nan', '~real', 'inf', '~int', '~pow2', [ 'lt' num2str( minvalue ) ] )
%     text = [
%         'The length of the Fourier transform must be a power of two greater than the order of the auto-regresive model (%g).\n\n' ...
%         'Do you want to replace it for the nearest suitable value (%g)?' ];
%     text = sprintf ( text, minvalue, optvalue );
%     
%     if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
%     else set ( handles.nfft, 'String', optvalue );
%     end
% end

% Checks the statistics configuration.
maxvalue = 10000;
minvalue = 20;
optvalue = min ( max ( ceil ( str2double ( get ( handles.surrogates, 'String' ) ) ), minvalue ), maxvalue );

if get ( handles.statistics, 'Value' ) && H_checkOR ( str2double ( get ( handles.surrogates, 'String' ) ), 'nan', 'inf', '~real', '~int', 'lt20', 'gt10000' )
    text = 'The number of surrogades must be a natural number between %g and %g.\n\nDo you want to replace it for the nearest allowed value (%g)?';
    text = sprintf ( text, minvalue, maxvalue, optvalue );
    
    if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Replace', 'Cancel', options ), 'Replace' ), return
    else set ( handles.surrogates, 'String', optvalue );
    end
end

% Confirmation of the overlap in stimulus aligment.
options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Continue' );

if get ( handles.alignment, 'Value' ) == 2 && str2double ( get ( handles.overlap, 'String' ) ) ~= 0
    text = [
        'Overlapping windows have been selected when aligning the epoch to the stimulous. This configuration could lead to a confuse output.\n\n' ...
        'Do you want to continue with the selected configuration?' ];
    text = sprintf ( text );
    
    if ~strcmp ( questdlg ( text, 'GC paramenters warning', 'Continue', 'Cancel', options ), 'Continue' ), return, end
end

% If everything is OK, the configurations is saved.
handles.output.orderAR  = str2double ( get ( handles.orderAR,  'String' ) );
handles.output.orderMAR = str2double ( get ( handles.orderMAR, 'String' ) );

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


function varargout = HERMES_GCparameters_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;

delete ( hObject )


function GC_parameters_CloseRequestFcn(hObject, eventdata, handles),uiresume

function GC_parameters_WindowKeyPressFcn(hObject, eventdata, handles)
if strcmp ( eventdata.Key, 'escape' ), uiresume, end

function orderMAR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
