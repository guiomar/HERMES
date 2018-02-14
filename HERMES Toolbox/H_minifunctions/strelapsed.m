function string = strelapsed ( varargin ) % ( seconds, maxunits, format )
% STRELAPSED Outputs the formated remaining time.
%   
%   S = STRELAPSED(T) creates a string S by splitting the time T in weeks,
%   days, hours, minutes and seconds. If the input is lower than 1, the
%   output is given in milliseconds.
%   
%   S = STRELAPSED(T,MAX) creates a string with a maximum of MAX output
%   units.
%   
%   S = STRELAPSED(T,MAX,FORMAT) creates a string with a maximum of MAX
%   units and with a format defined by FORMAT:
%   
%   - If FORMAT is 'short' the short form of the units is used (i.e. w, d,
%     h, min, s, ms).
%   - If FORMAT is 'long' the long form of the unit is used.
%
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
% Authors:  Guiomar Niso, Ricardo Bruna, 2012
%


% Fulfills the input variables.
if nargin < 1, error 'No time has been provided';
else           seconds = varargin { 1 };          end
if nargin > 1, maxunits = varargin { 2 };
else           maxunits = 6;                      end
if nargin > 2, format = varargin { 3 };
else           format = 'long';                   end

% Defines the units.
if strcmp ( format, 'short' ), units = { 'w' 'd' 'h' 'min' 's' 'ms' };
else                           units = { ' weeks' ' days' ' hours' ' minutes' ' seconds' ' milliseconds' };
end

% Defines the relation between units.
factors = [ 7*24*60*60 24*60*60 60*60 60 1 0.001 ];

% If the time is 0 exits.
if seconds < 1
    string = sprintf ( '%.0f%s', round ( seconds / factors ( end ) ), units { end } );
    return
end

% Initializes the time vectors.
times   = [ 0 0 0 0 0 ];
rounded = [ 0 0 0 0 0 ];

% Gets the number of units for each unit.
remaining = seconds;
for unit = 1: numel ( times );
    
    % Calculates the real and rounded time for unit.
    times   ( unit ) = floor ( remaining / factors ( unit ) );
    rounded ( unit ) = round ( remaining / factors ( unit ) );
    
    % Gets the remain.
    remaining = rem ( remaining, factors ( unit ) );
end

% Gets the required output units from 'maxunits'.
output = find ( times, maxunits, 'first' );

% Creates the output string from the required units.
string = '';
for unit = output ( 1: end - 1 )
    string = sprintf ( '%s %.0f%s', string, times ( unit ), units { unit } );
end
string = sprintf ( '%s %.0f%s', string, rounded ( output ( end ) ), units { output ( end ) } );

% Deletes the extra spaces. 
string = strtrim ( string );