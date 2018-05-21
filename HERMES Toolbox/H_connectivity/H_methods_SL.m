function output = H_methods_SL ( data, config, waitbar )
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
% Niso G, Bruna R, Pereda E, Gutiérrez R, Bajo R., Maestú F, & del-Pozo F. 
% HERMES: towards an integrated toolbox to characterize functional and 
% effective brain connectivity. Neuroinformatics 2013, 11(4), 405-434. 
% DOI: 10.1007/s12021-013-9186-1. 
%
% =========================================================================
%
% Authors:  Guiomar Niso, 2011
%           Guiomar Niso, Ricardo Bruna, 2012
%           Guiomar Niso, 2018
%


% Checks the existence of the waitbar.
if nargin < 3, waitbar = []; end

% Windows the data.
data = H_window ( data, config.window );
% Gets the size of the analysis data.
[ samples, channels, windows, trials ] = size ( data );

% Reserves the needed memory.
if H_check ( config.measures, 'SL' ), output.SL.rawdata = ones ( channels, channels, windows, trials ); end

% Calculates the indexes for each trial and pair of sensors.

for window = 1: windows
    
for trial = 1: trials
    output.SL.rawdata(:,:,window,trial) = H_sl (data(:,:,window,trial), config);
    
    if isstruct ( waitbar )
        waitbar.progress ( 5: 6 ) = [ trial trials ];
        waitbar = H_waitbar ( waitbar );
    end
end

end

output.SL.data = mean ( output.SL.rawdata, 4 );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  Synchronization Likelihood Stand-Alone Calculator

function RESULT = H_sl( X, config)

% DESCRIPTION
% This function takes in data from the file s_in or variable X_in
% (if not given, then a prompt appears asking for filename)
% and outputs the synchronization likelihood in three files,
% 'synchro.txt', 'syntime.txt', 'marnhold.txt', unless specified.
%

% TO CHANGE PARAMETERS, DO A SEARCH FOR "SETTINGS", CASE SENSITIVE!
% -------------------------------------------------------------------------

% input data source
%       The input data file must contain M columns and N rows of numbers.  These numbers
%       correspond to the N samples for each of the M channels.
% (if s_in/X_in is not given, then there will be a prompt asking for the input file.)
%
% synchro.txt
%         This file will contain the synchronization likelihood of each channel, compared
%         with *all* other channels.  The output will contain M columns and T rows of
%         numbers.
%
% syntime.txt
%         This file contains the *overall* synchronization likelihood of the signals
%         at each time t.  The output will contain 1 column and T rows of numbers.
%
% marnhold.txt
%         This file contains an MxM matrix, which corresponds to an alternative time-averaged
%         calculation of synchronization values.  In position (X,Y), the value represents
%         the *harmonic average* of the synchronization likelihood of X to Y & Y to X.
%

% NOTE (marnhold.txt):
%         The actual calculation is: 2 * ( # X&Y are hit ) / ( #X-hits + # Y-hits ), which
%         is the harmonic average of ( # X-hit )/( # X&Y are hit ) and
%                                    ( # Y-hit )/( # X&Y are hit )
%
%         where #hits is the total number of hits across time.
%

% DEVIATIONS from synchronization(.) procedure (i.e. the "Pascal code")
% 1. The variable w has been changed to w1, to correspond with the articles.
% 2. The variable w2 has been redefined, to correspond with the articles.
%     This change alters the result slightly with the Pascal code; in the Pascal code,
%     w2 approximately represented the fraction of the total number of samples, and in
%     one instance is hardcoded as 0.1.  Also, the total number of samples was
%     calculated in two different manners, yielding two different results.
%     These discrepancies have been eliminated in this implementation.  w2 is the actual
%     integer number that represents the upper bound of the window, as in the articles.
% 3. The chanbias & actchan variables have been eliminated!  The result from using
%     chanbias & actchan can be obtained from the S_matrix variable:
%        S_matrix(:,actchan,:)
%     That is, if chanbias is used, then we are considering how all the other channels
%     relate as *driver systems* to the *response system* actchan-channel.
% 4. The ranges for i & j is now 1 : m2 - l*(m-1), instead of 1 : m2 - l*m.
%     The last element of X_{k,m2-l*(m-1)} will use the last element X_{k,m2} in the calculation.
% 5. The calculation of epsilons is different; it is now closer to pref.
%
% Note: (26.06.03) S_matrix is now an internal variable. Use the sync_gui.m program
%     to manipulate the S_matrix variable.
%

% A SHORT INTRODUCTION TO THE SYNCHRONIZATION LIKELIHOOD MEASURE
%
% We define the SYNCHRONIZATION LIKELIHOOD for a driver system X and a response system Y.
% 
% PROPERTY (*): If X is in the same state at times i & j, then Y is also in the same state at times i & j.
%
% Generalized synchronization exists when property (*) holds.
% If X & Y exhibit property (*), then the synchronization likelihood between X and Y will be high.
%
% State (def'n): Given l (lag) and m (embedding dimension), the state of X at time i is defined
%  as the vector X_i = ( x_{i}, x_{i+l}, x_{i+2l}, ..., x_{i+(m-1)l} )
%
% Similarity between states (def'n): Two states X_i and X_j are similar if the distance between
%  X_i and X_j is small.  We use the euclidean distance measure (the L2 norm of the vector difference).
%
%
% To have a measure of similarity, we construct an epsilon that depends on the system (X) and time (i).
% We will define that similarity exists if |X_i - X_j| < epsilon_{X,i}.
%
% To determine epsilon_{X,i}, we consider the set of X_j for all j satisfying w1<|i-j|<w2.  From this set,
% we then determine the set of distances between X_i and all X_j.  We then choose epsilon_{X,i} as the
% distance so that the fraction of distances |X_i - X_j| less than epsilon_{X,i} is Pref.
%
% We calculate epsilon_{Y,i} in a similar manner, *using the same Pref* (and same time i).
%
% Now, with i fixed, for each of the values j satisfying w1<|i-j|<w2, we consider a hit wrt X occurs
% (at time j) when |X_i - X_j| < epsilon_{X,i}.  A hit wrt Y occurs when |Y_i - Y_j| < epsilon_{Y,i}.
%
% The synchronization likelihood is defined as the probability (over the valid j's) that
%  there is a hit wrt Y, *given* that there is a hit wrt X.
%
% That is, S(x,y,i) = (# of times there is a hit wrt X and a hit wrt Y) / (# of hits wrt X).
%
%
% If there is no synchronization between X & Y, then the synchronization likelihood is close to Pref.
% If there is synchronization between X & Y, then the synchronization likelihood will approach 1.
%
% Once the whole set of S(x,y,i) is constructed, we can construct variations by averaging over one or
%  more of the three axes (driver system, response system, time).
%
% "Averaging over all [axes] gives S, the overall level of synchronization in a multi channel epoch."
% [2] p.67
%

% SOURCES:
% 1. C.J. Stam, B.W. van Dijk.  "Synchronization likelihood: an unbiased measure of generalized
%     synchronization in multivariate data sets."  Physica D 163 (2002), 236-251.
% 2. C.J. Stam, M. Breakspear, A. van Cappellen van Walsum, B. W. van Dijk.  "Nonlinear
%     Synchronization in EEG and Whole-Head MEG Recordings of Healthy Subjects."  Human Brain
%     Mapping, 19:63-78 (2003).
%

% AUTHOR: Jimmy Chui



[num_samples, num_chans] = size(X);

% initialize variables
m1 = 1;           % first sample
m2 = num_samples; % last sample

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize parameters
lag  = config.TimeDelay;    % 10;   % lag
m    = config.EmbDim;    % 10;   % embedding dimension
w1   = config.w1;   % 100;  % window (Theiler correction for autocorrelation)
w2   = config.w2;   % 410;  % window (used to sharpen the time resolution of synchronization measure)
pref = config.pref; % 0.01;

speed = 16;

% set active channels
usechan = zeros(num_chans,1); %FALSE = 0, TRUE = 1
usechan(1:num_chans) = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% trim input data
num_usechan = sum( usechan(1:num_chans) ); % determine number of used channels
usechan_index = zeros(num_usechan,1); % create an index that relates # in-use channel to # actual channel

n = 1; % counter
for k = 1 : num_chans
    if usechan(k)
        usechan_index(n) = k;
        n = n + 1;
    end %if
end %for
X = X(:,usechan_index);

% calculate number of iterations
num_it = floor( (m2 - lag*(m-1))/speed ) - ceil( m1/speed ) + 1;


% calculate the synchronization likelihood matrix
[ S_matrix, hit_matrix ] = synchronization(X,lag,m,w1,w2,pref,speed);

%--------------------------------------------------
% calculate outputs
%--------------------------------------------------
% calculate S_ki for each channel & time, averaged over all other channels ("first file")
% i.e. an average synchronization value for driver system k, with all other response systems l
S_ki_matrix = zeros(num_usechan, num_it); % initialize
S_ki_temp = sum(S_matrix, 2); % sum across response systems (l)
S_ki_temp = (S_ki_temp - 1) / (num_usechan - 1); % average the sum ( -1 occurs to eliminate current channel count )
S_ki_matrix(:) = S_ki_temp(:); % store in matrix

%--------------------------------------------------
% calculate S_i for each time; is an averaged S_ki across k ("second file")
S_i_matrix = sum(S_ki_matrix,1)/num_usechan; % sum across k and average, size (1, num_it)

%--------------------------------------------------
% calculate pairwise time-averaged synchronization likelihood ("third file")

S_kl_temp = sum(hit_matrix, 3); % sum the hit matrix across time i, size (num_chan, num_chan)
hit_diag = diag( S_kl_temp );
% at a (k,l) position, s_kl_temp contains the number of hits occuring at both channels k & l, over all i & j
% at a (k,k) position, s_kl_temp contains the number of hits at channel k, over all i & j

S_kl_matrix = hit_diag * ones(1,num_usechan) + ones(num_usechan,1) * hit_diag';
% at a (k,l) position, s_kl_matrix contains the number of hits occuring at k and at l (hits at both k&l are counted twice)
% at a (k,k) position, s_kl_matrix contains the number of hits occuring at k, times 2

S_kl_matrix = S_kl_matrix + (S_kl_matrix == 0); % if S(k,k) == 0 & S(l,l) == 0 then S(k,l) must also be 0.
% this calculation protects against division by 0

% 2 * ( #k & l are both hit ) / ( #k is hit + #l is hit )
% = harmonic average of ( #k hit / # k & l are hit ) and ( #l hit / # k & l are hit )
S_kl_matrix = 2 * S_kl_temp ./ S_kl_matrix;

%--------------------------------------------------

% % overall synchronization
% S = sum(sum(sum(S_matrix,1)-1))/(num_usechan-1)/num_usechan/num_it;
RESULT = S_kl_matrix;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNCHRONIZATION SUBPROCEDURE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% a modified version of synchronization.m (display changes)

function [RESULT1, RESULT2] = synchronization(S_in,lag,m,w1,w2,pref,speed);

% read in data, determine size of data
% S_in must be 2-D, size #samples x #chans
[num_samples, num_chans] = size(S_in);

% initialize variables
m1 = 1;           % first sample
m2 = num_samples; % last sample

% calculate number of iterations
num_it = floor( (m2 - lag*(m-1))/speed ) - ceil( m1/speed ) + 1;

% initialize variables - inner loop
epsilon = ones(num_chans,1); % epsilon(of channel k) at time i

% initialize variables - outer loop
S_matrix = zeros(num_chans,num_chans,num_it); %S(k,l,i) matrix
hit_matrix = zeros(num_chans,num_chans,num_it);
i_count = 0; % iteration count, used to store matrix entries

% on_display percentage meter
pmdots = 20; % number of dots to display

for i = m1 : (m2 - lag*(m-1))
    if mod(i, speed) == 0
        
        i_count = i_count + 1;
        
        pm = floor(i_count/num_it*pmdots);
        
        % determine the valid j times, w1<|i-j|<w2
        j = m1 : (m2 - lag*(m-1));
        valid_range = abs(i-j)>w1 & abs(i-j)<w2; % vector of valid range positions
        num_validj = sum(valid_range); % number of valid range positions

        % construct compressed table of euclidean distances
        euclid4_table = zeros(num_chans,num_validj);
        n = 0; % counter
        for j = m1 : (m2 - lag*(m-1))
            if valid_range(j-m1+1)
                n = n + 1;
                for k = 1 : num_chans
                    % euclid4 not explicity called; saves about 25% of time
                    %euclid4_table(k,n) = euclid4(S_in,lag,m,k,i,j);
                    euclid4_table(k,n) = sqrt( sum(   (S_in(i+lag*(0:(m-1)),k) ...
                                                     - S_in(j+lag*(0:(m-1)),k)).^2   ) );
                end %for
            end %if
        end %for
        
        % construct table of epsilons (formerly used the "crlocal" subroutine)
        % epsilon(k) is epsilon_{k,i}: the actual threshold distance such that the fraction
        % of all distances |X_{k,i} - X_{k,j}| less than epsilon_{k,i} is Pref
        for k = 1 : num_chans
            sorted_table = sort( euclid4_table(k,:) ); % size (1,validj)
            epsilon(k) = sorted_table( ceil( pref * num_validj ) );
        end %for
        
        % construct 'hit' table, i.e. determine if |X_{k,i} - X_{k,j}| <= epsilon_x for each k & j
        % size (num_chans, num_validj)
        hit_table = ( euclid4_table <= ( epsilon(1:num_chans) * ones(1,num_validj) ) );
        hit_table = double(hit_table); %Matlab 6.5
        
        % construct alternate hit table:
        % at position (k,l), determine the number of hits occuring at both channels k & l (across all j)
        % size (num_chans, num_chans)
        hit_table2 = hit_table * hit_table';
        
        % determine number of hits for each channel, across all j
        % NOTE: this is equivalent to diag(hit_table2)
        %num_hitsperchan = sum( hit_table, 2 ); % size (num_chans,1)
        num_hitsperchan = diag(hit_table2);
        
        % store hit_table2 in a 3-D array
        hit_matrix(:,:,i_count) = hit_table2;
        
        % perform conditional probability calculation
        % divide k^th row by number of hits for channel k
        S_matrix(:,:,i_count) = hit_table2 ./ ( num_hitsperchan * ones(1,num_chans) );
        
    end %if mod(i, speed) == 0
end %for

RESULT1 = S_matrix;
RESULT2 = hit_matrix;
  
% % overall synchronization likelihood
% S = sum(sum(sum(S_matrix,1)-1))/(num_chans-1)/num_chans/num_it;

