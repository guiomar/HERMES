function output = H_show ( variable, shift, vardescription )
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

% Checks the number and type of the parameters.
if nargin < 1, error ( 'H_show requires at least one input' ), end
if nargin > 1 && ~isnumeric ( shift ) && numel ( shift ) ~= 1, error ( 'H_show''s second parameter must be a number.' ), end

% If no description, gets the name variable in the original workspace.
if nargin < 3, vardescription = inputname ( 1 ); end

% Sets the level to 0 if none.
if nargin == 1, shift = 0; end

% Initializes the output.
output = '';

% Prints the name or description of the variable, if any.
if ~isempty ( vardescription )
    output = cat2 ( output, sprintf ( '%s%s:', spacer ( shift ), vardescription ) );
end

if isstruct ( variable ) || isa ( variable, 'MException' )
    
    % Prints the variable description.
    output = cat2 ( output, sprintf ( ' %s structure array with fields:\n', dimensioner ( variable ) ) );
    
    % Gets the field names.
    minivarnames = fieldnames ( variable );
    maxlength    = max ( cellfun ( @numel, minivarnames ) );
    
    % In a multidimensional structure, prints each entry.
    if numel ( variable ) > 1
        for entry = 1: numel ( variable )
            output = cat2 ( output, H_show ( variable ( entry ), shift + maxlength + 2, sprintf ( 'Entry %.0f', entry ) ) );
        end
        return
    end
    
    % Recursivelly calls the function for each field.
    for minivar = 1: numel ( minivarnames )
        
        % Gets the field name.
        minivarname = minivarnames { minivar };
        
        % Writes a blank line if the field is a structure.
        if isstruct ( variable.( minivarname ) )
            output = cat2 ( output, sprintf ( '\n' ) );
        end
        
        % Writes the variable number.
        output = cat2 ( output, sprintf ( '%s%s:', spacer ( shift + 5 + maxlength - numel ( minivarname ) ), minivarname ) );
        
        if numel ( variable.( minivarname ) ) < 1,
            output = cat2 ( output, sprintf ( ' Empty field.\n' ) );
            continue
        end
        
        % Calls the function.
        output = cat2 ( output, H_show ( variable.( minivarname ), shift + maxlength + 2 ) );
        
    end
    
% Char array.
elseif ischar ( variable )
    output = cat2 ( output, ' ''' );
    output = cat2 ( output, strrep ( variable, sprintf ( '\n' ), [ sprintf( '\n' ) spacer( shift + 6 ) ] ) );
    output = cat2 ( output, '''' );
    
% Array.
elseif isnumeric ( variable )
    
    % Checks if the variable is a matrix of integers.
    isint = variable == int64 ( variable );
    
    % Empty array.
    if isempty ( variable )
        output = cat2 ( output, sprintf ( ' Empty array.' ) );
        
    % Bidimensional array.
    elseif ndims ( variable ) == 2 %#ok<ISMAT> Compatibility with older versions.
        
        % Prints the brackets.
        if numel ( variable ) > 1
            output = cat2 ( output, sprintf ( ' [' ) );
        end
        
        % Goes through any row in variable.
        for row = 1: size ( variable, 1 )
            
            % Prints the valule if integer.
            if isint
                output = cat2 ( output, sprintf ( ' %.0f', variable ( row, : ) ) );
                
            % Prints otherwise.
            else
                output = cat2 ( output, sprintf ( ' %f', variable ( row, : ) ) );
            end
            
            % Prints the semicolon at the end of the row.
            if row < size ( variable, 1 )
                output = cat2 ( output, sprintf ( ';' ) );
            end
        end
        
        % Prints the brackets.
        if numel ( variable ) > 1
            output = cat2 ( output, sprintf ( ' ]' ) );
        end
        
    % n-dimensional array
    else
        output = cat2 ( output, sprintf ( ' Multidimensional array.' ) );
    end
    
% Cell string array.
elseif iscellstr ( variable )
    
    % Empty cell array.
    if isempty ( variable )
        output = cat2 ( output, sprintf ( ' Empty cell array.' ) );
        
    % Bidimensional cell array.
    elseif ndims ( variable ) == 2 %#ok<ISMAT> Compatibility with older versions.
        
        % Prints the curly brackets.
        if numel ( variable ) > 1
            output = cat2 ( output, sprintf ( ' {' ) );
        end
        
        % Goes through any row in variable.
        for row = 1: size ( variable, 1 )
            
            % Goes through any column in variable.
            for column = 1: size ( variable, 2 )
                
                % Prints the value.
                output = cat2 ( output, sprintf ( ' ''%s''', variable { row, column } ) );
            end
            
            % Prints the semicolon at the end of the row.
            if row < size ( variable, 1 )
                output = cat2 ( output, sprintf ( ';' ) );
            end
        end
        
        % Prints the curly brackets.
        if numel ( variable ) > 1
            output = cat2 ( output, sprintf ( ' }' ) );
        end
        
    % n-dimensional cell array
    else
        output = cat2 ( output, sprintf ( ' Multidimensional cell array.' ) );
    end
    
% Unkwnown variable type.
else
    output = cat2 ( output, sprintf ( ' Unknown variable type (class %s).\n', class ( variable ) ) );
end

% Writes a blank line after the variable.
output = cat2 ( output, sprintf ( '\n' ) );

% Sets the maximum number of consecutive blank rows to one.
output = strrep ( output, sprintf ( '\n\n\n' ), sprintf ( '\n\n' ) );


% Function to print n spaces.
function spaces = spacer ( number )

spaces = sprintf ( '%s', repmat ( ' ', 1, number ) );

% Function to print the dimension of a matrix.
function dimensions = dimensioner ( variable )

dimensions = size ( variable );
dimensions = sprintf ( '%.0fx', dimensions );
dimensions = dimensions ( 1: end - 1 );

% Function to concatenate along the second dimension.
function output = cat2 ( input1, input2 )

output = cat ( 2, input1, input2 );