function surrogate = H_surrogate ( data, varargin )
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

% If no option is selected, the method used is phase randomization.
if numel ( varargin ), option = varargin { 1 };
else option = 'phase'; end

% Conversion of the data to single precision float.
data = single ( data );
    
% If the option is change the phase, it is replaced for a random value.
if strcmp ( option, 'phase' )
    % Calculation of the FT of the data.
    ft_data = fft ( data, [], 1 );
    
    % Randomization of the phase of the data.
    semiphase  = rand ( floor ( ( size ( ft_data, 1 ) - 1 ) / 2 ), size ( data, 2 ), size ( data, 3 ), 'single' );
    
    % It's necessary to be sure that the phase is symmetric conjugate.
    phase = zeros ( size ( ft_data ) );
    
    phase ( 2: size ( semiphase, 1 ) + 1, :, : ) = semiphase;
    phase ( end - size ( semiphase, 1 ) + 1: end, :, : ) = flipdim ( semiphase, 1 );
    
    % Inclusion of the new phase in the signal.
    ft_surrogate = abs ( ft_data ) .* exp ( 1i * 2 * pi * phase );
    
    % Inverse FT.
    surrogate = ifft ( ft_surrogate, [], 1, 'symmetric' );
    
% If the option is to perform a suffling, we do so.
else
    surrogate = zeros ( size ( data ), 'single' );
    
    % Suffling of each signal.
    for sensor = 1: size ( data, 2 )
        for trial = 1: size ( data, 3 )
            for window = 1: size ( data, 4 )
                surrogate ( :, sensor, trial, window ) = data ( randperm ( size ( data, 1 ) ), sensor, trial, window );
            end
        end
    end
end