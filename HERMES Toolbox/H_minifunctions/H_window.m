function windowed = H_window ( data, config, varargin )
%H_WINDOW overlaping sliding windowing of data.
%   
%   WINDOWED = H_WINDOW(X,CONFIG)
%
%   H_WINDOW performs the overlapping windowing of the data in X. X must be
%   given as data per channel per trial for correct performing.
%
%   Input value config must consist of a structure with, at least, fields:
%   - window: Window length in milliseconds.
%   - overlap: Sliding window overlap.
%   - fs: Sample rate of the data.
%
%   Output data WINDOWED is given as windowed data per channel per step per
%   trial. The number of steps is selected according to the length of the
%   data, the length of the window and the overlap selected.
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


% Checks the existence of all paramters.

if ~isfield ( config, 'length' ),    return,                     end
if ~isfield ( config, 'overlap' ),   return,                     end
if ~isfield ( config, 'alignment' ), config.alignment = 'epoch'; end
if ~isfield ( config, 'fs' ),        return,                     end
if ~isfield ( config, 'baseline' ),  config.baseline   = 0;       end

% If the alignment is with the stimulus, cuts the initial edge.
if strcmp ( config.alignment, 'stimulus' )
    shift = rem ( config.baseline, round ( ( 1 - config.overlap / 100 ) * config.length / 1000 * config.fs ) );
    data ( 1: shift, :, :, : ) = [];
end

% Calculates the length of the window and the overlap.
length  = round ( config.length / 1000 * config.fs );
overlap = round ( config.length / 1000 * config.fs * config.overlap / 100 );

% Calculates matriz size from original data, length of the window and
% number of windows.
windows = floor ( ( size ( data, 1 ) - overlap ) / ( length - overlap ) );
sizes   = [ length size( data, 2 ) windows size( data, 3 ) ];

% Returns the size of the data if itis required.
if any ( strcmp ( varargin, 'size' ) )
    windowed = sizes;
    return
end

% Memory reservation for the output data.
windowed = zeros ( sizes );

% Fulfilment of the data.
for step = 1: windows
    windowed ( :, :, step, : ) = data ( ( step - 1 ) * ( length - overlap ) + ( 1: length ), :, : );
end

% Sets zero mean and unity standard deviation.
windowed = zscore ( windowed );