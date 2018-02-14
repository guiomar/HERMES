function config = H_waitbar ( config )
% H_WAITBAR Creation and updating of progress bar.
%   
%   CONFIG = H_WAITBAR(CONFIG)
%
%   H_WAITBAR draws he progress bar and stimates remaining time acording to
%   the parameters in the configuration structure CONFIG.
%
%   CONFIG is a structure with fields:
%   - HANDLE: Handle to the progress bar, if exists.
%   - TIC: Time of the beggining of the calculations related to the bar.
%     The time is expressed in the format given by function CLOCK.
%   - PROGRESS: A vector indicating the proportion of the process
%     performed. It's a vector of even size. In this vector, each odd
%     element represents the complete subtasks, and the even after it the
%     total number of subtasks.
%
%   The value given by the function is the same configuration structure
%   with the new HANDLE field, if it is modified.
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



% If there is no waitbar creates one.
set ( 0, 'ShowHiddenHandles', 'on' )
if ~numel ( config.handle ) || ~any ( findobj ( 'type', 'figure' ) == config.handle )
    config.handle = waitbar ( 0, 'HERMES', 'CreateCancelBtn', 'H_cancel(gcbf)', 'visible', 'off' );
    set ( config.handle, 'Position', get ( config.handle, 'Position' ) + [ 0 0 0 20 ] )
%     set ( config.handle, 'CloseRequestFcn', 'delete(gcbf)', 'WindowStyle', 'modal', 'visible', 'on', 'Tag', 'H_waitbar', 'Color', H_background )
    set ( config.handle, 'CloseRequestFcn', 'delete(gcbf)', 'visible', 'on', 'Tag', 'H_waitbar', 'Color', H_background )
    
    % Sets the progress bar color to blue.
    set ( findobj ( config.handle, 'Type', 'patch' ), 'FaceColor', [ 0 0 1 ], 'EdgeColor', [ 0 0 1 ] )
    
    config.state.progress = 0;
end

% Calculates the progress by increasing pairs un config.progress.
% Just the last task will be completed.
if ~isfield ( config, 'progress' ), config.progress = [ 0 1 ]; end
progress = ( config.progress ( end - 1 ) ) / config.progress ( end );
for subtask = numel ( config.progress ) - 2: -2: 1
    progress = ( progress + ( config.progress ( subtask - 1 ) - 1 ) ) / config.progress ( subtask );
end

% Waitbar is updated if the change is greater than 2% or the message has
% changed.
if 100 * progress - config.state.progress >= 2 || progress == 0 || ~strcmp ( config.message, config.state.message )
    
    config.state.progress = round ( 100 * progress );
    config.state.message  = config.message;
    config.state.title    = config.title;
    
    % Stimates the remaining time from elapsed time and progress.
    elapsed   = etime ( clock, config.tic );
    total     = elapsed / progress;
    remaining = total - elapsed;
    
    % Gets the corresponding string.
    elapsed   = strelapsed ( elapsed,   2, 'short' );
    total     = strelapsed ( total,     2, 'short' );
    remaining = strelapsed ( remaining, 2, 'short' );
    
    % Creates the output.
    if ( progress > 0 ), message = sprintf ( '%s of %s (%0.0f%%, %s to finish)', elapsed, total, round ( 100 * progress ), remaining );
    else                 message = 'Estimating remaining time...'; end
    if isfield ( config, 'message' ), message = { config.message; message }; end
    if isfield ( config, 'title' ),   set ( config.handle, 'name', config.title ); end
    
    waitbar ( progress, config.handle, message );
end

if isobject ( config.handle ), set ( config.handle, 'UserData', config ); end