function dimension = fnn ( x, tao )
% Calculation of the false nearest neighbours.

% Based on the reference:
%   M. B. Kennel, R. Brown, and H. D. I. Abarbanel, Determining
%   embedding dimension for phase-space reconstruction using a geometrical 
%   construction, Phys. Rev. A 45, 3403 (1992).
% 
% Author: Merve Kizilkaya
% Editated by: Ricardo Bruna

% Modified to stop after reducing the number of neighbours to 10%.

% Sets the initial parameters to the defaults.
mmax = 20;
rtol = 15;
atol = 2;

% Gets the metadata.
N  = numel ( x );
Ra = std ( x );

% Checks the number of neighbours increasing the dimension.
for dimension = 1: mmax
    M = N - dimension * tao;
    
    Y = psr ( x, dimension, tao, M );
    
    % Initializes the value.
    FNN = 0;
    
    % Checks each point to see if it's a neighbour.
    for n = 1: M
        
        y0 = ones ( M, 1 ) * Y ( n, : );
        
        distance = sqrt ( sum ( ( Y - y0 ) .^ 2, 2 ) );
        [ neardis nearpos ] = sort ( distance );
        
        D = abs ( x ( n + dimension * tao ) - x ( nearpos ( 2 ) + dimension * tao ) );
        R = sqrt ( D .^ 2 + neardis ( 2, : ) .^ 2 );
        
        % Stores the value if the distance is small enough.
        FNN = FNN + ( D ./ neardis ( 2, : ) > rtol | R / Ra > atol )';
    end
    
    % In the first iteration stores the original number of neighbours.
    if ( dimension == 1 ),
        FNN0 = FNN;
        
    % If the number of neighbours is under 10% of the initial, stops.
    elseif FNN < FNN0 / 10
        return
    end
    
end

% Sets the ouput to NaN if no dimension was found.
dimension = NaN;


function Y = psr ( x, m, tao, M )

% Creates the indexes matrix from the delays and the jumps.
delays  = ( 1: M )';
jumps   = tao * ( 0: m - 1 );
indexes = delays ( :, ones ( m, 1 ) ) + jumps ( ones ( M, 1 ), : );

% Returns the matrix.
Y = x ( indexes );
