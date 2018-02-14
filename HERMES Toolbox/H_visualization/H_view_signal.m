function varargout = H_view_signal(varargin)

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
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%


% H_view_signal M-file for H_view_signal.fig
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @H_view_signal_OpeningFcn, ...
                   'gui_OutputFcn',  @H_view_signal_OutputFcn, ...
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

function H_view_signal_OpeningFcn ( hObject, eventdata, handles, varargin )

% Sets the default background color.
elements   = findobj ( hObject, 'Type', 'uipanel', '-or', 'Style', 'text', '-or', 'Style', 'pushbutton', '-or', 'Style', 'checkbox' );
set ( hObject,  'Color',           H_background )
set ( elements, 'BackgroundColor', H_background )
handles.output = [];

handles.project = varargin{1};
axis off

% Fills the window with the project data.
handles.display_options = { 'Distributed', 'Aligned', 'Butterfly' };

set ( handles.title,     'String', handles.project.name )
set ( handles.condition, 'String', handles.project.conditions )
set ( handles.channels,  'String', sprintf ( '[ 1 - %d ]', handles.project.channels ) )
set ( handles.display,   'String', handles.display_options)

% Sets the subject as condition to 1.
set ( handles.subject,   'String', 1 )
set ( handles.condition, 'Value',  1 )

% Channel number
set ( handles.channel, 'Enable', 'Off' );

% Time display
handles.DISPLAY =handles.display_options{1};

% Time axis
handles.T1 = handles.project.time (1);
handles.T2 = handles.project.time (end);

set ( handles.tStart, 'String', handles.T1 )
set ( handles.tEnd,   'String', handles.T2 )

% Frequency axis
handles.F1 = 0.01;
handles.F2 = floor ( handles.project.fs / 2 );

set ( handles.fStart, 'String', handles.F1 )
set ( handles.fEnd,   'String', handles.F2 )

set ( handles.fStart, 'Enable', 'off' )
set ( handles.fEnd,   'Enable', 'off' )

% Initilizes the 'previous' structure.
handles.data.previous.subject   = 0;
handles.data.previous.condition = 0;

enableML ( handles );
update   ( handles );


function varargout = H_view_signal_OutputFcn ( hObject, eventdata, handles )
varargout {1} = handles.output;


function handles = update ( handles )
subject   = str2double ( get ( handles.subject, 'String' ) );
condition = get ( handles.condition, 'Value' );

% Checks if the selected data matrix has changed.
if handles.data.previous.subject ~= subject || handles.data.previous.condition ~= condition
    
    % Loads the data if required.
    data = H_load ( handles.project, subject, condition );
    
    % Project-type specific code.
    switch handles.project.type
        
        case 'continuous'
            
            % Sets the length of the fft to two auto.
            winlength = floor ( 2 * handles.project.samples / 9 );
            overlap   = floor ( handles.project.samples / 9 );
            
        case 'with trials'
            
            % Calculates the mean of the baseline.
            baseline = mean ( data ( 1: handles.project.baseline * handles.project.fs / 1000, :, : ) );
            baseline ( isnan ( baseline ) ) = 0;
            
            % Substracts the baseline from the data.
            data = data - baseline ( ones ( handles.project.samples, 1 ), :, : );
            
            % Sets the length of the fft to the trial length.
            winlength = handles.project.samples;
            overlap   = 0;
    end
    
    % Sets the length of the fft.
    nfft = pow2 ( nextpow2 ( winlength ) );
    
    % Calculates the spectrum.
    % If more than 8 trials, uses the trials as segments.
    if min ( [ handles.project.statistical.trials ] ) >= 8
        spectra = H_spectra ( data, 'welch', true );
        
    % Otherwise uses the old approach.
    else
        spectra = H_spectra ( data, 'welch', hamming ( winlength ), overlap, nfft );
    end
    
    spectra ( isnan ( spectra ) ) = 0;
    
    % Gets the mean of all trials.
    data    = mean ( data,     3 );
    spectra = mean ( spectra, 3 );
    
    % Obtains the times and frequencies vectors.
    times = handles.project.time;
    freqs = linspace ( 0, handles.project.fs, nfft );
    
    % Stores the data in the 'previous' structure.
    handles.data.previous.subject   = subject;
    handles.data.previous.condition = condition;
    handles.data.previous.data      = data;
    handles.data.previous.spectra   = spectra;
    handles.data.previous.times     = times;
    handles.data.previous.freqs     = freqs;
    
else
    
    % Recovers the data from the 'previous' structure.
    data    = handles.data.previous.data;
    spectra = handles.data.previous.spectra;
    times   = handles.data.previous.times;
    freqs   = handles.data.previous.freqs;
end


% Gets the temporal limits.
handles.T1 = str2double ( get ( handles.tStart, 'String' ) );
handles.T2 = str2double ( get ( handles.tEnd,   'String' ) );

data  = data  ( times > handles.T1 & times < handles.T2, : );
times = times ( times > handles.T1 & times < handles.T2 );

% Gets the frequency limits.
handles.F1 = str2double ( get ( handles.fStart, 'String' ) );
handles.F2 = str2double ( get ( handles.fEnd,   'String' ) );

spectra = spectra ( handles.F1 < freqs & freqs < handles.F2, : );
freqs   = freqs    ( handles.F1 < freqs & freqs < handles.F2 );

% Plots the temporal or spectral data.
if get ( handles.timeData,  'Value' ), plotData ( data,    times, 't', handles ); end
if get ( handles.freqData,  'Value' ), plotData ( spectra, freqs, 'f', handles ); end

guidata ( handles.HERMES_figure, handles );


function plotData ( data, daxis, type, handles )

if get(handles.allChans,'Value')==1
    sensors=1:handles.project.channels;
    s='all';
end
if get(handles.singleChan,'Value')==1
    sensors=str2double(get(handles.channel,'String'));
    s='one';
end
if isempty(sensors) || sum(find(sensors<1))~=0 || sum(find(sensors>handles.project.channels))~=0
    str=['Specify valid sensors between 1 and ' num2str(handles.project.channels)];
    warndlg(str,'Invalid sensors'' number'); return
end

% Gets the data.
data = data ( :, sensors );

% Sets the option-dependent parameters.
if type == 'f'
    
    tit  ='Power Spectrum';
    xlab ='Frequency (Hz)';
    ylab ='Log(power)';
    
    ymax = max ( data (:) ) * 1.01;
    ymin = 0;
    
elseif type == 't'
    
    tit  ='Raw Data';
    xlab ='Time (ms)';
    ylab ='Amplitude';
    
    ymax = max ( abs ( data (:) ) ) * 1.01;
    ymin = -ymax;
    
end

% Deletes the previously existent axes.
delete ( findobj ( gcf, 'Type', 'axes' ) );

% Plots one or several signals.
switch s
    
    case 'one'
        
        % If one channel, plots it in the whole space.
        axes ( 'position', [ .11 .15 .8 .5 ] );
        plot ( daxis, data );
        
        % Sets the labels.
        title ( sprintf ( '%s: channel %.0f', tit, sensors ) )
        xlabel ( xlab )
        ylabel ( ylab )
        
        % Set the axes limits.
        xlim ( daxis ( [ 1 end ] ) );
        ylim ( [ ymin ymax ] );
        
    case 'all'
                    
        % Normalices the layout (between 0 and 1).
        layout = handles.project.sensors.layout;
        layout ( :, 1 ) = layout ( :, 1 ) - min ( layout ( :, 1 ) );
        layout ( :, 2 ) = layout ( :, 2 ) - min ( layout ( :, 2 ) );
        layout = layout / max ( max ( layout ( :, [ 1 2 ] ) + layout ( :, [ 3 4 ] ) ) );

        switch handles.DISPLAY
   
            case 'Distributed'  
                for i = 1: length ( sensors );
                    % Creates the axes in the layout position and plots the data.
                    axes ( 'position', layout ( i, : ) .* [ .9 .6 .9 .6 ] + [ .05 .1 0 0 ], 'fontsize', 4 );
                    plot ( daxis, data ( :, i ) );
                    % Displays the channel number.
                    text ( 0, 1, sprintf ( ' %.0f', sensors ( i ) ), 'Color', 'r', ...
                        'fontsize', 6, 'VerticalAlignment', 'base', 'Units', 'normalized' )
                    % Set the axes limits.
                    xlim ( daxis ( [ 1 end ] ) );
                    ylim ( [ ymin ymax ] );
                    axis off;
                end
            
            case 'Aligned'
                
                % Normalizes the data between 0 and 1.
                data = zscore ( data );
                
                % Shiftes each channel from the previous one.
                adds  = ( 1: handles.project.channels );
                data  = data + adds  ( ones ( size ( data, 1 ), 1 ), : );
                
                % Plots the data.
                axes ( 'position', [ .1 .1 .8 .65 ] );
                plot ( daxis, data, 'b' );
                axis tight
                
                xlabel(xlab)
                ylabel('Num channel')

            case 'Butterfly'
                
                % Plots the data.
                axes ( 'position', [ .1 .15 .8 .5 ] );
                plot ( daxis, data );
                axis tight
        end
end



function HERMES_figure_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);

function subject_Callback(hObject, eventdata, handles)
handles.NSUBJ = str2double(get(hObject,'String'));
if handles.NSUBJ < 1
    handles.NSUBJ = 1;
    set(handles.subject,'String',handles.NSUBJ)
elseif handles.NSUBJ > numel(handles.project.subjects)
    handles.NSUBJ = numel(handles.project.subjects);
    set(handles.subject,'String',handles.NSUBJ)
end
handles = update(handles);
guidata(hObject,handles)

function prevSubject_Callback(hObject, eventdata, handles)
handles.NSUBJ =  str2double(get(handles.subject,'String'));
if handles.NSUBJ > 1
    handles.NSUBJ = handles.NSUBJ-1;
    set(handles.subject,'String',handles.NSUBJ)
end
enableML(handles);
handles = update(handles);
guidata(hObject,handles)


function nextSubject_Callback(hObject, eventdata, handles)
handles.NSUBJ = str2double(get(handles.subject,'String'));
if handles.NSUBJ < numel(handles.project.subjects)
    handles.NSUBJ = handles.NSUBJ+1;
    set(handles.subject,'String',handles.NSUBJ)
end
enableML(handles);
handles = update(handles);
guidata(hObject,handles)


function PDF_Callback(hObject, eventdata, handles)
set(gcf,'PaperPositionMode','auto')
name = ['Projects/',handles.project.filename,'/',handles.project.filename];
print('-dpsc','-append',[name,'.eps'])
ps2pdf('psfile',[name,'.eps'],'pdffile',[name,'.pdf']);


function condition_Callback(hObject, eventdata, handles)
handles.NCOND = get(handles.condition,'Value');
handles = update(handles);
guidata(hObject,handles)


function tStart_Callback(hObject, eventdata, handles)
minvalue = handles.project.time(1);
maxvalue = handles.T2;
optvalue = handles.project.time(1);
str1 = 'Signal view paramenters warning';
str2 = 'Time window starting';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 0);
handles.T1 = str2double(get(handles.tStart,'String'));
handles.T2 = str2double(get(handles.tEnd,'String'));
update(handles);


function tEnd_Callback(hObject, eventdata, handles)
minvalue = handles.T1;
maxvalue = handles.project.time(end);
optvalue = handles.project.time(end);
str1 = 'Signal view paramenters warning';
str2 = 'Time window starting';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 0);
handles.T1 = str2double(get(handles.tStart,'String'));
handles.T2 = str2double(get(handles.tEnd,'String'));
update(handles);


function display_Callback(hObject, eventdata, handles)
handles.DISPLAY = handles.display_options{ get(handles.display,'Value')};
guidata(hObject,handles)
update(handles);


function fStart_Callback(hObject, eventdata, handles)
minvalue = 0;
maxvalue = handles.F2;
optvalue = 0;
str1 = 'Signal view paramenters warning';
str2 = 'Frequency window starting';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 0);
handles.F1 = str2double(get(handles.fStart,'String'));
handles.F2 = str2double(get(handles.fEnd,'String'));
update(handles);


function fEnd_Callback(hObject, eventdata, handles)
minvalue = handles.F1;
maxvalue = floor(handles.project.fs/2);
optvalue = floor(handles.project.fs/2);
str1 = 'Signal view paramenters warning';
str2 = 'Frequency window starting';
H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, 0);
handles.F1 = str2double(get(handles.fStart,'String'));
handles.F2 = str2double(get(handles.fEnd,'String'));
update(handles);


function channel_Callback ( hObject, eventdata, handles )
update ( handles );


function enableML(handles)

subject = str2double ( get ( handles.subject, 'Value' ) );

% Updates the 'next subject' and 'previous subject' buttons.
if subject == 1 
    set ( handles.prevSubject, 'Enable', 'Off' )
else
    set ( handles.prevSubject, 'Enable', 'On' )
end

if subject == numel ( handles.project.subjects )
    set ( handles.nextSubject, 'Enable', 'Off' )
else
    set ( handles.nextSubject, 'Enable', 'On' )
end


function showChans_SelectionChangeFcn ( hObject, eventdata, handles )

if strcmp ( get ( hObject, 'Tag' ), 'singleChan' )
    set ( handles.channel, 'Enable', 'on'  )
    set ( handles.channel, 'String', '1'   )
    set ( handles.display, 'Enable', 'off' )
else
    set ( handles.channel, 'Enable', 'off' )
    set ( handles.channel, 'String', ''    )
    set ( handles.display, 'Enable', 'on'  )
end

update ( handles );


function showData_SelectionChangeFcn ( hObject, eventdata, handles )

if strcmp ( get ( hObject, 'Tag' ), 'timeData' )
    set ( handles.tStart, 'Enable', 'on'  )
    set ( handles.tEnd,   'Enable', 'on'  )
    set ( handles.fStart, 'Enable', 'off' )
    set ( handles.fEnd,   'Enable', 'off' )
else
    set ( handles.fStart, 'Enable', 'on'  )
    set ( handles.fEnd,   'Enable', 'on'  )
    set ( handles.tStart, 'Enable', 'off' )
    set ( handles.tEnd,   'Enable', 'off' )
end

update ( handles );
