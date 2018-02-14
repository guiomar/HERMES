function spectrum = H_spectrum ( data, type, varargin )
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
% Authors:  Guiomar Niso, Ricardo Bruna, 2012
%


% Default parameters.
[ samples, signals, trials ] = size ( data );
step = floor ( samples / 9 );
wlen = step * 2;
win  = hamming ( wlen );
nfft = max ( 256, pow2 ( nextpow2 ( wlen ) ) );

% User defined parameters.
if numel ( varargin ) > 0 && ~isempty ( varargin { 1 } ), win  = varargin { 1 }; wlen = length ( win ); nfft = max ( 256, pow2 ( nextpow2 ( wlen ) ) ); end
if numel ( varargin ) > 1 && ~isempty ( varargin { 2 } ), step = wlen - varargin {2}; end
if numel ( varargin ) > 2 && ~isempty ( varargin { 3 } ), nfft = varargin {3}; end

if numel ( varargin ) > 0 && numel ( varargin {1} ) == 1 && varargin {1} == 0, wlen = samples; win = rectwin ( samples ); step = 1; end

% Calculation of the number of segments.
segments = floor ( ( samples - wlen ) / step ) + 1;

% Window matrix construction from the selected window modified to imprement
% the scalations.
win = win  / norm ( win ) / sqrt ( pi );
win  = win ( :, ones ( signals, 1 ), ones ( trials, 1 ) );

% Windowing of the data.
windowed = zeros ( wlen, signals, trials, segments );
for s = 1: segments, windowed ( :, :, :, s ) = win .* data ( ( s - 1 ) * step + ( 1: wlen ), :, : ); end

% Fourier transform of the windowed data.
FT = fft ( windowed, nfft, 1 );
FT = FT ( 1: ceil ( ( nfft + 1 ) / 2 ), :, :, : );
FT ( [ 1 end ], :, :, : ) = FT ( [ 1 end ], :, :, : ) / sqrt ( 2 );

% Construction of the Welch periodogram.
if any ( strcmp ( type, { 'welch' 'coherence' } ) )
    
    welch = mean ( FT .*  conj ( FT ), 4 );
    
    if strcmp ( type, 'welch' ), spectrum = welch; return, end
end

% Construction of the cross-spectrum.
if any ( strcmp ( type, { 'cross' 'coherence' } ) )
    
    crossspectrum = zeros ( [ size( FT, 1 ) signals signals trials ] );
    for i = 1: signals
        FTi = conj ( FT ( :, i, :, : ) );
        FTi = FTi ( :, ones ( signals, 1 ), :, : );
        crossspectrum ( :, i, :, : ) = mean ( FT .* FTi, 4 );
    end
    
%     FT1 = repmat ( reshape ( FT,          [ ceil( ( nfft + 1 ) / 2 ) 1 signals trials segments ] ), [ 1 signals 1 1 1 ] );
%     FT2 = repmat ( reshape ( conj ( FT ), [ ceil( ( nfft + 1 ) / 2 )
%     signals 1 trials segments ] ), [ 1 1 signals 1 1 ] );
%     crossspectrum = FT1 .* FT2;
    
    if segments > 1, crossspectrum = mean ( crossspectrum, 5 ); end
    
    if strcmp ( type, 'cross' ), spectrum = crossspectrum; return, end
end

% Construction of the coherence.
if strcmp ( type, 'coherence' )
    
%     denominator = zeros ( [ size( FT, 1 ) size( FT, 2 ) size( FT, 2 ) size( FT, 3 ) ] );
%     for i = 1: size ( FT, 2 );
%         welchi = repmat ( welch ( :, i, :, : ), [ 1 size( FT, 2 ) 1 1 ] );
%         denominator ( :, i, :, : ) = welch .* welchi;
%     end
%     coeherence = abs ( crossspectrum ) .^ 2 ./ denominator;
    
    welch1 = reshape ( welch, [ size( welch, 1 ) 1 signals trials ] );
    welch2 = reshape ( welch, [ size( welch, 1 ) signals 1 trials ] );
    
    welchs = welch1 ( :, ones ( signals, 1 ), :, : ) .* welch2 ( :, :, ones ( signals, 1 ), : );
    
    coherence = crossspectrum .* conj ( crossspectrum ) ./ welchs;
    
    spectrum = coherence;
end
