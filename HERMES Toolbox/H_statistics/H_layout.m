function project = H_layout ( project )

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

% Gets sensors information.
sensors = project.sensors;

% Load the systems and extracts the ID and name.
% systems = importdata ( H_path ( 'coordinates', 'systems_.mat' ) );
systems  = importdata ( H_path ( 'coordinates', 'systems.mat' ) );
sysnames = { systems.name }';

% Initializes the coincidences array.
coincidences = [];
syspossible  = [];

% If the files were labelled gets the compatible systems.
if sensors.labelled
    
    % Compares the labels of the data with those in the stored systems.
    coincidences = false ( numel ( systems ), 1 );
    for system = 1: numel ( systems )
        coincidences ( system ) = all ( ismember ( systems ( system ).labels, sensors.label ) ) || all ( ismember ( sensors.label, systems ( system ).labels ) );
    end
    
    coincidences = find ( coincidences );
    
% Otherwise preselects the systems with the same number of channels.    
else
    syspossible = [ systems.channels ] == project.channels;
    syspossible = find ( syspossible );
end

while true
    
    % Promts the systems compatible with the current labels.
    if numel ( coincidences )
        system = listdlg ( 'Name', 'HERMES - Coordinates system selection', ...
            'PromptString', 'The following systems are compatible with your data:', ...
            'ListString', [ sysnames( coincidences ); 'Subset based on other system' ], ...
            'SelectionMode', 'single', 'ListSize', [ 400 200 ]);
        
        if system > numel ( coincidences ), system = 0; break, end
        
    % Promts the systems with the same number of channels.
    elseif numel ( syspossible )
        system = listdlg ( 'Name', 'HERMES - Coordinates system selection', ...
            'PromptString', 'Select the coordinates system of the data:', ...
            'ListString', [ sysnames( syspossible ); 'Subset based on other system' ], ...
            'SelectionMode', 'single', 'ListSize', [ 400 200 ]);
        
        if system > numel ( syspossible ), system = 0; break, end
        
    % Otherwise leaves the loop.
    else system = 0; break
    end
    
    % If the user cancells, asks for confirmation and exits.
    if isempty ( system )
        options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );
        
        % Asks if the user really wants to continue without a layout.
        text = [
            'Do you really want to continue without a layout?\n\n' ...
            'Remember that you won''t be able to select a layout later, nor accuratly represent the connectivity.\n' ...
            'In addition, some statistics could throw wrong results due to not being able to detect near sensors.' ];
        text = sprintf ( text );
        
        if ~strcmp ( questdlg ( text, 'HERMES Â· Layout selecting question', 'Yes', 'No', options ), 'Yes' ), continue
        else
            
            % Sets the information and returns.
            labels  = sensors.label;
            sensors = [];
            
            sensors.label    = labels;
            sensors.layout   = nan ( project.channels, 4 );
            sensors.order    = 1: project.channels;
            sensors.position = nan ( project.channels, 3 );
            sensors.system   = 'Undefined';
            
            project.sensors = sensors;
            
            return
        end
        
    % If the user selected a system, uses that one.
    else
        
        % If coincidences, constructs the subset.
        if numel ( coincidences )
            options = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );
            
            % Gets the real system ID.
            system  = coincidences ( system );
            sysname = sprintf ( 'Subset based on %s', systems ( system ).name );
            
            if systems ( system ).channels ~= project.channels
                
                if systems ( system ).channels < project.channels
                    text = [
                        'The selected system has less channels (%i) that the data (%i).\n' ...
                        'The non-present channels will be discarded.\n\n' ...
                        'Do you want to continue?' ];
                    
                else
                    text = [
                        'The selected system has more channels (%i) that the data (%i).\n' ...
                        'The excess channels will be ignored.\n\n' ...
                        'Do you want to continue?' ];
                end
                text = sprintf ( text, systems ( system ).channels, project.channels );
                
                if ~strcmp ( questdlg ( text, 'HERMES Â· Layout selecting question', 'Yes', 'No', options ), 'Yes' ), continue
                end
            end
            
            % Initializes the order variable.
            order   = zeros ( systems ( system ).channels, 1 );
            
            % Goes through all the channels in the data.
            for channel = 1: project.channels
                
                % Gets the position of the channel in the system.
                position = strcmp ( project.sensors.label { channel }, systems ( system ).labels );
                order ( position ) = channel;
            end
            
        % If possible systems, the assignation is automatic.
        elseif numel ( syspossible )
            
            % Gets the real system ID.
            system  = syspossible ( system );
            sysname = systems ( system ).name;
            
            % Assigns the order automatically.
            order   = ( 1: systems ( system ).channels )';
        end
        
        % Leaves the loop.
        break
    end
end

while system == 0
    
    % Promts all the systems.
    system = listdlg ( 'Name', 'HERMES - Coordinates system selection', ...
        'PromptString', 'Select the original coordinates system:', ...
        'ListString', sysnames, ...
        'SelectionMode', 'single', 'ListSize', [ 400 200 ]);
    
    % If the user cancells, asks for confirmation and exits.
    if isempty ( system )
        options  = struct ( 'WindowStyle', 'modal', 'Interpreter', 'TeX', 'Default', 'No' );
        
        % Asks if the user really wants to continue without a layout.
        text = [
            'Do you really want to continue without a layout?\n\n' ...
            'Remember that you won''t be able to select a layout later, nor accuratly represent the connectivity.\n' ...
            'In addition, some statistics could throw wrong results due to not being able to detect near sensors.' ];
        text = sprintf ( text );
        
        if ~strcmp ( questdlg ( text, 'HERMES Â· Layout selecting question', 'Yes', 'No', options ), 'Yes' ), continue
        else
            
            % Sets the information and returns.
            labels  = sensors.label;
            sensors = [];
            
            sensors.label    = labels;
            sensors.layout   = nan ( project.channels, 4 );
            sensors.order    = 1: project.channels;
            sensors.position = nan ( project.channels, 3 );
            sensors.system   = 'Undefined';
            
            project.sensors = sensors;
            
            return
        end
    end
    
    % Gets the order of the channels in the modified layout.
    sysname = sprintf ( 'Subset based on %s', systems ( system ).name );
    order   = HERMES_FitLayout ( systems ( system ).labels, project.sensors.label );
end

% Sets the information.
sensors.label    = systems ( system ).labels   ( order ~= 0 );
sensors.layout   = systems ( system ).layout   ( order ~= 0, : );
sensors.order    = order ( order ~= 0 );
sensors.position = systems ( system ).position ( order ~= 0, : );
sensors.system   = sysname;

project.sensors  = sensors;
project.channels = numel ( sensors.label );
