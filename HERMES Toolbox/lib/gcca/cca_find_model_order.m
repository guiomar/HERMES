function [ bic, aic ] = cca_find_model_order ( data, minP, maxP )
%-----------------------------------------------------------------------
% FUNCTION: cca_find_model_order.m
% PURPOSE:  use the Bayesian Information Criterion (BIC) and/or the Aikaike
%           Information Criterion to find the best model order (NLAGS)
%           for a multivariate data set.
% 
% INPUTS:   X: matrix of nvar variables by nobs observations of each variable by trials
%           MINP: minimum model order to consider
%           MAXP: maximum model order to consider
%
% OUTPUT:   bic: optimal model order according to BIC
%           aic: optimal model order according to Akaike Information Criterion (AIC)
%
%           Written by Anil Seth, March 2004
%           Updated August 2004
%           Updated December 2005
%           Ref: Seth, A.K. (2005) Network: Comp. Neural. Sys. 16(1):35-55
%-----------------------------------------------------------------------

% Modified by Ricardo Bruna
% Included in HERMES
% Original can be accessed in http://www.sussex.ac.uk/Users/anils/aks_code.htm

% Gets information about the input.
[ nvar, nl, ntr ] = size ( data );

nobs   = nl * ntr;
orders = minP: maxP;
data   = data ( :, : );

if nobs < nvar,  error ( 'Fewer observations than variables, exiting' ); end
if maxP <= minP, error ( 'MAXP must be bigger than MINP, exiting' ); end

% Reserves memory.
bc = zeros ( size ( orders ) );
ac = zeros ( size ( orders ) );

for i = 1: numel ( orders )
    try
        % Checks if the matrix is bi- or tri-dimensional.
        if ntr == 1
            res = cca_regress ( data, orders (i), 0 );
            E   = res.Z;
        else
            [ tmp, E ] = armorf ( data, ntr, nl, orders (i) );
        end
        
        % Estimates the error noise.
        nest = orders (i) * nvar ^ 2;
        Err  = log ( det ( E ) );
        
        % Calcultes the indexes from the error noise.
        bc (i) = Err + ( log ( nobs ) * nest / nobs );
        ac (i) = Err + ( 2 * nest / nobs );
        
        % If the first iteration gives as result an infinite, exits.
        if i == 1 && isinf ( bc (i) ) && isinf ( ac (i) )
            bic = NaN;
            aic = NaN;
            return
        end
        
        % If this iteration gives a value higher than the previous, exits.
        if i > 1 && bc (i) > min ( bc ) || ac (i) > min ( ac )
            bc = bc ( 1: i );
            ac = ac ( 1: i );
            break
        end
        
    catch %#ok<CTCH>
        bc (i) = NaN; 
        ac (i) = NaN;
    end
%     fprintf ( 1, 'VAR order %d, BIC = %.4f, AIC = %.4f.\n', orders (i), bc (i), ac (i) );
end

% Sets the optimal order as the one that minimizes the error.
[ tmp, bic ] = min ( bc );
[ tmp, aic ] = min ( ac );

bic = orders ( bic );
aic = orders ( aic );

% This file is part of GCCAtoolbox.  
% It is Copyright (C) Anil Seth (2005-2009) 
% 
% GCCAtoolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% GCCAtoolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with GCCAtoolbox.  If not, see <http://www.gnu.org/licenses/>.