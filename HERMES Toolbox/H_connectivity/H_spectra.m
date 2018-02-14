function output = H_spectra ( data, type, varargin )
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
% Authors:  Ricardo Bruna, 2012
%


% Gets the size of the data.
[ samples, signals, trials ] = size ( data );

% If trials are provided, each trial is considered a segment.
% if ~ismatrix ( data )
if ndims ( data ) ~= 2
    windowed = reshape ( data, samples, signals, 1, trials );
    nfft     = max ( 256, pow2 ( nextpow2 ( samples ) ) );
    trials   = 1;

% Otherwise uses the windowing approach.
else
    % Default parameters.
    step = floor ( samples / 9 );
    wlen = step * 2;
    win  = hamming ( wlen );
    nfft = max ( 256, pow2 ( nextpow2 ( wlen ) ) );
    
    % User defined parameters.
    if numel ( varargin ) > 0 && ~isempty ( varargin {1} ), win  = varargin {1}; wlen = length ( win ); nfft = max ( 256, pow2 ( nextpow2 ( wlen ) ) ); end
    if numel ( varargin ) > 1 && ~isempty ( varargin {2} ), step = wlen - varargin {2}; end
    if numel ( varargin ) > 2 && ~isempty ( varargin {3} ), nfft = varargin {3}; end
    
    if numel ( varargin ) > 0 && numel ( varargin {1} ) == 1 && varargin {1} == 0, wlen = samples; win = rectwin ( samples ); step = 1; end
    
    % Calculation of the number of segments.
    segments = floor ( ( samples - wlen ) / step ) + 1;
    
    % Window matrix construction from the selected window modified to imprement
    % the scalations.
    win = win / norm ( win ) / sqrt ( pi );
    win = win ( :, ones ( signals, 1 ), ones ( trials, 1 ) );
    
    % Windowing of the data.
    windowed = zeros ( wlen, signals, trials, segments );
    for s = 1: segments, windowed ( :, :, :, s ) = win .* data ( ( s - 1 ) * step + ( 1: wlen ), :, : ); end
end


% Fourier transform of the segmented data.
FT = fft ( windowed, nfft, 1 );
FT = FT ( 1: ceil ( ( nfft + 1 ) / 2 ), :, :, : );
FT ( [ 1 end ], :, :, : ) = FT ( [ 1 end ], :, :, : ) / sqrt (2);

% Construction of the Welch periodogram.
if any ( strcmp ( type, { 'welch' 'coherence' 'icoherence' } ) )
    
    welch = mean ( FT .*  conj ( FT ), 4 );
end

% Construction of the cross-spectrum.
if any ( strcmp ( type, { 'cross' 'coherence' 'icoherence' } ) )
    
    crossspectrum = zeros ( size ( FT, 1 ), signals, signals );
    
    for signal = 1: signals
        FTi = conj ( FT ( :, signal, :, : ) );
        FTi = FTi ( :, ones ( signals, 1 ), :, : );
        crossspectrum ( :, signal, : ) = mean ( FT .* FTi, 4 );
    end
end

% Construction of the complex coherence.
if any ( strcmp ( type, { 'coherence' 'icoherence' } ) )
    
    % Coherence requires the square root of the product of the spectra.
    sqrtwelch = sqrt ( welch );
    
    sqrtwelch1 = reshape ( sqrtwelch, [], 1, signals, trials );
    sqrtwelch2 = reshape ( sqrtwelch, [], signals, 1, trials );
    sqrtwelchs = sqrtwelch1 ( :, ones ( signals, 1 ), :, : ) .* sqrtwelch2 ( :, :, ones ( signals, 1 ), : );
    
    coherence = crossspectrum ./ sqrtwelchs;
end

% Returns the requested output.
switch type
    case 'welch',      output = welch;
    case 'cross',      output = crossspectrum;
    case 'coherence',  output = coherence .* conj ( coherence );
    case 'icoherence', output = imag ( coherence ) .^ 2 ./ ( 1 - real ( coherence ) .^ 2 );
end
