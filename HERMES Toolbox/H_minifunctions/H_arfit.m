function A = H_arfit ( v, p )
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



[ samples, channels, trials] = size ( v );

mcor = 1;
ne   = trials * ( samples - p );
np   = channels * p + mcor;

if ne <= np, error ( 'Time series too short.' ), end

% compute QR factorization for model of order pmax
[R, scale]   = arqr(v, p, mcor);

% select order of model
popt         = p;%min + iopt-1; % estimated optimum order
np           = channels*popt + mcor; % number of parameter vectors of length m

% decompose R for the optimal model order popt according to
%
%   | R11  R12 |
% R=|          |
%   | 0    R22 |
%
R11   = R(1:np, 1:np);
R12   = R(1:np, np+1:np+channels);
R22   = R(np+1:np+channels, np+1:np+channels);

% get augmented parameter matrix Aaug=[w A] if mcor=1 and Aaug=A if mcor=0
if (np > 0)
    if (mcor == 1)
        % improve condition of R11 by re-scaling first column
        con 	= max(scale(2:np+channels)) / scale(1);
        R11(:,1)	= R11(:,1)*con;
    end;
    Aaug = (R11\R12)';
    
    %  return coefficient matrix A and intercept vector w separately
    if (mcor == 1)
        % intercept vector w is first column of Aaug, rest of Aaug is
        % coefficient matrix A
        w = Aaug(:,1)*con;        % undo condition-improving scaling
        A = Aaug(:,2:np);
    else
        % return an intercept vector of zeros
        w = zeros(m,1);
        A = Aaug;
    end
else
    % no parameters have been estimated
    % => return only covariance matrix estimate and order selection
    % criteria for ``zeroth order model''
    w   = zeros(channels,1);
    A   = [];
end

% return covariance matrix
dof   = ne-np;                % number of block degrees of freedom
C     = R22'*R22./dof;        % bias-corrected estimate of covariance matrix

% for later computation of confidence intervals return in th:
% (i)  the inverse of U=R11'*R11, which appears in the asymptotic
%      covariance matrix of the least squares estimator
% (ii) the number of degrees of freedom of the residual covariance matrix
invR11 = inv(R11);
if (mcor == 1)
    % undo condition improving scaling
    invR11(1, :) = invR11(1, :) * con;
end
Uinv   = invR11*invR11';
th     = [dof zeros(1,size(Uinv,2)-1); Uinv];



function [R, scale]=arqr(v, p, mcor)
%ARQR	QR factorization for least squares estimation of AR model.
%
%  [R, SCALE]=ARQR(v,p,mcor) computes the QR factorization needed in
%  the least squares estimation of parameters of an AR(p) model. If
%  the input flag mcor equals one, a vector of intercept terms is
%  being fitted. If mcor equals zero, the process v is assumed to have
%  mean zero. The output argument R is the upper triangular matrix
%  appearing in the QR factorization of the AR model, and SCALE is a
%  vector of scaling factors used to regularize the QR factorization.
%
%  ARQR is called by ARFIT.
%
%  See also ARFIT.

%  Modified 29-Dec-99
%           24-Oct-10 Tim Mullen (added support for multiple realizatons)
%
%  Author: Tapio Schneider
%          tapio@gps.caltech.edu

% n:   number of time steps (per realization)
% m:   number of variables (dimension of state vectors)
% ntr: number of realizations (trials)
[n,m,ntr] = size(v);

ne    = ntr*(n-p);            % number of block equations of size m
np    = m*p+mcor;             % number of parameter vectors of size m

% If the intercept vector w is to be fitted, least squares (LS)
% estimation proceeds by solving the normal equations for the linear
% regression model
%
%                  v(k,:)' = Aaug*u(k,:)' + noise(C)        (1)
%
% with Aaug=[w A] and `predictors'
%
%              u(k,:) = [1 v(k-1,:) ...  v(k-p,:)].         (2a)
%
% If the process mean is taken to be zero, the augmented coefficient
% matrix is Aaug=A, and the regression model
%
%                u(k,:) = [v(k-1,:) ...  v(k-p,:)]          (2b)
%
% is fitted.
% The number np is the dimension of the `predictors' u(k).
%
% If multiple realizations are given (ntr > 1), they are appended
% as additional ntr-1 blocks of rows in the normal equations (1), and
% the 'predictors' (2) correspondingly acquire additional row blocks.

% Initialize the data matrix K (of which a QR factorization will be computed)
K = zeros(ne,np+m);                 % initialize K
if (mcor == 1)
    % first column of K consists of ones for estimation of intercept vector w
    K(:,1) = ones(ne,1);
end

% Assemble `predictors' u in K
for itr=1:ntr
    for j=1:p
        K((n-p)*(itr-1) + 1 : (n-p)*itr, mcor+m*(j-1)+1 : mcor+m*j) = ...
            squeeze(v(p-j+1:n-j, :, itr));
    end
    % Add `observations' v (left hand side of regression model) to K
    K((n-p)*(itr-1) + 1 : (n-p)*itr, np+1 : np+m) = squeeze(v(p+1:n, :, itr));
end

% Compute regularized QR factorization of K: The regularization
% parameter delta is chosen according to Higham's (1996) Theorem
% 10.7 on the stability of a Cholesky factorization. Replace the
% regularization parameter delta below by a parameter that depends
% on the observational error if the observational error dominates
% the rounding error (cf. Neumaier, A. and T. Schneider, 2001:
% "Estimation of parameters and eigenmodes of multivariate
% autoregressive models", ACM Trans. Math. Softw., 27, 27--57.).
q     = np + m;             % number of columns of K
delta = (q^2 + q + 1)*eps;  % Higham's choice for a Cholesky factorization
scale = sqrt(delta)*sqrt(sum(K.^2));
R     = triu(qr([K; diag(scale)]));