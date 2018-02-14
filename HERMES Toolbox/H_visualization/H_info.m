function output = H_info ( input )

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


% Gets the type from the input structure.
if isfield ( input, 'origin' )
    stats = input;
    index = input.origin;
else
    stats = [];
    index = input;
end

% Initializes the output.
output = char;

if ~isempty ( stats )
    
    % Prints out the description of the statitic test.
    output = sprintf ( '%sStatistic test''s information:\n', output );
    output = sprintf ( '%sMethod: %s\n', output, stats.method {1} );
    output = sprintf ( '%sCalculated on: %s\n', output, datestr ( stats.date, 'dd/mm/yyyy' ) );
    output = sprintf ( '%sFixed parameter: %s\n', output, stats.config.fix );
    
    switch stats.config.fix
        case 'Group'
            output = sprintf ( '%s  Group: %s\n', output, stats.info.groups { stats.config.fixed } );
            output = sprintf ( '%s  Condition 1: %s\n', output, stats.info.conditions { stats.config.set1 } );
            output = sprintf ( '%s  Condition 2: %s\n', output, stats.info.conditions { stats.config.set2 } );
            
        case 'Condition'
            output = sprintf ( '%s  Condition: %s\n', output, stats.info.conditions { stats.config.fixed } );
            output = sprintf ( '%s  Group 1: %s\n', output, stats.info.groups { stats.config.set1 } );
            output = sprintf ( '%s  Group 2: %s\n', output, stats.info.groups { stats.config.set2 } );
    end
    
    % Prints a blank line.
    output = sprintf ( '%s\n', output );
    
    % Prints out the statitic test's configuration.
    config = stats.config.parameters;
    output = sprintf ( '%s%s', output, H_show ( config, -4, 'Statistic test''s configuration' ) );
end

if ~isempty ( index )
    
    % Prints out the description of the index.
    output = sprintf ( '%sIndex'' information:\n', output );
    output = sprintf ( '%sName: %s\n', output, index.name );
    output = sprintf ( '%sType: %s\n', output, index.type );
    output = sprintf ( '%sCalculated on: %s\n', output, datestr ( index.date, 'dd/mm/yyyy' ) );
    
    % Prints a blank line.
    output = sprintf ( '%s\n', output );
    
    % Prints out the index configuration.
    config = rmfield ( index.config, { 'measures' 'window' 'statistics' 'surrogates' } );
    output = sprintf ( '%s%s', output, H_show ( config, -4, 'Index'' configuration' ) );
    
    % Prints out the widowing configuration.
    window = index.config.window;
    output = sprintf ( '%sWindow''s configuration:\n', output );
    output = sprintf ( '%sLength: %gms\n', output, window.length );
    output = sprintf ( '%sOverlap: %g%%\n', output, window.overlap );
    output = sprintf ( '%sAlignment: To the %s\n', output, window.alignment );
    
    % Prints a blank line.
    output = sprintf ( '%s\n', output );
    
    % Prints out the surrogates configuration.
    if index.config.statistics, output = sprintf ( '%sSurrogates: %g\n', output, index.config.surrogates );
    else                        output = sprintf ( '%sSurrogates: No\n', output );
    end
end