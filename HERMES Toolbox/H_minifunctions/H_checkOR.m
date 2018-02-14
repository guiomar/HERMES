function output = H_checkOR ( value, varargin )
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


output = 1;

for arg = 1: numel ( varargin )
    condition = varargin { arg };
    
    if strcmp  ( condition,  'nan'   ) &&  isnan  ( value ), return, end
    if strcmp  ( condition, '~nan'   ) && ~isnan  ( value ), return, end
    if strcmp  ( condition,  'inf'   ) &&  isinf  ( value ), return, end
    if strcmp  ( condition, '~inf'   ) && ~isinf  ( value ), return, end
    if strcmp  ( condition,  'real'  ) &&  isreal ( value ), return, end
    if strcmp  ( condition, '~real'  ) && ~isreal ( value ), return, end
    if strcmp  ( condition,  'int'   ) &&  round(value)==value, return, end
    if strcmp  ( condition, '~int'   ) &&  round(value)~=value, return, end
    
    if strcmp  ( condition,  'pow2'  ) && pow2 ( nextpow2 ( value ) ) == value, return, end
    if strcmp  ( condition, '~pow2'  ) && pow2 ( nextpow2 ( value ) ) ~= value, return, end
    
    if strncmp ( condition, 'et',  2 ) && value == str2double ( condition ( 3: end  ) ), return, end
    if strncmp ( condition, '~et', 3 ) && value ~= str2double ( condition ( 4: end  ) ), return, end
    if strncmp ( condition, 'lt',  2 ) && value <  str2double ( condition ( 3: end  ) ), return, end
    if strncmp ( condition, 'let', 3 ) && value <= str2double ( condition ( 4: end  ) ), return, end
    if strncmp ( condition, 'gt',  2 ) && value >  str2double ( condition ( 3: end  ) ), return, end
    if strncmp ( condition, 'get', 3 ) && value >= str2double ( condition ( 4: end  ) ), return, end
end

output = 0;