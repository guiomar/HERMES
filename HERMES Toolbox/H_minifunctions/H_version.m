function version = H_version ( project, output )
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
% Authors:  Ricardo Bruna, 2013
%


current = 'HERMES v0.9.1';

if nargin == 0, version = current; return, end
if nargin == 1, output = 'vector'; end

% Extracts the numerical version.
if isempty ( project ), verstr = current;
else                    verstr = project.version;
end
vernum = verstr ( 9: end );

% Sets each number as a element in a vector.
version = regexp ( vernum, '([0-9]+)', 'match' );
version = str2double ( version );
version = version (:);

% Sets the vector in decimal mode, if required.
if strcmp ( output, 'decimal' )
    for subversion = 2: numel ( version )
        version (1) = version (1) + version ( subversion ) / 10 ^ ( ( subversion - 1 ) * 2 );
    end
    version = version (1);
end