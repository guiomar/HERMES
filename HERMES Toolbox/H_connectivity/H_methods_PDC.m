function output = H_methods_PDC ( data, config, waitbar )
% H_PDCMETHODS PDC and DTF calculation.
%   
%   OUTPUT = H_PDCMETHODS(X,CONFIG)
%
%   H_PDCMETHODS calculates the PDC and DTF connectivity in the signals
%   given in the columns of the matrix X using a MVAR model computed using
%   the ARFIT package.
%
%   OUTPUT.PDF and OUTPUT.DTF are the Partial Directed Coherence and Direct
%   Transfer Function obtained according to Pereda et ï¿½l. 2005.
%
%   CONFIG is a structure with fields:
%   - ORDERMAR: Indicates the order of the MVAL model.
%   - NFFT: Indicates the length of the Fourier transform used to compute
%     the PDC and DTF algorithms. NFFT refers only to the possitive part of
%     the spectra, ie., samples between 0 and the Nyquist frequency.
%
%   References:
%     [1] Ernesto Pereda et al., Nonlinear multivariate analysis of
%         neurophysiological signals, Progress in Neurobiology, vol. 77,
%         pp. 1-37, 2005.
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
% Authors:  Ricardo Bruna, 2011
%           Guiomar Niso, Ricardo Bruna, Ricardo Gutierrez 2012
%

% Checks the completitude of the configuration structure.
if ~isfield ( config, 'measures' ), config.measures = {};        end
if ~isfield ( config, 'orderMAR' ), config.orderMAR = 3;         end
if ~isfield ( config, 'nfft' ),     config.nfft     = 64;        end
if ~isfield ( config, 'window' ),   config.window   = struct (); end

if ~isfield ( config.window, 'length' ),    config.window.length    = size ( data, 1 ); end
if ~isfield ( config.window, 'overlap' ),   config.window.overlap   = 0;                end
if ~isfield ( config.window, 'alignment' ), config.window.alignment = 'epoch';          end
if ~isfield ( config.window, 'fs' ),        config.window.fs        = 256;              end
if ~isfield ( config.window, 'baseline' ),  config.window.baseline  = 0;                end

% Checks the existence of the waitbar.
if nargin < 3, waitbar = []; end

% Fetchs option data
PDC_on = H_check ( config.measures, 'PDC' );
DTF_on = H_check ( config.measures, 'DTF' );

% Fixes the length of the fft.
config.nfft = max ( pow2 ( nextpow2 ( config.orderMAR ) ), 64 );

% Windows the data.
data = H_window ( data, config.window );

% Gets the size of the analysis data.
[ samples, channels, windows, trials ] = size ( data ); %#ok<ASGLU,NASGU>
data = permute ( data, [ 1 2 4 3 ] );

% Reserves the needed memory.
if PDC_on, output.PDC.data = zeros ( channels, channels, config.nfft, windows ); end
if DTF_on, output.PDC.data = zeros ( channels, channels, config.nfft, windows ); end

% Throttled user cancelation check vars
interval_between_checks = 0.2; % in seconds
tic;

% Calculates the indexes for each window.
for window = 1: windows
    
%     % Calculates the model using ARfit.
%     [ w A ] = arfit ( squeeze ( data ( :, :, :, window ) ), config.orderMAR, config.orderMAR );
    
    % Calculates the model using a modified version of ARfit.
    A = H_arfit ( data ( :, :, :, window ), config.orderMAR );
    A = reshape ( A, channels, channels, [] );

    % Claculates A(f).
    B = zeros ( size ( A ) + [ 0 0 1 ] );
    B ( :, :, 2: config.orderMAR + 1 ) = A;
    A = B;
    Af = fft ( A, 2 * config.nfft, 3 );
    Af = Af ( :, :, 1: config.nfft );
    
    % Reserves memmory for Bf and the normalization matrixes.
    Bf = zeros ( size ( Af ) );
    Af_norm = zeros ( size ( Af ) );
    Bf_norm = zeros ( size ( Af ) );
    
    % Calculates A_(f) and B(f) from A(f).
    for f = 1: config.nfft
        Af ( :, :, f ) = eye ( channels ) - Af ( :, :, f );
        if DTF_on, Bf ( :, :, f ) = inv ( Af ( :, :, f ) ); end
        
        % Creates the normalization matrixes for A and B.
        for j = 1: channels
            if PDC_on, Af_norm ( :, j, f ) = norm ( Af ( :, j, f ) ); end
            if DTF_on, Bf_norm ( j, :, f ) = norm ( Bf ( j, :, f ) ); end
        end
        
        % Checks for user cancelation (Throttled)
        if toc > interval_between_checks
            tic;
            if ( H_stop ), return, end
        end
    end

    % Calculates the coherence measures.
    if PDC_on, output.PDC.data ( :, :, :, window ) = abs ( Af ) ./ Af_norm; end
    if DTF_on, output.DTF.data ( :, :, :, window ) = abs ( Bf ) ./ Bf_norm; end
    
    
    % Checks for user cancelation (Throttled)
    if toc > interval_between_checks
        tic;
        if ( H_stop ), return, end
    end
    
    % Updates the progress bar.
    if isstruct ( waitbar )
        waitbar.progress ( 5: 6 ) = [ window windows ];
        waitbar = H_waitbar ( waitbar );
    end
end

% Order directionality in the stablished way: 
% Element (i,j) indicates i->j
if PDC_on, output.PDC.data = permute ( output.PDC.data, [ 2 1 3 4 ] ); end
if DTF_on, output.DTF.data = permute ( output.DTF.data, [ 2 1 3 4 ] ); end

