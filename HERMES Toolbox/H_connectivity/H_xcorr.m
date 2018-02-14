function index = H_xcorr ( data, varargin )
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



% Setting of the automatic parameters.
[ samples, signals, trials ] = size ( data );

nfft   = pow2 ( nextpow2 ( 2 * samples - 1 ) );
maxlag = samples - 1;
mode   = 'none';

% Setting of the user parameters.
if numel ( varargin ) > 0 && ~isempty ( varargin {1} ), maxlag = varargin {1}; end
if numel ( varargin ) > 1 &&  ischar  ( varargin {2} ), mode   = varargin {2}; end

% If maxlag is equal to zero forces the normalization to coeff.
if maxlag == 0, mode = 'coeff'; end

% Setting of the correction index.
switch mode
    case 'coeff'
    energy = sqrt ( sum ( data .* conj ( data ), 1 ) );
    data = data ./ energy ( ones ( samples, 1 ), :, : );
    correction = 1;
    
    case 'biased'
    correction = samples;
    
    case 'unbiased'
    correction = samples - abs ( -maxlag: maxlag )';
    correction = correction ( :, ones ( signals, 1 ), ones ( signals, 1 ), ones ( trials, 1 ) );
    
    otherwise
    correction = 1;
    
end

% Fast method for 0-lag autocorrelation (Pearson correlation index).
if maxlag == 0
    
    % Gets the complex conjugate of the data.
    if ~isreal ( data ), cdata = conj ( data );
    else                 cdata = data;
    end
    
    index = zeros ( signals, signals, trials );
    
    for signal = 1: signals
        index ( :, signal, : ) = sum ( data .* cdata ( :, signal * ones ( signals, 1 ), : ), 1 );
    end

% FFT based method.
else
    
    % Gets the Fourier transform of the data.
    FT  = fft ( data, nfft, 1 );
    iFT = conj ( FT );
    
    % Gets the cross-spectra.
    crossspectrum = zeros ( size ( FT, 1 ), signals, signals, trials );
    
    for signal = 1: signals
        crossspectrum ( :, signal, :, : ) = FT .* iFT ( :, signal * ones ( signals, 1 ), :, : );
    end
    
    % Gets the indexes from the cross-spectrum and the lag indexes.
    lags  = [ nfft - maxlag + 1: nfft 1: maxlag + 1 ];
    index = ifft ( crossspectrum );
    index = index ( lags, :, :, : );
    
    % Applies the correction.
    if correction ~= 1, index = index ./ correction; end
    
end