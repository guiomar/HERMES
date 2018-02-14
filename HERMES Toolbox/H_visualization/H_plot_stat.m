function H_plot_stat(Msync,handles)

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


% Gets the variables refering to the system.
layout    = handles.data.layout ( :, [ 1 2 ] );
labels    = handles.data.labels;

% Normalizes the layout.
layout = layout - repmat ( mean ( layout, 1 ), numel ( labels ), 1 );
layout = layout ./ repmat ( max ( abs ( layout ), [], 1 ), numel ( labels ), 1 );

% Draws the sensors and prepares the axes.
scatter ( handles.axes, layout ( :, 1 ), layout ( :, 2 ), 150, [ 0 0 0 ], 'filled');
axis ( [ -1.05 1.05 -1.05 1.05 ] )
hold on
axis off

% Sets the color of the lines from the direction of the difference.
if max ( Msync (:) ) == 1
    colorin = [ 1 0 0 ];
else
    colorin = [ 0 0 1 ];
end

% Activates the axes to write in.
axes ( handles.axes )

% Print channels' numbers, if required.
if get ( handles.show_labels, 'Value' )
    for channel = 1: size ( layout, 1 )
        text ( layout ( channel, 1 ), layout ( channel, 2 ) + .03, labels { channel }, ...
            'FontSize', 6, 'Color', [ .3 .3 .3 ], 'FontUnits', 'normalized', ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle' )
    end
end

% Activates the axes to write in.
axes ( handles.axes )

for ch1 = 1: handles.data.project.channels
    for ch2 = ch1 + 1: handles.data.project.channels
            
        if abs ( Msync ( ch1, ch2 ) ) == 1
            
            line ( layout ( [ ch1 ch2 ], 1 )', layout ( [ ch1 ch2 ], 2 )', ...
                'Color', colorin * abs ( Msync ( ch1, ch2 ) ), 'LineWidth', 2 );
        end

    end
end

hold off
