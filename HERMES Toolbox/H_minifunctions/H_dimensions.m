function dimensions = H_dimensions ( index, config, project )
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


% Determine the dimensions of the calculated indexes' matrix.
switch index
    case { 'PLV' 'PLI' 'wPLI', 'RHO', 'DPI' },  dimensions = { 'sensor' 'sensor' 'band' 'time' };
    case { 'GC' },                              dimensions = { 'sensor' 'sensor' 'time' };
    case { 'PDC' 'DTF' },                       dimensions = { 'sensor' 'sensor' 'frequency' 'time' };
    case { 'S' 'H' 'M' 'N' 'L' 'SL' },          dimensions = { 'sensor' 'sensor' 'time' };
    case { 'COR', 'PSI' },                      dimensions = { 'sensor' 'sensor' 'time' };
    case { 'xCOR' },                            dimensions = { 'sensor' 'sensor' 'lag' 'time' };
    case { 'COH' 'iCOH' },                      dimensions = { 'sensor' 'sensor' 'frequency' 'time' };
    case { 'MI' , 'TE', 'PMI','PTE'},           dimensions = { 'sensor' 'sensor' 'time'};
    otherwise,                                  dimensions = cell (0); return
end

% Makes space for the values of each dimension.
dimensions { 2, end } = [];

% Calculates the beginning and end of each temporal window.
if any ( strcmp ( dimensions (:), 'time' ) )
    
    datasize = project.samples;
    
    wlen = round ( config.window.length * project.fs / 1000 );
    step = floor ( wlen * ( 1 - config.window.overlap / 100 ) );
    
    % Discards the first segment if alignemnt with the stimulus is enabled.
    if strcmp ( config.window.alignment, 'stimulus' )
        shift = rem ( sum ( project.time < 0 ), wlen );
    else
        shift = 0;
    end
    
    steps = 0: floor ( ( datasize - wlen - shift ) / step );
    windows = [ steps' * step + 1, steps' * step + wlen ] + shift;
    windows = project.time ( windows );
    
    dimensions { 2, strcmp ( dimensions ( 1, : ), 'time' ) } = windows;
end

% Calculates the DFT frequencies.
if any ( strcmp ( dimensions (:), 'frequency' ) )
    
    samples   = round ( config.window.length * project.fs / 1000 );
    
    % If the data has enough trials, the data is not windowed.
    if any ( ismember ( index, { 'COH' 'iCOH' } ) ) && config.trials
        wlen    = samples;
        nfft    = max ( 256, pow2 ( nextpow2 ( wlen ) ) );
        
    % Otherwise the data is segmented in nine overlapping windows.
    else
        wlen    = 2 * floor ( samples / 9 );
        nfft    = max ( 256, pow2 ( nextpow2 ( wlen ) ) );
    end
    
    % For PDC/DTF the nfft depends on the order of the MAR model.
    if ismember ( index, { 'PDC' 'DTF' } )
        nfft = max ( pow2 ( nextpow2 ( config.orderMAR ) ), 64 );
    end
    
    % Labels the frequency data as nfft/2 values between 0 and fs/2.
    frequency = linspace ( 0, project.fs / 2, ceil ( ( nfft + 1 ) / 2 ) );
    
    % Stores the frequencies as a column vector.
    dimensions { 2, strcmp ( dimensions ( 1, : ), 'frequency' ) } = frequency (:);
end

% Calculates the beginning and end of the frequency bands.
if any ( strcmp ( dimensions (:), 'band' ) )

    bands = [ config.bandcenter' - config.bandwidth / 2, config.bandcenter' + config.bandwidth / 2 ];
    bands ( bands < 0 ) = 0;
    bands ( bands > project.fs / 2 ) = project.fs / 2;
    
    dimensions { 2, strcmp ( dimensions ( 1, : ), 'band' ) } = bands;
end

% Calculates the lag in ms.
if any ( strcmp ( dimensions (:), 'lag' ) )

    lags = ( -config.maxlags: config.maxlags ) / project.fs * 1000;
    
    % Stores the lags as a column vector.
    dimensions { 2, strcmp ( dimensions ( 1, : ), 'lag' ) } = lags (:);
end