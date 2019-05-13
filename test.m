clc; clear; close 

% Add Hermes to path
addpath(genpath('/export02/data/guiomar/HERMES/HERMES Toolbox 2016-01-28'));

% Data path
mydir = '/export02/data/guiomar/Hermes_test/';

% Load data
data = importdata ([mydir,'example_connectivity.mat']); % Nchannels x Nsamples x (Ntrials)


%% HERMES config file

% General project specifications

config.fs           = 250;    % Sampling rate (in Hz)
config.baseline     = -2500;  % Baseline period (in ms)
config.statistics   = 0;      % (0=no,1=yes)
config.surrogates   = 0;      % Number of surrogates (for statistics)


% Metrics to compute
config.measures = {'PLV'}; %(cell: {'COR','COH'})

% Specific parameter for some PS metrics
config.bandcenter   = [6];
config.bandwidth    = 4;

config.window.length  = 500;
config.window.overlap = 0;
config.window.alignment = 'stimulus'; % 'epoch'

%% Compute Connectivity metrics

indexes = H_compute_PS_commandline ( data, config )
