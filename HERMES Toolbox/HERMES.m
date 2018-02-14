function varargout = HERMES(varargin)

% HERMES M-file for HERMES.fig
%      HERMES, by itself, creates a new HERMES or raises the existing
%      singleton*.
%
%      H = HERMES returns the handle to a new HERMES or the handle to
%      the existing singleton*.
%
%      HERMES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES.M with the given input arguments.
%
%      HERMES('Property','Value',...) creates a new HERMES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Copyright 2002-2003 The MathWorks, Inc.
% Edit the above text to modify the response to help HERMES
% Last Modified by GUIDE v2.5 30-Aug-2014 20:14:08
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
% ** Please cite: 
% Niso G, Bruna R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, 2010
%           Guiomar Niso, Ricardo Bruna, 2014
%

clc

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @HERMES_OpeningFcn, ...
    'gui_OutputFcn',  @HERMES_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end % End initialization code - DO NOT EDIT

% Deactivation of the unwanted warnings.
%#ok<*INUSL,*INUSD,*DEFNU,*ST2NM>


function HERMES_OpeningFcn ( hObject, eventdata, handles, varargin )

% Includes the HERMES functions' folders to the temporal path.
path ( H_path,                       path );
path ( H_path ( 'H_interface' ),     path );
path ( H_path ( 'H_connectivity' ),  path );
path ( H_path ( 'H_statistics' ),    path );
path ( H_path ( 'H_visualization' ), path );
path ( H_path ( 'H_minifunctions' ), path );

% Includes the lib subfolders in the temporal path.
path ( H_path ( 'lib/tim-matlab-1.2.0' ), path );
path ( H_path ( 'lib/fnn' ), path );
path ( H_path ( 'lib/gcca' ), path );

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )

% Gets the 100px or the 120px logo according to the platform.
if     ispc,   logo = imread ( H_path ( 'img', 'LogoPC.png' ), 'BackgroundColor', H_background );
elseif isunix, logo = imread ( H_path ( 'img', 'Logo.png' ),   'BackgroundColor', H_background );
end

% Draw the logo of HERMES.
set     ( handles.logo, 'Units', 'pixels' )
logopos = get ( handles.logo, 'Position' ) .* [ 1 1 0 0 ] + H_size ( logo, [ 0 0 1 2 ] );
set     ( handles.logo, 'Position', logopos )
image   ( logo, 'Parent', handles.logo, 'Clipping', 'off' )
axis    ( handles.logo, 'off' )
% imshow ( logo, 'Parent', handles.logo, 'InitialMagnification', 100 )

% Initialize the data.
handles.output = struct ([]);

handles.data.project = struct ([]);
handles.data.index   = {};

% Deactivates buttons and checkboxes until a project is loaded.
set ( findobj ( handles.HERMES, 'Style', 'pushbutton' ), 'Enable', 'off' )
set ( findobj ( handles.HERMES, 'Style', 'checkbox' ),   'Enable', 'off', 'Value', 0, 'ForegroundColor', [ 0 0 0 ] )

% Create data about posible measures.
handles.rom.groups = { 'CM', 'PS', 'GS', 'GC', 'IT' };

handles.rom.measures.CM = { 'COR', 'xCOR', 'COH', 'iCOH', 'PSI' };
handles.rom.measures.PS = { 'PLV', 'PLI', 'wPLI', 'RHO', 'DPI' };
handles.rom.measures.GS = { 'S', 'H', 'N', 'M', 'L', 'SL' };
handles.rom.measures.GC = { 'GC', 'PDC', 'DTF' };
handles.rom.measures.IT = { 'MI', 'TE', 'PMI', 'PTE'};

% Updates the projects list.
updateProjects ( handles )

% Update handles structure.
guidata ( hObject, handles );


function file_Callback       ( hObject, eventdata, handles ), updateProjects ( handles )
function statistics_Callback ( hObject, eventdata, handles ), updateGUImenu  ( handles )

function export_Callback     ( hObject, eventdata, handles ), H_HERexport    ( handles.data.project );
function import_Callback     ( hObject, eventdata, handles ), loadProject    ( handles, H_HERimport )
function create_Callback     ( hObject, eventdata, handles ), loadProject    ( handles, HERMES_NewProject )

function load_Callback ( hObject, eventdata, handles, project )

% If the project is empty, exits.
if isempty ( project ), return, end

% Loads the project.
handles.data.project = H_load ( project );
handles.data.runs    = H_load ( handles.data.project, 'indexes' );
handles.data.logs    = H_load ( handles.data.project, 'log' );

if numel ( handles.data.runs ), handles.data.indexes = unique ( cat ( 1, handles.data.runs.indexes ) );
else                            handles.data.indexes = {};
end

guidata ( hObject, handles )
updateGUI ( handles )


function log_Callback                ( hObject, eventdata, handles ), HERMES_Logs          ( handles.data.project )
function exportIdx_Callback          ( hObject, eventdata, handles ), HERMES_ExportIndexes ( handles.data.project )
function exportStats_Callback        ( hObject, eventdata, handles ), HERMES_ExportStats   ( handles.data.project )

function view_signal_Callback        ( hObject, eventdata, handles ), H_view_signal        ( handles.data.project )
function view_connectivity_Callback  ( hObject, eventdata, handles ), H_view_connectivity  ( handles.data.project )
function view_average_Callback       ( hObject, eventdata, handles ), H_view_average       ( handles.data.project )


function compute_statistics_Callback ( hObject, eventdata, handles ), HERMES_contrast      ( handles.data.project )
function view_statistics_Callback    ( hObject, eventdata, handles ), H_view_statistics    ( handles.data.project )

function aboutHERMES_Callback        ( hObject, eventdata, handles ), HERMES_About
function HERMES_web_Callback         ( hObject, eventdata, handles ), web ( 'http://hermes.ctb.upm.es', '-browser' )


function labels_Callback             ( hObject, eventdata, handles ), HERMES_ViewLabels ( handles.data.project )
function layout_Callback             ( hObject, eventdata, handles )


% PARAMETERS

function CM_PARAM_pushbutton_Callback ( hObject, eventdata, handles )
handles.config.CM = HERMES_CMparameters ( handles.config.CM, handles.data.project );
guidata ( hObject, handles );

    
function PS_PARAM_pushbutton_Callback ( hObject, eventdata, handles )
handles.config.PS = HERMES_PSparameters ( handles.config.PS, handles.data.project );
guidata ( hObject, handles );


function GS_PARAM_pushbutton_Callback ( hObject, eventdata, handles )
handles.config.GS = HERMES_GSparameters ( handles.config.GS, handles.data.project );
guidata ( hObject, handles );

    
function GC_PARAM_pushbutton_Callback ( hObject, eventdata, handles )
handles.config.GC = HERMES_GCparameters ( handles.config.GC, handles.data.project );
guidata ( hObject, handles );

% Disables PDC and DTF if the calculation is not possible.
checkPDC ( handles );


function IT_PARAM_pushbutton_Callback ( hObject, eventdata, handles )
handles.config.IT = HERMES_ITparameters ( handles.config.IT, handles.data.project );
guidata ( hObject, handles );


function COR_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function xCOR_Callback ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function COH_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function iCOH_Callback ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function PSI_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )

function PLV_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function PLI_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function wPLI_Callback ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function RHO_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function DPI_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )

function S_Callback    ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function N_Callback    ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function M_Callback    ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function H_Callback    ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function L_Callback    ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function SL_Callback   ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )

function GC_Callback   ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function DGC_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function PDC_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function DTF_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )

function MI_Callback   ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function TE_Callback   ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function PMI_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )
function PTE_Callback  ( hObject, eventdata, handles ), check ( hObject, eventdata, handles )


function run_Callback ( hObject, eventdata, handles )

% Deletes the Cancel flag.
H_stop ( false );

% Creates the waitbar.
handles.config.waitbar.start    = clock;
handles.config.waitbar.title    = 'HERMES - Initiating';
handles.config.waitbar.message  = 'Configuring calculations...';
handles.config.waitbar.progress = [ 0 1 ];
handles.config.waitbar.handle   = [];
guidata ( hObject, handles );
        
% Creates a new log entry.
% handles.data.project = H_log ( handles.data.project, 'new', handles.config );
H_log ( handles.data.project, 'new', handles.config );
guidata ( hObject, handles );
updateGUImenu ( handles )

% Creates the indexes configuration structure.
metas = H_load ( handles.data.project, 'indexes' );
meta.filename    = sprintf ( '%03g.index', numel ( metas ) + 1 );
meta.date        = clock;
meta.description = sprintf ( 'Run calculated on %s at %s', datestr ( meta.date, 24 ), datestr ( meta.date, 13 ) );
meta.indexes     = [];

% Calls each of the index group functions.
for group = 1: numel ( handles.rom.groups )
    
    % Gets the group name.
    groupname = handles.rom.groups { group };
    if isfield ( handles.config, groupname ) && isempty ( handles.config.( groupname ).measures ), continue, end
    
    try
        switch groupname
            case 'CM', indexes = H_compute_CM ( handles.data.project, handles.config );
            case 'GC', indexes = H_compute_GC ( handles.data.project, handles.config );
            case 'GS', indexes = H_compute_GS ( handles.data.project, handles.config );
            case 'PS', indexes = H_compute_PS ( handles.data.project, handles.config );
            case 'IT', indexes = H_compute_IT ( handles.data.project, handles.config );
        end
    
        % Updates the menu.
        updateGUImenu ( handles )
        
        % Updates the project information.
        guidata ( hObject, handles );
        
        % If user cancelation, includes it in the log.
        if ( H_stop ), H_log ( handles.data.project, 'cancel' ); return, end
        
        % Saves and updates the calculated indexes.
        H_save ( handles.data.project, 'indexes', meta, indexes )
        handles.data.runs    = H_load ( handles.data.project, 'indexes' );
        handles.data.indexes = unique ( cat ( 1, handles.data.runs.indexes ) );
        
        % Marks the index as calculated in the main GUI.
        while numel ( handles.config.( groupname ).measures )
            indexname = handles.config.( groupname ).measures {1};
            
            set ( handles.( indexname ), 'Value', 0, 'ForegroundColor', [ .2 .2 .8 ] )
            
            handles.config.( groupname ).measures ( ismember ( handles.config.( groupname ).measures, indexname ) ) = [];
        end
        
    % Catches the errores and writes them down in the current log.    
    catch errorh
        
        % Deletes the waitbar.
        delete ( findobj ( 'tag', 'H_waitbar' ) );
        
        % Creates an entry in the log for the error.
        H_log ( handles.data.project, 'error', errorh );
        
        % Writes out an error message.
        text = [
            'The execution has ended with the error:\n\n' ...
            '     %s\n\n' ...
            'Please, read the project log for expanded information.' ];
        message = sprintf ( text, errorh.message );
        errordlg ( message, 'HERMES - Error' )
        
        updateGUImenu ( handles )
        
        return
    end
end

% Updates the GUI.
updateGUI ( handles )

% Deletes the waitbar.
delete ( findobj ( 'tag', 'H_waitbar' ) );

% Calculates and promts the elapsed time.
elapsed = etime ( clock, handles.config.waitbar.start );
msgbox ( strelapsed ( elapsed, 2, 'long' ), 'HERMES - Finished' )

% Writes out the success in the current log.
H_log ( handles.data.project, 'finished', strelapsed ( elapsed, 2, 'long' ) );

guidata ( hObject, handles );


function HERMES_OutputFcn ( hObject, eventdata, handles )
function exit_Callback    ( hObject, eventdata, handles ), delete ( gcf )



function loadProject ( varargin )

if nargin == 2
    handles = varargin {1};
    project = varargin {2};
elseif nargin == 4
    handles = varargin {3};
    project = varargin {4};
else return
end

% If the project is empty, exits.
if isempty ( project ), return, end

% Loads the project.
handles.data.project = H_load ( project );
handles.data.runs    = H_load ( handles.data.project, 'indexes' );
handles.data.logs    = H_load ( handles.data.project, 'log' );

if ( numel ( handles.data.runs ) ), handles.data.indexes = unique ( cat ( 1, handles.data.runs.indexes ) );
else                                handles.data.indexes = {};
end

guidata ( handles.HERMES, handles )
updateGUI ( handles )


function updateGUI ( handles )

% Update GUI metadata.
set ( handles.File_edit,  'String', handles.data.project.name )

set ( handles.subjects,   'String', sprintf ( '%i',            numel ( handles.data.project.subjects ) ) )
set ( handles.channels,   'String', sprintf ( '%i',            handles.data.project.channels ) )

set ( handles.groups,     'String', sprintf ( '%i',            numel ( handles.data.project.groups ) ) )
set ( handles.conditions, 'String', sprintf ( '%i',            numel ( handles.data.project.conditions ) ) )

set ( handles.fs,         'String', sprintf ( '%.f Hz',        handles.data.project.fs ) )
set ( handles.samples,    'String', sprintf ( '%i',            handles.data.project.samples ) )
set ( handles.time,       'String', sprintf ( '%.f to %.f ms', handles.data.project.time ( [ 1 end ] ) ) )

if strcmp ( handles.data.project.type, 'with trials' )
    set ( handles.samples, 'String', sprintf ( '%s per trial', get ( handles.samples, 'String' ) ) )
end

% Waitbar defenition
handles.config.waitbar = struct;

% Default parameters for Classic measures.
handles.config.CM.measures    = {};

handles.config.CM.maxlags     = floor ( handles.data.project.samples / 20 );
handles.config.CM.freqRange   = [];

handles.config.CM.window.length    = floor ( 1000 * sum ( handles.data.project.time >= 0 ) / handles.data.project.fs );
handles.config.CM.window.overlap   = 0;
handles.config.CM.window.alignment = 'epoch';
handles.config.CM.window.fs        = handles.data.project.fs;
handles.config.CM.window.baseline  = handles.data.project.baseline;

handles.config.CM.statistics  = 0;
handles.config.CM.surrogates  = 100;

% Default parameters for Phase Synchronization measures.
handles.config.PS.measures    = {};

handles.config.PS.bandcenter  = [ 10 20 ];
handles.config.PS.bandwidth   = 4;
handles.config.PS.fs          = handles.data.project.fs;
handles.config.PS.method      = 'ema';

handles.config.PS.window.length    = floor ( 1000 * sum ( handles.data.project.time >= 0 ) / handles.data.project.fs );
handles.config.PS.window.overlap   = 0;
handles.config.PS.window.alignment = 'epoch';
handles.config.PS.window.fs        = handles.data.project.fs;
handles.config.PS.window.baseline  = handles.data.project.baseline;

handles.config.PS.statistics  = 0;
handles.config.PS.surrogates  = 100;

% Default parameters for Generalized Synchronization measures.
handles.config.GS.measures    = {};

handles.config.GS.EmbDim      = 3;
handles.config.GS.TimeDelay   = handles.data.project.defaults.act;
handles.config.GS.Nneighbours = 4;
handles.config.GS.w1          = handles.data.project.defaults.act;
handles.config.GS.w2          = 204;
handles.config.GS.pref        = 0.05;

handles.config.GS.window.length    = floor ( 1000 * sum ( handles.data.project.time >= 0 ) / handles.data.project.fs );
handles.config.GS.window.overlap   = 0;
handles.config.GS.window.alignment = 'epoch';
handles.config.GS.window.fs        = handles.data.project.fs;
handles.config.GS.window.baseline  = handles.data.project.baseline;

handles.config.GS.statistics  = 0;
handles.config.GS.surrogates  = 100;

% Default parameters for Granger Causality measures.
handles.config.GC.measures    = {};

handles.config.GC.orderAR     = 10;
handles.config.GC.orderMAR    = 3;
% handles.config.GC.nfft        = 64;

handles.config.GC.window.length    = floor ( 1000 * sum ( handles.data.project.time >= 0 ) / handles.data.project.fs );
handles.config.GC.window.overlap   = 0;
handles.config.GC.window.alignment = 'epoch';
handles.config.GC.window.fs        = handles.data.project.fs;
handles.config.GC.window.baseline  = handles.data.project.baseline;

handles.config.GC.statistics  = 0;
handles.config.GC.surrogates  = 100;

% Default parameters for Information Theory measures.
handles.config.IT.measures    = {};

handles.config.IT.EmbDim      = 3;
handles.config.IT.TimeDelay   = 10;
handles.config.IT.Nneighbours = 4;

handles.config.IT.window.length    = floor ( 1000 * sum ( handles.data.project.time >= 0 ) / handles.data.project.fs );
handles.config.IT.window.overlap   = 0;
handles.config.IT.window.alignment = 'epoch';
handles.config.IT.window.fs        = handles.data.project.fs;
handles.config.IT.window.baseline  = handles.data.project.baseline;

handles.config.IT.statistics  = 0;
handles.config.IT.surrogates  = 100;
    

% Activates the buttons and the checkboxes.
set ( findobj ( handles.HERMES, 'Style', 'pushbutton' ), 'Enable', 'on' )
set ( findobj ( handles.HERMES, 'Style', 'checkbox' ),   'Enable', 'on', 'Value', 0, 'ForegroundColor', [ 0 0 0 ] )

% Disables partial IT measures for more than 10 channels.
if handles.data.project.channels > 10
    set ( handles.PMI, 'Enable', 'Off' )
    set ( handles.PTE, 'Enable', 'Off' )
end

% If no trials, disables the checkbox for wPLI and PSI.
if strcmp ( handles.data.project.type, 'continuous' )
    set ( handles.wPLI, 'Enable', 'Off' );
    set ( handles.PSI,  'Enable', 'Off' );
end

% Checks if PDC and DTF can be calculated.
checkPDC ( handles )

% Mark the calculated indexes.
for index = 1: numel ( handles.data.indexes )
    set ( handles.( handles.data.indexes { index } ), 'ForegroundColor', [ .2 .2 .8 ] );
end

% Updates the menu.
updateGUImenu ( handles )
guidata ( handles.HERMES, handles );


function updateGUImenu ( handles )

% Activates the menues.
set ( handles.export,        'Enable', 'On' )
set ( handles.visualization, 'Enable', 'On' )
set ( handles.view_signal,   'Enable', 'On' )

% Checks that there exists logs.
if numel ( H_load ( handles.data.project, 'logs' ) )
    set ( handles.log, 'Enable', 'On' )
else
    set ( handles.log, 'Enable', 'Off' )
end

% Checks that there exists calculated indexes.
if numel ( H_load ( handles.data.project, 'indexes' ) )
    set ( handles.view_connectivity, 'Enable', 'On'  )
    set ( handles.view_average,      'Enable', 'On'  )
    set ( handles.exportIdx,         'Enable', 'On'  )
else
    set ( handles.view_connectivity, 'Enable', 'Off' )
    set ( handles.view_average,      'Enable', 'Off' )
    set ( handles.exportIdx,         'Enable', 'Off' )
end

% Checks if we can calculate statistics.
if statisticsCapable ( handles )
    set ( handles.statistics,        'Enable', 'On'  )
else
    set ( handles.statistics,        'Enable', 'Off' )
end

% Checks that there exists calculated statistics.
if numel ( H_load ( handles.data.project, 'statistics' ) )
    set ( handles.view_statistics,   'Enable', 'On'  )
    set ( handles.exportStats,       'Enable', 'On'  )
else
    set ( handles.view_statistics,   'Enable', 'Off' )
    set ( handles.exportStats,       'Enable', 'Off' )
end

% Checks that there is at least one selected index to calculate.
if numel ( findobj ( handles.HERMES, 'Style', 'checkbox', 'Value', 1 ) )
    set ( handles.run,               'Enable', 'On'  )
else
    set ( handles.run,               'Enable', 'Off' )
end

% Disables the view layout button.
set ( handles.layout,                'Enable', 'Off' )


function updateProjects ( handles )

% Clear the project list.
delete ( get ( handles.select, 'Children' ) )

% Gets the project list.
projects = H_projects;

if isempty ( projects ), set ( handles.select, 'Enable', 'off' )
else                     set ( handles.select, 'Enable', 'on'  )
end

% Includes the projects in the selection menu.
for p = 1: numel ( projects )
    handle = uimenu ( handles.select );
    set ( handle, 'Label', projects ( p ).name, 'Callback', @(hObject,eventdata)HERMES ( 'loadProject', hObject, eventdata, handles, projects ( p ).filename ) )
    
    % Sets the accelerator up to the tenth project.
    if p < 10, set ( handle, 'Accelerator', num2str ( p ) ), end
end


function checkPDC ( handles )

% Gets the minimum allowed window size to calculate PDF and DTF indexes.
MARmin = 3;
winmin = ceil ( 1000 * ( ( MARmin * handles.data.project.channels + 1 ) / min ( min ( [ handles.data.project.statistical.trials ] ) ) + MARmin ) / handles.data.project.fs );

% If the window size for CG is lower than the minimum value, disables the
% indexes.
if handles.config.GC.window.length < winmin
    set ( handles.PDC, 'Value', 0, 'Enable', 'off' )
    set ( handles.DTF, 'Value', 0, 'Enable', 'off' )
else
    set ( handles.PDC, 'Enable', 'on' )
    set ( handles.DTF, 'Enable', 'on' )
end


function check ( hObject, eventdata, handles )

% Characterize the checkbox.
group   = strrep ( get ( get ( hObject, 'Parent' ), 'Tag' ), 'group', '' );
measure = get ( hObject, 'Tag' );

% Adds or deletes the index to the list of selected ones.
if get ( hObject, 'Value' ), handles.config.( group ).measures = union   ( handles.config.( group ).measures, measure );
else                         handles.config.( group ).measures = setdiff ( handles.config.( group ).measures, measure );
end

updateGUImenu ( handles )

guidata ( hObject, handles );


function capable = statisticsCapable ( handles )

% By default, we won't be able to calculate statistics.
capable = false;

% If no calculated indexes we can not calculate statistics.
if numel ( H_load ( handles.data.project, 'indexes' ) ) < 1
    return
end

% If less than 6 subjects we can not calculate statistics.
if numel ( handles.data.project.subjects ) < 4
    return
end

% If two or more groups we can calculate statistics.
if numel ( handles.data.project.groups ) > 1
    capable = true;
    return
end

% If two or more conditions we can calculate statistics.
if numel ( handles.data.project.conditions ) > 1
    capable = true;
    return
end

% Otherwise checks the number of windows in the calculated indexes.

% Gets the list of runs.
runs    = H_load ( handles.data.project, 'indexes' );

% Checks that all the indexes has a 'dimensions' field.
for run = 1: numel ( runs )
    for index = 1: numel ( runs ( run ).indexes )
        
        index_name = runs ( run ).indexes { index };
        
        % If the current index has not dimensions, has one window.
        if ~isfield ( runs ( run ).config.( index_name ), 'dimensions' )
            
            % Ignores the index run.
            handles.data.runs ( run ).indexes { index } = '';
        
        % Otherwise checks the number of defined windows.
        else
            
            % Gets the dimensions
            dimensions = runs ( run ).config.( index_name ).dimensions;
            windows    = dimensions { 2, strcmp ( dimensions ( 1, : ), 'time' ) };
            
            % If one window, ignores the index run.
            if size ( windows, 1 ) == 1
                runs ( run ).indexes { index } = '';
            end
        end
    end
    
    % Removes the ignored indexes.
    runs ( run ).indexes ( cellfun ( @isempty, runs ( run ).indexes ) ) = [];
end

% If any index has two or more windows we can calculate statistics.% If one group and one condition, and only one window, exits.
if any ( ~cellfun ( @isempty, { handles.data.runs.indexes } ) )
    capable = true;
    return
end
