function output = H_methods_GC ( data, config, waitbar )
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
% Niso G, Bruña R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%


% Checks the completitude of the configuration structure.
% if ~isfield ( config, 'measures' ),  config.measures  = {};        end
% if ~isfield ( config, 'orderAR' ),   config.orderAR   = 10;        end
% if ~isfield ( config, 'bandwidth' ), config.bandwidth = 4;         end
% if ~isfield ( config, 'window' ),    config.window    = struct (); end
% 
% if ~isfield ( config.window, 'length' ),    config.window.length    = size ( data, 1 ); end
% if ~isfield ( config.window, 'overlap' ),   config.window.overlap   = 0;                end
% if ~isfield ( config.window, 'alignment' ), config.window.alignment = 'epoch';          end
% if ~isfield ( config.window, 'fs' ),        config.window.fs        = 256;              end
% if ~isfield ( config.window, 'baseline' ),  config.window.baseline  = 0;                end




% Checks the existence of the waitbar.
if nargin < 3, waitbar = []; end

% Windows the data.
data = H_window ( data, config.window );

% Gets the size of the analysis data.
[ samples, channels, windows, trials ] = size ( data );

% Calculates the window size, the overlapping and the nfft value.
output.GC.rawdata = zeros ( channels, channels, windows, trials );

% Throttled variables.
interval_between_checks = 0.1;
tic

% Calculates the AR models for each vector.
models = cell ( channels, windows, trials );
for model = 1: numel ( models )
    models { model } = createModel ( data ( :, model ), config.orderAR );
end

for trial = 1: trials
    for window = 1: windows
        for ch1 = 1: channels - 1
            for ch2 = ch1 + 1: channels
                
                if ( H_stop ), return, end
                
                Mx  = models { ch1, window, trial };
                My  = models { ch2, window, trial };
                Mxy = [ Mx My ];
                Myx = [ My Mx ];
                
                
                ey_y  = modelError ( data ( config.orderAR + 1: end, ch2, window, trial ), My,  samples, config.orderAR );
                ex_x  = modelError ( data ( config.orderAR + 1: end, ch1, window, trial ), Mx,  samples, config.orderAR );
                ey_xy = modelError ( data ( config.orderAR + 1: end, ch2, window, trial ), Mxy, samples, config.orderAR );
                ex_xy = modelError ( data ( config.orderAR + 1: end, ch1, window, trial ), Mxy, samples, config.orderAR );
%                 ex_xy = modelError ( data ( config.orderAR + 1: end, i ), Myx, samples, config.orderAR );
                
                output.GC.rawdata ( ch1, ch2, window, trial ) = log ( var ( ey_y ) / var ( ey_xy ) );
                output.GC.rawdata ( ch2, ch1, window, trial ) = log ( var ( ex_x ) / var ( ex_xy ) );
            end
            
            
            % Throttled check.
            if toc > interval_between_checks
                tic
                
                % Checks for user cancelation.
                if ( H_stop ), return, end
                
                % Updates the waitbar.
                if ~isempty ( waitbar )
                    waitbar.progress ( 5: 6 ) = [ trial trials ];
                    waitbar.progress ( 7: 8 ) = [ window windows ];
                    waitbar.progress ( 9 )    = ( 2 * channels - ch1 ) * ( ch1 - 1 ) / 2;
                    waitbar.progress ( 10 )   = channels * ( channels - 1 ) / 2;
                    waitbar                   = H_waitbar ( waitbar );
                end
            end
        end
    end
    
    % Checks for user cancelation (Throttled)
    if toc > interval_between_checks
        if ( H_stop ), return, end
    end
end

% Averages across trials.
output.GC.data  = mean ( output.GC.rawdata, 4 );

% Removes the trial information.
output.GC = rmfield ( output.GC, 'rawdata' );


function E = modelError ( y, model, N, Q )

M1 = ones ( N - Q, 1 );
H = regress ( y, [ M1 model ] );
Y_x = [ M1 model ] * H;
E = y - Y_x;


function model = createModel ( X, order )

model = convmtx ( X, order );
model = model ( order: end - order, : );
model = flipdim ( model, 2 );
