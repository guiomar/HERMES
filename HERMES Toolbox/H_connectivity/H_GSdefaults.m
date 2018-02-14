function [ act, dimension ] = H_GSdefaults ( project, flag )
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
% ** Please cite: ---------------------------------------------------------
% Niso G, Bruña R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
% 
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%


% Sets the flag to select if the fnn must be estimated.
flag = nargin > 1 && flag;

% Sets the number of vectors to check.
samplesize = 100;

% Sets the delayed cancelation check variables.
H_stop (0);
tinv = 0.1;
tic;

% Creates and configures the waitbar.
waitbar.start    = clock;
waitbar.progress = [ 0 1 ];
waitbar.handle   = [];
waitbar.title    = 'Set default parameters';
waitbar.message  = sprintf ( 'Selecting %.0f random vectors to check...', samplesize );
waitbar.tic      = clock;

waitbar.state.progress = 0;
waitbar.state.message  = '';
waitbar.state.title    = '';

waitbar = H_waitbar ( waitbar );

% Creates an index refering each trial in the data.
trials = cell2mat ( { project.statistical.trials } );
index  = zeros ( sum ( cell2mat ( { project.statistical.trials }' ) ), 3 );

for subject = 1: numel ( project.subjects )
    for condition = 1: numel ( project.conditions )
        offset = sum ( sum ( trials ( :, 1: subject - 1 ) ) ) + sum ( trials ( 1: condition - 1, subject ) );
        
        index ( offset + 1: offset + trials ( condition, subject ), 1 ) = subject;
        index ( offset + 1: offset + trials ( condition, subject ), 2 ) = condition;
        index ( offset + 1: offset + trials ( condition, subject ), 3 ) = 1: trials ( condition, subject );
    end
end

% Randomly selects the trials and a channel for each selected trial.
check = index ( randi ( size ( index, 1 ), samplesize, 1 ), : );
check ( :, 4 ) = randi ( project.channels, samplesize, 1 );
check = sortrows ( check );

% Reserves memory for the vectors.
data = zeros ( project.samples, samplesize );

% Gets the files to load.
files = unique ( check ( :, 1: 2 ), 'rows' );

% Updates the waitbar.
waitbar.progress (1) = 0;
waitbar.progress (2) = size ( files, 1 );
waitbar = H_waitbar ( waitbar );

% Loads each file and get the required vectors.
for file = 1: size ( files, 1 )
    
    % Load the whole data in two dimensions.
    datafile = H_load ( project, files ( file, 1 ), files ( file, 2 ) );
    datasize = [ size( datafile, 2 ) size( datafile, 3 ) ];
    datafile = datafile ( :, : );
    
    % Gets the list of vectors.
    active   = check ( :, 1 ) == files ( file, 1 ) & check ( :, 2 ) == files ( file, 2 );
    vectors  = check ( active, [ 4 3 ] );
    vectors  = sub2ind ( datasize, vectors ( :, 1 ), vectors ( :, 2 ) );
    
    % Selects selects the data and stores it.
    data ( :, active ) = datafile ( :, vectors );
    
    % Temporal spaced check.
    if toc > tinv, tic
        
        % Checks for user cancelation.
        if ( H_stop ), return, end
        
        % Updates the waitbar.
        waitbar.progress (1) = file;
        waitbar = H_waitbar ( waitbar );
    end
end

% Updates the waitbar.
waitbar.message  = 'Calculating autocorrelation of the vectors...';
waitbar.tic      = clock;
waitbar.progress = [ 0 1 ];
waitbar = H_waitbar ( waitbar );

% Calculates the autocorrelation from the FFT.
nfft = pow2 ( nextpow2 ( 2 * project.samples - 1 ) );
FT = fft ( data, nfft, 1 );
acorr = ifft ( FT .* conj ( FT ) ) / ( project.samples - 1 );
acorr = acorr ( 1: nfft / 2 + 1, : );

% Calculates the envelope of the autocorrelation function.
envelope = sqrt ( 2 ) * filtfilt ( fir1 ( min ( 100, floor ( size ( acorr, 1 ) / 3 ) - 1 ), .01 ), 1, abs ( acorr ) );

% Updates the waitbar.
waitbar.message  = 'Calculating default parameters';
waitbar.tic      = clock;

waitbar.progress (1) = 0;
waitbar.progress (2) = samplesize;
waitbar = H_waitbar ( waitbar );

% Gets the delay for each vector.
delays    = zeros ( samplesize, 1 );
dimension = zeros ( samplesize, 1 );

for vector = 1: samplesize
    
    % Calculates the autocorrelation time.
    delay = find ( envelope ( :, vector ) < exp (-1), 1, 'first' );
    if isempty ( delay ), delay = project.samples; end
    delays ( vector ) = delay;
    
    % If requested, calculates the embedding dimension.
    if flag, dimension ( vector ) = fnn ( data ( :, vector ), delay );
    else     dimension ( vector ) = 4;
    end
    
    % Temporal spaced check.
    if toc > tinv, tic
        
        % Checks for user cancelation.
        if ( H_stop ), return, end
    
        % Updates the waitbar.
        waitbar.progress (1) = vector;
        waitbar = H_waitbar ( waitbar );
    end
end

% Sets the TAU to the mean of the calculated delays.
act       = round ( mean ( delays ) );
dimension = round ( nanmean ( dimension ) ) ;

if isnan ( dimension ), dimension = 10; end

delete ( waitbar.handle );
