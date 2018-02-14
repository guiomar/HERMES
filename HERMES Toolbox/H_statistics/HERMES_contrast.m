function varargout = HERMES_contrast(varargin)
% HERMES_CONTRAST MATLAB code for HERMES_contrast.fig
%      HERMES_CONTRAST, by itself, creates a new HERMES_CONTRAST or raises the existing
%      singleton*.
%
%      H = HERMES_CONTRAST returns the handle to a new HERMES_CONTRAST or the handle to
%      the existing singleton*.
%
%      HERMES_CONTRAST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_CONTRAST.M with the given input arguments.
%
%      HERMES_CONTRAST('Property','Value',...) creates a new HERMES_CONTRAST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_contrast_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_contrast_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

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
% Authors:  Guiomar Niso, Ricardo Bruna, 2014
%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OpeningFcn, ...
                   'gui_OutputFcn',  @OutputFcn, ...
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

function fix_Callback           ( hObject, eventdata, handles ), update_fix        ( handles )
function fixed_Callback         ( hObject, eventdata, handles )
function set1_Callback          ( hObject, eventdata, handles ), update_index_run  ( handles )
function set2_Callback          ( hObject, eventdata, handles ), update_index_run  ( handles )
function index_Callback         ( hObject, eventdata, handles ), update_index      ( handles )
function index_run_Callback     ( hObject, eventdata, handles ), update_index_run  ( handles )
function time1_Callback         ( hObject, eventdata, handles )
function time2_Callback         ( hObject, eventdata, handles )
function configuration_button_Callback ( hObject, eventdata, handles ), update_statistics ( handles )
function run_Callback           ( hObject, eventdata, handles ), run_contrast      ( handles )
function OutputFcn              ( hObject, eventdata, handles ), delete            ( hObject )
function CloseRequestFcn        ( hObject, eventdata, handles ), uiresume
function OpeningFcn             ( hObject, eventdata, handles, varargin ), initialize ( handles, varargin {:} )
function WindowKeyPressFcn      ( hObject, eventdata, handles ), if strcmp ( eventdata.Key, 'escape' ), uiresume, end


function initialize ( handles, varargin )

% Sets the default background color.
elements   = findobj ( handles.HERMES_contrast, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox', '-or', 'Style', 'radiobutton' );
set ( handles.HERMES_contrast, 'Color',           H_background )
set ( elements,                'BackgroundColor', H_background )

if nargin == 1, return, end


% Default basic configuration parameters.
handles.configuration.test      = 'wilcoxon';
handles.configuration.alpha     = 0.05;

% Default statistics_FDR configuration parameters.
handles.configuration.FDRq      = 0.1;
handles.configuration.FDRtype   = 2;

% Default statistics_CBPT configuration parameters.
handles.configuration.MaxDist   = 1.5;
handles.configuration.Nclusters = 10;
handles.configuration.Nperm     = 100;


% Gets the project.
handles.data.project = varargin {1};

% Gets the list of indexes and runs.
handles.data.runs    = H_load ( handles.data.project, 'indexes' );
handles.data.indexes = unique ( cat ( 1, handles.data.runs.indexes ) );

% Checks that all the indexes has a 'dimensions' field.
for run = 1: numel ( handles.data.runs )
    for index = 1: numel ( handles.data.runs ( run ).indexes )
        
        index_name = handles.data.runs ( run ).indexes { index };
        
        % If the current index has not dimensions, creates one window.
        if ~isfield ( handles.data.runs ( run ).config.( index_name ), 'dimensions' )
            
            % Creates a dimensions description.
            dimensions = { 'sensors' 'sensors' 'time' };
            dimensions { 2, 3 } = handles.data.project.time ( [ 1 end ] );
            
            handles.data.runs ( run ).config.( index_name ).dimensions = dimensions;
        end
        
        % If one group and one condition, removes the indexes with one window.
        if numel ( handles.data.project.groups ) < 2 && numel ( handles.data.project.conditions ) < 2
            
            % Gets the dimensions
            dimensions = handles.data.runs ( run ).config.( index_name ).dimensions;
            windows    = dimensions { 2, strcmp ( dimensions ( 1, : ), 'time' ) };
            
            % If one window, ignores the index run.
            if size ( windows, 1 ) == 1
                handles.data.runs ( run ).indexes { index } = '';
            end
        end
    end
    
    % Removes the ignored indexes.
    handles.data.runs ( run ).indexes ( cellfun ( @isempty, handles.data.runs ( run ).indexes ) ) = [];
end


% If one group and one condition, and only one window, exits.
if all ( cellfun ( @isempty, { handles.data.runs.indexes } ) )
    guidata ( handles.HERMES_contrast, handles );
    uiresume
    return;
    
% If only one group, fixes it.
elseif numel ( handles.data.project.groups ) < 2
    handles.set.fixes = { 'Group' };
    
% If only one condition, fixes it.
elseif numel ( handles.data.project.conditions ) < 2
    handles.set.fixes = { 'Condition' };
    
% Otherwise, fixes the condition.
else
    handles.set.fixes = { 'Condition' };
end

% Fills the list of indexes and runs.
set ( handles.index, 'String', handles.data.indexes );
update_index ( handles )
handles = guidata ( handles.HERMES_contrast );

% Updates the contrast to compare.
set ( handles.fix,   'String', handles.set.fixes );
update_fix   ( handles )

uiwait ( handles.HERMES_contrast )


function update_fix ( handles )

% Fills the selects with the selected options.
switch handles.set.fixes { get ( handles.fix, 'Value' ) }
    case 'Group'
        set ( handles.fixed, 'String', handles.data.project.groups )
        set ( handles.set1,  'String', handles.data.project.conditions )
        set ( handles.set2,  'String', handles.data.project.conditions )
        
    case 'Condition'
        set ( handles.fixed, 'String', handles.data.project.conditions )
        set ( handles.set1,  'String', handles.data.project.groups )
        set ( handles.set2,  'String', handles.data.project.groups )
end

% Selects the two first avaliable contrast.
set ( handles.fixed, 'Value',  1 )
set ( handles.set1,  'Value',  1 )
set ( handles.set2,  'Value',  min ( 2, numel ( get ( handles.set2, 'String' ) ) ) )

update_index ( handles )
% update_index_run ( handles )


function update_index ( handles )

% Gets the list of runs where the selected index was calculated.
index = handles.data.indexes { get ( handles.index, 'Value' ) };
handles.data.index_runs = find ( cellfun ( @ismember, repmat ( { index }, size ( handles.data.runs ) ), { handles.data.runs.indexes } ) );

% Fills the list of runs with the avaliable runs.
set ( handles.index_run, 'String', { ( handles.data.runs ( handles.data.index_runs ).filename ) }, 'Value', 1 );

% Update the list of windows for the current run.
update_index_run ( handles )


function update_index_run ( handles )

% If the comparision is between groups, exits.
if ~strcmp ( handles.set.fixes { get ( handles.fixed, 'Value' ) }, 'Group' )
    
    % Sets the windows list to 'All'.
    string = { 'All' };
    
    % Disables the window selector.
    set ( handles.time1, 'String', string, 'Enable', 'off' );
    set ( handles.time2, 'String', string, 'Enable', 'off' );
    
    guidata ( handles.HERMES_contrast, handles );
    
    return
end

% If both sets are equal, the comparision must be between time windows.
if get ( handles.set1,  'Value' ) == get ( handles.set2,  'Value' )
    
    % Gets the selected index and run.
    index = handles.data.indexes    { get ( handles.index,     'Value' ) };
    run   = handles.data.index_runs ( get ( handles.index_run, 'Value' ) );
    
    % Gets the list of time windows analized for this index and run.
    dims  = handles.data.runs ( run ).config.( index ).dimensions;
    times = dims { 2, strcmp ( dims ( 1, : ), 'time' ) };
    times = mat2cell ( times, ones ( size ( times, 1 ), 1 ), 2 );
    
    % Sets the windows in the form of a string.
    string = cellfun ( @( win ) sprintf ( '%i - %i ms', win ), times, 'UniformOutput', false );
    
    % Enables the window selector.
    set ( handles.time1, 'String', string, 'Enable', 'on'  );
    set ( handles.time2, 'String', string, 'Enable', 'on'  );
    
% Othewise, all the windows are compared.
else
    
    % Sets the windows list to 'All'.
    string = { 'All' };
    
    % Disables the window selector.
    set ( handles.time1, 'String', string, 'Enable', 'off' );
    set ( handles.time2, 'String', string, 'Enable', 'off' );
end

% Fills the list of windows with the avaliable windows.
set ( handles.time1, 'String', string, 'Value', 1 );
set ( handles.time2, 'String', string, 'Value', min ( 2, numel ( string ) ) );

guidata ( handles.HERMES_contrast, handles );


function update_statistics ( handles )

handles.configuration = HERMES_statistics ( handles.configuration, handles.data.project );
guidata ( handles.HERMES_contrast, handles );


function run_contrast ( handles )
options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'Cancel' );

% Checks that the sets to compare are diferent.
if get ( handles.set1, 'Value' ) == get ( handles.set2, 'Value' ) && get ( handles.time1, 'Value' ) == get ( handles.time2, 'Value' )
    text = [
        'Both comparing sets are really the same.\n' ...
        '\n' ...
        'It is not possible to use this configuration.\n' ];
    text = sprintf ( text );
    
    errordlg ( text, 'Statistics error', options )
    return
end

% Checks that the size of each set is enough.
if strcmp ( handles.set.fixes, 'Group' )
    minset = sum ( [ handles.data.project.statistical.group ] == get ( handles.fix, 'Value' ) );
else
    minset = min ( sum ( [ handles.data.project.statistical.group ] == get ( handles.set1, 'Value' ) ), sum ( [ handles.data.project.statistical.group ] == get ( handles.set2, 'Value' ) ) );
end
if minset < 4
    text = [
        'At least one of the groups have only %d subjects.\n' ...
        'The results are not accurate with less than four subjects in each group.\n' ...
        '\n' ...
        'Do you still want to continue?' ];
    text = sprintf ( text, minset );
    
    if ~strcmp ( questdlg ( text, 'Statistics warning', 'Continue', 'Cancel', options ), 'Continue' ), return, end
end

% If everything is OK, the configuration is saved.
configuration.index = handles.data.indexes    { get ( handles.index,     'Value' ) };
configuration.run   = handles.data.index_runs ( get ( handles.index_run, 'Value' ) );

configuration.fix   = handles.set.fixes       { get ( handles.fix,       'Value' ) };
configuration.fixed = get ( handles.fixed, 'Value' );

configuration.set1  = get ( handles.set1,  'Value' );
configuration.set2  = get ( handles.set2,  'Value' );

configuration.time1 = get ( handles.time1, 'Value' );
configuration.time2 = get ( handles.time2, 'Value' );

% If the sets are different, the first time option is 'All'.
if get ( handles.set1, 'Value' ) ~= get ( handles.set2, 'Value' )
    configuration.time1 = configuration.time1 - 1;
    configuration.time2 = configuration.time2 - 1;
end

if     get ( handles.statistics_FDR,  'Value' )
    configuration.method = 'FDR';
elseif get ( handles.statistics_CBPT, 'Value' )
    configuration.method = 'CBPT';
else
    configuration.method = 'Uncorrected';
end

configuration.parameters = handles.configuration;

% Calculates the configuration with the selected configuration.
H_statistics ( handles.data.project, configuration );

% Closes the configuration calculation window.
close ( handles.HERMES_contrast )
