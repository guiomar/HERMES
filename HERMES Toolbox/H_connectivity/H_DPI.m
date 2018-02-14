function [ind12] = H_DPI (phi1, phi2, method)

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
% This function is adapted form DAMOCO toolbox:
% http://www.stat.physik.uni-potsdam.de/~mros/damoco.html
%
% This function filters two signals, estimates phases and computes
% two directionality indices
%
% For description of algorithms see:
%  www.agnld.uni-potsdam.de/~mros/pdf/PRE41909.pdf
%
% Modified by:
% Authors:  Guiomar Niso, Ricardo Bruna, 2013
%           Jose Maria Perez Ramos, GOPAC, 06/02/2013
%


                                          

% unwrap phases
phi1 = unwrap(phi1);       
phi2 = unwrap(phi2);

switch method
    case 'ema'
        ind12 = dirc( phi1, phi2 ); % EMA d12
    case 'ipa'
        ind12 = prdirc ( phi1, phi2 ); % IPA r12
end


% EPA algorithm 
% -------------------------------------------------------------------------
function d12 = dirc ( phi1, phi2 ) 
% inputs are unwrapped phases

tau1 = round ( 2*pi*length(phi1)/phi1(end) );
tau2 = round ( 2*pi*length(phi2)/phi2(end) );

TAU = min (tau1, tau2);

% Version for LFP-EMG data
pi2 = pi+pi;
npt = length(phi1) - TAU;

dphi1 = phi1(TAU+1:TAU+npt);
dphi2 = phi2(TAU+1:TAU+npt);

phi1 = phi1(1:npt);   
phi2 = phi2(1:npt);

dphi1 = dphi1-phi1;   
dphi2 = dphi2-phi2;

phi1 = mod(phi1,pi2); 
phi2 = mod(phi2,pi2);

% design matrix is common for both fittings
X = [ones(size(phi1)) sin(phi1) cos(phi1) sin(phi2) cos(phi2) ...
     sin(phi1-phi2) cos(phi1-phi2) sin(phi1+phi2) cos(phi1+phi2)...
     sin(2*phi1) cos(2*phi1) sin(2*phi2) cos(2*phi2)...
     sin(3*phi1) cos(3*phi1) sin(3*phi2) cos(3*phi2)];

% Delta\phi_1
a = X\dphi1;  
c1 = sqrt(dzdy2(a));

a = X\dphi2;  
c2 = sqrt(dzdx2(a));

% PONER EL WARNING!!!!
% % if (c1<0.01) && (c2<0.01)
% %     disp('WARNING: coefficients c1 and c2 are too small!');
% %     disp('Be careful: probably the signals are not correlated');
% % end;

d12 = (c2-c1)/(c1+c2);

    
function r=dzdx2(a)
 r = 4*a(10)^2 + 4*a(11)^2 + 9*a(14)^2 + 9*a(15)^2 + a(2)^2 ...
    + a(3)^2 + a(6)^2 + a(7)^2 + a(8)^2 + a(9)^2;

function r=dzdy2(a)
 r = 4*a(12)^2 + 4*a(13)^2 + 9*a(16)^2 + 9*a(17)^2 + a(4)^2 ...
    + a(5)^2 + a(6)^2 + a(7)^2 + a(8)^2 + a(9)^2;



% IPA algorithm 
% -------------------------------------------------------------------------
function r12 = prdirc ( phi1, phi2 )       
% inputs are unwrapped phases
    
% Dependence of instantaneous period on the phase of the second oscillator

[rt1,npt1] = instper(phi1);  % compute series of instantaneous periods
[rt2,npt2] = instper(phi2);

npt = min(npt1,npt2);

phi1 = phi1(1:npt);
phi2 = phi2(1:npt); 

rt1 = rt1(1:npt);
rt2 = rt2(1:npt);

% design matrix for fitting
X = [ones(size(phi1)) sin(phi1) cos(phi1) sin(phi2) cos(phi2) ...
     sin(phi1-phi2) cos(phi1-phi2) sin(phi1+phi2) cos(phi1+phi2)...
     sin(2*phi1) cos(2*phi1) sin(2*phi2) cos(2*phi2)...
     sin(3*phi1) cos(3*phi1) sin(3*phi2) cos(3*phi2)];

% approximate inst periods for 1st signal
a = X\rt1';   
c1 = sqrt(dzdy2(a));

% approximate inst periods for 2nd signal
a = X\rt2';
c2 = sqrt(dzdx2(a));

r12 = (c2-c1)/(c1+c2);


function [rt, nptnew] = instper( phi ) 
% input: unwrapped phases

pi2 = pi+pi;
npt = length(phi); % num of points in the signal 
tim = 1:npt; 

% Reduce point number so there is at least a 2pi safe space from
% last point's value to the new last point's value
finphi = phi(npt)-pi2;
nptnew = npt;
while phi(nptnew) > finphi
    nptnew = nptnew-1;
end;

% Changed by GOPAC (Date: 06/02/2013)
% Author: Perez Ramos, Jose Maria
%
% Before:
% For each time (t1), get its phase (p1) and then search for the time 
% (t2) with phase (p2 ~ p1+2pi), create a spline with the 10 values 
% around that time (t2) to get t2' so its phase (p2' = p1+2pi).
% (The spline is created as a phase -> time function) 
% The difference between t1 and t2' is the instant period for t1.
%
% Now:
% Spline all values at once (HUGE perfomance improvement).
% (The spline is created as a phase -> time function) 
% For each time (t1), get its phase (p1), and then evaluate the spline
% in p1+2pi to get t2'.
% The diference between both times is the instant period for each time.
%
% Results:
%   Perfomance: 
%       Up to 167x faster, as the spline creation is called just once 
%       rather than thousands of times, and there are no wasted calls 
%       to the spline creation function (before, the splines created 
%       were overlapped as it used 11 points for each spline and
%       created one spline per value in the x axis).
%   Indices:
%       By my tests, the values (instant period) calculated differ  
%       up to 2.2e-05 with a mean difference of 1.7e-07.
%       These changes are axplained as the difference between using
%       different number of points in the spline interpolation.
%

newtim = 1:nptnew; 
rt = spline(phi,tim,phi(newtim)+pi2)'-newtim;
