function labels = autolabel ( string, number )
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

% Checks that 'string' has a valid value.
if ~isstr ( string ) || isempty ( string )
    error ( '''string'' must be a non-empty string.' );
end

% Checks that 'subjects' has a valid value.
if H_checkOR ( number, 'inf', 'nan', '~int', 'lt1' )
    error ( '''subjects'' must take a, integer value greater than zero.' );
end

% Escapes the possible % characters.
string = strrep ( string, '%', '%%' );

% Creates the template from the string and the size of the sample.
template = '%s%%0%0.0f.0f, ';
template = sprintf ( template, string, ceil ( log10 ( number + 1 ) ) );

% Creates a list of comma-separated values for the labels.
labels   = sprintf ( template, 1: number );

% Removes the last two characters (comma and blank space).
labels   = labels ( 1: end - 2 );