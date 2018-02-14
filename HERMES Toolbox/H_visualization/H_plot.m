function H_plot(Msync,handles)

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

% Gets the variables from the figure.
index     = handles.data.indexes { get ( handles.index, 'Value' ) };
% mindist   = str2double ( get ( handles.distance,  'String' ) );
threshold = str2double ( get ( handles.threshold, 'String' ) );

% Gets the variables refering to the system.
positions = handles.data.position;
layout    = handles.data.layout ( :, [ 1 2 ] );
labels    = handles.data.labels;

% Normalizes the layout.
layout = layout - repmat ( mean ( layout, 1 ), numel ( labels ), 1 );
layout = layout ./ repmat ( max ( abs ( layout ), [], 1 ), numel ( labels ), 1 );

% Gets the distance between sensors.
dist   = squareform ( pdist ( positions ) );

% Draws the sensors and prepares the axes.
scatter ( handles.axes, layout ( :, 1 ), layout ( :, 2 ), 150, [ 0 0 0 ], 'filled');
axis ( [ -1.05 1.05 -1.05 1.05 ] )
hold on
axis off

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

switch index
    case { 'GC','TE','PTE','PSI','DPI','L','DTF','PDC' }, handles.asymetric = 1;
    otherwise,                                      handles.asymetric = 0;
end

MM = max ( abs ( Msync (:) ) );

% Activates the axes to write in.
axes ( handles.axes )

for ch1 = 1: handles.data.project.channels
    for ch2 = ch1 + 1: handles.data.project.channels
        
        switch handles.asymetric
            
            case 0 % Symetric indexes
                if abs ( Msync ( ch1, ch2 ) ) > threshold
                    if isnan ( dist ( ch1, ch2 ) ) || dist ( ch1, ch2 ) >= str2double ( get ( handles.distance, 'String' ) )
                        
                        line ( layout ( [ ch1 ch2 ], 1 )', layout ( [ ch1 ch2 ], 2 )', ...
                            'Color', [ .5 1 .5 ] * abs ( Msync ( ch1, ch2 ) / MM ), 'LineWidth', 2 );
                    end
                end
                
            case 1 % Asymetric indexes
                
                % Strength F
                F = max ( Msync ( ch1, ch2 ), Msync ( ch2, ch1 ) ) / MM;
                
                % Directionality D
                switch index
                    case 'DPI'
                        D = Msync ( ch1, ch2 ) / MM;
                    case 'PSI'
                        D = -Msync ( ch1, ch2 ) / MM;
                    otherwise % if D>0 => Msync(ch1,ch2)>Msync(ch2,ch1) => ch1->ch2
                        D = ( Msync ( ch1, ch2 ) - Msync ( ch2, ch1 ) ) / ( Msync ( ch1, ch2 ) + Msync ( ch2, ch1 ) );
                end
                D ( isnan ( D ) ) = 0;
                
                % Plot the lines and arrows
                if abs ( F ) > threshold
                    
                    if isnan ( dist( ch1, ch2 ) ) || dist( ch1, ch2 ) >= str2double ( get( handles.distance, 'String' ) )
                        
                        line ( layout( [ ch1 ch2 ], 1 ), layout( [ ch1 ch2 ], 2 ), ...
                            'Color', [ .5 1 .5 ] * abs ( F ), 'LineWidth', 2 );
                        
                        if D > 0 % ch1 --> ch2
                            arrowh ( layout( [ ch1 ch2 ], 1 ), layout( [ ch1 ch2 ], 2 ), ...
                                [ .5 1 .5 ] * abs ( F ), 500 * D );

                        else % ch2 --> ch1
                            arrowh ( layout( [ ch2 ch1 ], 1 ), layout( [ ch2 ch1 ], 2 ), ...
                                [ .5 1 .5 ] * abs ( F ), -500 * D );
                        end
                    end
                end
        end
    end
end

hold off
