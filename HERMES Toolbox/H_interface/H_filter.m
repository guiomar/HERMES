function filters = H_filter ( bandcenters, bandwidth, order )
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
% Niso G, Bruña R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, Ricardo Bruna, 2012
%

bandpass = [ ( bandcenters ( : ) - bandwidth ) ( bandcenters ( : ) + bandwidth ) ];

filters = cell ( 1, size ( bandpass, 1 ) );

for filter = 1: size ( bandpass, 1 )
    % Si la banda comprende de 0 a 1, se crea un filtro paso-todo.
    if bandpass ( filter, 1 ) <= 0 && bandpass ( filter, 2 ) >= 1
        filters { filter } = [ 1 0 ];
        
    % Si la banda comprende el 0, se crea un filtro paso-bajo.
    elseif bandpass ( filter, 1 ) <= 0
        filters { filter } = fir1 ( order, bandpass ( filter, 2 ) );
        
    % Si la banda comprende el 1, se crea un filtro paso-alto.
    elseif bandpass ( filter, 2 ) >= 1
        filters { filter } = fir1 ( order, bandpass ( filter, 1 ), 'high' );
        
    % Si la banda no comprende 0 ni 1 se crea un filtro paso-banda.
    else
        filters { filter } = fir1 ( order, bandpass ( filter, : ) );
    end
end