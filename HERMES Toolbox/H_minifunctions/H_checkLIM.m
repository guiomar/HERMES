function H_checkLIM (hObject, minvalue, maxvalue, optvalue, str1, str2, int)
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

options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX' );

% Gets the number.
number = str2double ( get ( hObject, 'String' ) );

    if H_checkOR ( number, 'nan', '~real', 'inf', '~int' ) && int
        
        % Prints the warning text.
        text = sprintf ( '%s must be a natural number between %i and %i.', minvalue, maxvalue, str2 );
        warndlg ( text, str1, options )
        
        % Modifies the field value.
        set ( hObject, 'String', optvalue );
        
    elseif H_checkOR ( number, 'nan', '~real', 'inf' )
        
        % Prints the warning text.
        text = sprintf ( '%s must be a real number between %0f and %0f.', minvalue, maxvalue, str2 );
        warndlg ( text, str1, options )
        
        % Modifies the field value.
        set ( hObject, 'String', optvalue );
        
    elseif H_checkOR ( number, sprintf ( 'lt%i', minvalue ), sprintf ( 'gt%i', maxvalue ) ) && int
        
        % Prints the warning text.
        text = sprintf ( 'We strongly recomend you to use a number between %i and %i, if you have not a well founded reason to do otherwise.', minvalue, maxvalue );
        warndlg ( text, str1, options )
        
    elseif H_checkOR ( number, sprintf ( 'lt%i', minvalue ), sprintf ( 'gt%i', maxvalue ) )
        
        % Prints the warning text.
        text = sprintf ( 'We strongly recomend you to use a number between %0f and %0f, if you have not a well founded reason to do otherwise.', minvalue, maxvalue );
        warndlg ( text, str1, options )
    end
end   
