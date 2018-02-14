function varargout = HERMES_filtering(varargin)
% HERMES_filtering M-file for HERMES_filtering.fig
%      HERMES_filtering, by itself, creates a new HERMES_filtering or raises the existing
%      singleton*.
%
%      H = HERMES_filtering returns the handle to a new HERMES_filtering or the handle to
%      the existing singleton*.
%
%      HERMES_filtering('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HERMES_filtering.M with the given input arguments.
%
%      HERMES_filtering('Property','Value',...) creates a new HERMES_filtering or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HERMES_filtering_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HERMES_filtering_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Copyright 2002-2003 The MathWorks, Inc.
% Edit the above text to modify the response to help HERMES_filtering
% Last Modified by GUIDE v2.5 27-Apr-2011 20:10:47
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
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HERMES_filtering_OpeningFcn, ...
                   'gui_OutputFcn',  @HERMES_filtering_OutputFcn, ...
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

function HERMES_filtering_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>

handles.dataset = varargin{1};

if isfield(handles.dataset,'FILTER')
    warndlg('Data previously filtered')
end

handles.calculado=0;

handles.fn=handles.dataset.SR/2; % Nyquist

N=min(1024, floor(handles.dataset.Nsamples/3)-1);% config
handles.order=N;
set(handles.F_order_edit,'String',num2str(N))

set(handles.OTHER_f1_edit,'Enable','off')
set(handles.OTHER_f2_edit,'Enable','off')

handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes HERMES_filtering wait for user response (see UIRESUME)
uiwait;

function varargout = HERMES_filtering_OutputFcn(hObject, eventdata, handles) 
if ~isfield(handles,'output'); % 'Cancel' button
    varargout{1} = [];
else
    varargout{1} = handles.output;
    close(gcf)
end

function OK_pushbutton_Callback(hObject, eventdata, handles) %#ok<*DEFNU>

if ~handles.calculado
    handles.FILTER=calculaFILT(handles);
end

handles.FILTER.data=filter_sensors(handles.dataset.data, handles.FILTER.config.coef);
handles.output=handles.FILTER;

guidata(hObject, handles)
uiresume

function Cancel_Button_Callback(hObject, eventdata, handles) %#ok<*INUSD>
close(gcf)

function ShowTF_pushbutton_Callback(hObject, eventdata, handles)

handles.FILTER=calculaFILT(handles); %%% F Y H sin normalizar!!!!!!

figure('Name','HERMES_Filtering');

band = handles.FILTER.config.band;
F = handles.FILTER.config.freq;
H = handles.FILTER.config.module;

% Module
subplot(2,1,1)
ff= (find(band(1)<=F*handles.fn/pi));
gg= (find(F(ff)*handles.fn/pi<=band(2)+1));

plot(F(ff(gg))*handles.fn/pi,10*log(abs(H(ff(gg)))),'b')
title(['Module (dB), Band: ', num2str(band(1)), '-', num2str(band(2)), 'Hz']);
xlabel('Hz'); ylabel('dB')
grid on; axis tight

% Phase
subplot(2,1,2)
plot(F(ff(gg))*handles.fn/pi,unwrap(angle(H(ff(gg)))),'g')
title(['Phase (rad), Band: ',num2str(band(1)),'-',num2str(band(2)),'Hz']);
xlabel('Hz'); ylabel('rad')
grid on; axis tight

handles.calculado=1;

function Fdata = filter_sensors(data, coef)

[Nchannels, Nsamples, Ntrials] = size(data);
Fdata=zeros(Nchannels, Nsamples, Ntrials);

h = waitbar(0,'Filtering signals...', 'Name','HERMES: Filtering');

if Ntrials ~=1
    
    for k = 1:Ntrials
        for n = 1:Nchannels
            waitbar(n/Nchannels);
            data1 = squeeze(data(n,:,:));
            Fdata(n,:,k) = filtfilt(coef, 1, data1(:,k));
        end
    end
else
    for n = 1:Nchannels
        waitbar(n/Nchannels);
        Fdata(n,:) = filtfilt(coef, 1, data(n,:));
    end
end
close(h);

function FILTER =calculaFILT(handles)

F1=0; F2=0;
if get(handles.OTHER_radiobutton,'Value')==1
    
    F1= str2double(get(handles.OTHER_f1_edit,'String'));
    F2= str2double(get(handles.OTHER_f2_edit,'String'));
    
    if isempty(F1) || isempty(F2)
        warndlg('Specify the limits of the band','Specify band'); return; end
    if F1 >= handles.fn || F2 >= handles.fn || F1 < 0 || F2 < 0
        str = ['Frequencies must be positive and lower than ',num2str(handles.fn),' Hz']; 
        warndlg(str,'Non valid band'); return; end
    if F2 <= F1
        warndlg('Higher frequency must be greater than lower frequency',...
            'Non valid band'); return; end
end

FILTERS={'DELTA','THETA','ALPHA','BETA','GAMMA','OTHER'};
BANDS={[0.01 4],[4 8],[8 12],[12 30], [30 100], [F1 F2]};

for i=1:length(FILTERS)

    if eval(['get(handles.',FILTERS{i},'_radiobutton,''Value'')==1']) 

        wn=BANDS{i};
        coef=fir1(handles.order,wn/handles.fn,'bandpass');
        [H,F]=freqz(coef);
        
        %%% guardo H y F normalizados????????

        FILTER.type='Filter';
        FILTER.name= FILTERS{i};
        FILTER.date=date;
        FILTER.config=struct('coef',coef,'module',H,'freq',F,'band',wn,'order',handles.order);

    end
end

function F_order_edit_Callback(hObject, eventdata, handles)
n1=str2double(get(handles.F_order_edit,'String'));
N=min(n1,handles.dataset.Nsamples/3-1); % Aviso ayuda de filtfit
handles.FILTER.order=N;
set(handles.F_order_edit,'String',num2str(N));


function DELTA_radiobutton_Callback(hObject, eventdata, handles)
set(handles.OTHER_f1_edit,'Enable','off')
set(handles.OTHER_f2_edit,'Enable','off')
function THETA_radiobutton_Callback(hObject, eventdata, handles)
set(handles.OTHER_f1_edit,'Enable','off')
set(handles.OTHER_f2_edit,'Enable','off')
function ALPHA_radiobutton_Callback(hObject, eventdata, handles)
set(handles.OTHER_f1_edit,'Enable','off')
set(handles.OTHER_f2_edit,'Enable','off')
function BETA_radiobutton_Callback(hObject, eventdata, handles)
set(handles.OTHER_f1_edit,'Enable','off')
set(handles.OTHER_f2_edit,'Enable','off')
function GAMMA_radiobutton_Callback(hObject, eventdata, handles)
set(handles.OTHER_f1_edit,'Enable','off')
set(handles.OTHER_f2_edit,'Enable','off')
function OTHER_radiobutton_Callback(hObject, eventdata, handles)
set(handles.OTHER_f1_edit,'Enable','on')
set(handles.OTHER_f2_edit,'Enable','on')


function OTHER_f1_edit_Callback(hObject, eventdata, handles)
function OTHER_f2_edit_Callback(hObject, eventdata, handles)
function OTHER_f1_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function OTHER_f2_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function F_order_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FILT_figure_CloseRequestFcn(hObject, eventdata, handles)
delete(hObject);
