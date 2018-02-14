function data = H_filtfilt ( numerator, denominator, data, hilbert )
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
% Authors:  Ricardo Bruna, 2014
%


% Raises an error if the filter is IIR.
if ~isscalar ( denominator ), error ( 'This functions does not accept IIR filters yet' ); end

% If empty, sets false to the 'perform Hilbert filtering' variable.
if nargin < 4, hilbert = false; end

% Gets the filter order.
order    = numel ( numerator ) - 1;

% If the imput is a row, marks it to convert to a colunm.
trans    = ( size ( data, 1 ) == 1 );

% Traspose the input, if necesary.
if trans, data = permute ( data, [ 2 1 3 ] ); end

% The maximum filter order is a third of the data length.
if order > size ( data, 1 ), error ( 'Data must have length more than 3 times filter order.' ); end

% Calculates the 'butterfly' reflections.
prepad   = bsxfun ( @minus, 2 * data ( 1,   :, : ), data ( order + 1: -1: 2, :, : ) );
pospad   = bsxfun ( @minus, 2 * data ( end, :, : ), data ( end - 1: -1: end - order, :, : ) );

% Concatenates the reflections to the data.
data     = cat  ( 1, prepad, data, pospad );

% Gets the metadata.
samples  = size ( data, 1 );
chans    = size ( data, 2 );
trials   = size ( data, 3 );

% Gets the optimal FFT length.
nfft     = optnfft ( samples );

% Gets the FFT of the data.
f_data   = fft  ( data, nfft, 1 );

% Gets the squared module of the FFT of the filter.
f_num    = fft  ( numerator   (:), nfft, 1 );
f_den    = fft  ( denominator (:), nfft, 1 );

f_filter = f_num ./ f_den;
f_filter = f_filter .* conj ( f_filter );
    
% Applies the Hilbert filter, if desired.
if hilbert
    
    % Removes the negative part of the spectrum.
    f_filter ( ceil ( ( nfft + 1 ) / 2 + 1 ): end ) = 0;
    
    % Duplicates the positive part of the spectrum.
    f_filter ( 2: floor ( ( nfft + 1 ) / 2 ) ) = 2 * f_filter ( 2: floor ( ( nfft + 1 ) / 2 ) );
end

% Applies the filter.
f_data   = f_data .* f_filter ( :, ones ( chans, 1 ), ones ( trials, 1 ) );

% Gets the filtered data.
data     = ifft ( f_data, nfft, 1 );
data     = data ( 1: samples, :, : );

% Removes the 'butterfly' reflections.
data     = data ( size ( prepad, 1 ) + 1: end - size ( pospad, 1 ), :, : );

% Converts the output in a row, if necesary.
if trans, data = permute ( data, [ 2 1 3 ] ); end



function nfft = optnfft ( samples )
% Looks for the optimal number of points of the FFT.

% If the number of samples is less than 50 000, uses the optimal value.
if samples <= 50000
    
    % Gets the list of optimal FFT lengths.
    onffts = importdata ( H_path ( 'HERMES', 'private', 'onffts.mat' ) );
    
    % Gets the 
    nfft   = min ( onffts ( onffts >= samples ) );
    nfft   = double ( nfft );
    
    % Exits.
    return
end

% If the number is samples is too high, estimates the optimal FFT length.

% Defines the combinations to try.
bases  = [ 2 3 5 7 ];
shifts = [ 1 2 3 4 5 6 ];
combs  = combvec ( bases, shifts )';

% Reserves memory.
nffts = zeros ( size ( combs, 1 ), 1 );
maxs  = zeros ( size ( combs, 1 ), 1 );

% Tries the combinations.
for comb = 1: size ( combs, 1 )
    
    % Gets the current base and shift.
    base  = combs ( comb, 1 );
    shift = combs ( comb, 2 );
    
    % Gets the base for this combination of values.
    root  = ceil ( log ( samples ) / log ( base ) ) - shift;
    root  = max ( root, 0 );
    
    % Calculates the FFT length for this combination of values.
    round ( ceil ( samples / base .^ root ) * base .^ root );
    nffts ( comb ) = ceil ( samples / base .^ root ) * base .^ root;
    
    % Gets the maximum factor for this FFT length.
    maxs  ( comb ) = max ( factor ( nffts ( comb ) ) );
end

% Selects the combination with the smaller factors.
[ ~, optimal ] = min ( maxs );
nfft = nffts ( optimal );
