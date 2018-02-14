function sizes = H_size ( data, dimensions )
% H_SIZE   Extension to Matlab SIZE function.
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
% ** Please cite: 
% Niso G, Bruna R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Ricardo Bruna, 2012
%

% Infinite indexing is only valid with linear dimensions vectors.
if any ( isinf ( dimensions (:) ) ) && sum ( size ( dimensions ) > 1 ) > 1, error ( 'Infinite indexing is valid with linear dimension inputs only.' ); end

% dimensions vector must be integer.
if any ( dimensions (:) ~= round ( dimensions (:) ) ), error ( 'Dimensions vector must be formed by integers or infinites.' ); end
if any ( isnan ( dimensions (:) ) ),                   error ( 'Dimensions vector must be formed by integers or infinites.' ); end

% If there is infinite indexing, reconstruct the vector.
if any ( isinf ( dimensions (:) ) )
    
    % Creates the cell to perform the expansion.
    expanded = cell ( size ( dimensions ) );
    
    % Goes through all the values.
    for value = 1: numel ( expanded )
        
        % The sucession [ x inf ] means [ x: ndims ].
        if isinf ( dimensions ( value ) )
            
            % If the infinite is in the begining of the vector, takes [ 1 inf ].
            if value == 1, start = 1;
            else           start = dimensions ( value - 1 ) + 1;
            end
            
            % Constructs [ x: ndims ].
            vector = start: ndims ( data );
            
            % Reshapes the vectors to match the original aligniation.
            shape = ones ( 1, max ( ndims ( vector ), find ( size ( dimensions ) > 1 ) ) );
            shape ( size ( dimensions ) > 1 ) = numel ( vector );
            
            expanded { value } = reshape ( vector, shape );
            
        % If the element is finite, continues.
        else
            expanded { value } = dimensions ( value );
        end
    end
    
    % Concatenates all the expanded vectors.
    dimensions = cell2mat ( expanded );
end

% Constructs the sizes vector with the same size as the dimensions vector.
sizes = zeros ( size ( dimensions ) );

% Fills the sizes version with each dimension size.
for dimension = 1: numel ( dimensions )
    
    % If dimension is 0 or negative, returns size 1.
    if dimensions ( dimension ) < 1
        sizes ( dimension ) = 1;
        
    % Otherwise returns the dimension size.
    else
        sizes ( dimension ) = size ( data, dimensions ( dimension ) );
        
    end
end