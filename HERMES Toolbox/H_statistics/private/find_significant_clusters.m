function [ clust_out, mass_out ] = find_significant_clusters ( Msync1, Msync2, dist_sens, maxdist, n, fix )

% Devuelve la localizacion de los n clusters mas significativos en orden
% decreciente de importancia, siguiendo la idea de clustering por
% contiguidad de Maris and Oostenveld (J Neurosci Methods, 164, 2007),
% usando como estadistico la suma de la t de cada punto de la matriz
% (con un test de dos colas). Pensado para el caso de dos grupos de 
% sujetos (para otros casos, retocar codigo), para hacer tests de
% permutaciones posteriormente sobre los clusters mas significativos.

% Salidas:
%
% * clust_out: contiene los indices correspondientes a los n
%   clusters mas significativos. n x size(sync_matriz1)
%   
%   clust_out(1,...) es el cluster mayor, clust_out(2,...) el 2 mayor, etc.
%   'mayor' significa 'de mayor 'exceedance mass' en valor absoluto'
%   
%  * mass_out: tamano ('exceedance mass', suma de la t en todos los 
%   puntos del cluster, manteniendo el signo) de cada cluster. 1 x n 
%  
% Basado en: Maris and Oostenveld (J Neurosci Methods, 164, 2007)
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
% Authors:  Ricardo Gutierrez, 2010
% 	        Guiomar Niso, Ricardo Gutierrez, 2011
%


dims = size(Msync1);
dims = dims(2:end); % dimensiones de la matriz de un sujeto
n_dims = ndims(Msync1) - 1; % n dimensiones de la matriz de sinc de un sujeto

% Voxel-level statistic

switch fix
    case 'Condition' % between groups
       [H,P,CI,STATS] = ttest2_mod(Msync1,Msync2,.05,'both'); %two sample t-test
    case 'Group'% between conditions
       [H,P,CI,STATS] = ttest(Msync1,Msync2,.05,'both'); %paired t-test
end


switch n_dims %% ESTA PARTE (DE AQUI A LA LINEA 132) ES, JUNTO CON LA 
              % FUNCION CLUSTERING, LA QUE MAS TIEMPO CONSUME (CONVIENE OPTIMIZAR)

    case 2  % Nsensors x Nsensors
        
       matriz_t = squeeze(STATS.tstat);
       matriz_H = squeeze(H);
       
       ttest_mat = matriz_t.*matriz_H;
       ttest_mat = triu(ttest_mat,1); 
       % Ponemos a cero todo lo que esta en y bajo la diagonal principal
       
       t_f_labels = ttest_mat; 
       % argumento de entrada necesario para clustering.m
       % en el caso de 2 dimensiones no se usa en esa funcion
        
    case 3  % Nsensors x Nsensors x t (o f)
       
       matriz_t = squeeze(STATS.tstat);
       matriz_H = squeeze(H);
       
       uppertri = triu(ones(dims(1)),1); % Nsensors x Nsensors
       uppertri = repmat(uppertri, [1 1 dims(3)]);
        
       ttest_mat = uppertri.*matriz_t.*matriz_H;  
       % Ponemos a cero todo lo que esta en y bajo la diagonal principal
       ttest_mat(isnan(ttest_mat)) = 0; 
       % Para borrar los valores indefinidos de la diagonal (par {sensorX, sensorX})
       
       
       % Clustering por tiempo (o frecuencia)
       
       t_f_labels = zeros(dims);
        
       for d1 = 1:dims(1)
           for d2 = d1+1:dims(1)
               t_f_labels(d1,d2,:) = bwlabel(squeeze(ttest_mat(d1,d2,:)));
               % adyacencia en tiempo (o frecuencia). Se mira por separado 
               % para cada par de sensores
           end
       end
             
        
    case 4  % Nsensors x Nsensors x t x f
        
       matriz_t = squeeze(STATS.tstat);
       matriz_H = squeeze(H);
       
       uppertri = triu(ones(dims(1)),1); % Nsensors x Nsensors
       uppertri = repmat(uppertri, [1 1 dims(3) dims(4)]);
        
       ttest_mat = uppertri.*matriz_t.*matriz_H;  
       % Ponemos a cero todo lo que esta en y bajo la diagonal principal
       ttest_mat(isnan(ttest_mat)) = 0; 
       % Para borrar los valores indefinidos de la diagonal (par {sensorX, sensorX})
        
       % Clustering por tiempo y frecuencia
        
       t_f_labels = zeros(dims);
    
       for d1 = 1:dims(1)
           for d2 = d1+1:dims(1)
               t_f_labels(d1,d2,:,:) = bwlabel(squeeze(ttest_mat(d1,d2,:,:)));
               % adyacencia en tiempo y frecuencia. Se mira por separado
               % para cada par de sensores
           end
       end
end  

[cluster, Nclusters] = clustering(t_f_labels, ttest_mat, dist_sens, maxdist); 

% hacemos el clustering con la informacion de t y f 
% y la informacion espacial

aux_cluster = zeros(dims);
mass_clust = zeros(1,Nclusters);

n_out = min(Nclusters,n);
clust_out = zeros([n_out dims]);
mass_out = zeros(1, n_out);

% n_out = n (n < Nclusters); si no, habra un mensaje de error.

switch n_dims

    case 2  % Nsensors x Nsensors
        
        for i = 1:Nclusters
            aux_cluster(cluster == i) = 1;
            mass_clust(1,i) = sum(sum(aux_cluster.*ttest_mat)); % exceedance mass
            aux_cluster = zeros(dims);
        end
        
        for i = 1:n_out
            [y,j] = max(abs(mass_clust));
            indices = cluster == j;
            clust_out(i,indices) = 1;
            mass_out(1,i) = mass_clust(j); % Con su signo original (para ver en que sentido van las diferencias)
            mass_clust(j) = 0;
        end
        
    case 3  % Nsensors x Nsensors x t (o f)

        for i = 1:Nclusters
            aux_cluster(cluster == i) = 1;
            mass_clust(1,i) = sum(sum(sum(aux_cluster.*ttest_mat))); % exceedance mass
            aux_cluster = zeros(dims);
        end        
        
        for i = 1:n_out
            [y,j] = max(abs(mass_clust));
            indices = cluster == j;
            clust_out(i,indices) = 1;
            mass_out(1,i) = mass_clust(j); % Con su signo original
            mass_clust(j) = 0;
        end
        
        
    case 4  % Nsensors x Nsensors x t x f

        for i = 1:Nclusters
            aux_cluster(cluster == i) = 1;
            mass_clust(1,i) = sum(sum(sum(sum(aux_cluster.*ttest_mat)))); % exceedance mass
            aux_cluster = zeros(dims);
        end
        
        for i = 1:n_out
            
            [y,j] = max(abs(mass_clust));
            indices = cluster == j;
            clust_out(i,indices) = 1;
            mass_out(1,i) = mass_clust(j); % Con su signo original
            mass_clust(j) = 0;
        end
end

% Si no hay clusteres pone la masa a 0.
if isempty ( mass_out ), mass_out = 0; end


function [cluster, nclusters] = clustering(t_f_labels, ttest_mat, dist_sens, maxdist)
    
% Realiza una agrupacion conjunta en todas las dimensiones a partir de las
% etiquetas de adyacencia espacial (por un lado) y en tiempo o frecuencia o
% ambas cosas (por otro).
%
% * cluster: matriz de tamano igual a la de sincronizacion original (y, por
%   tanto, a t_f_labels) que incluye etiquetas correspondientes al 
%   clustering final.
%
% * nclusters: numero de clusters resultante. Alguno puede estar vacio,
%   porque se puede abrir un cluster nuevo para un elemento de la matriz 
%   que es posteriormente asignado a uno que ya se habia abierto antes.


% FUNCION QUE CONSUME BASTANTE TIEMPO (CONVIENE OPTIMIZAR)

dims = size(t_f_labels);
n_dims = ndims(t_f_labels);
                    
spatial_labels = zeros(dims(1));
cluster = zeros(dims);
cluster_t_f = squeeze(cluster(1,1,:,:));
cluster_spat = zeros(dims(1));

latest_lab = 1; % etiqueta para el proximo cluster en ser identificado

switch n_dims
    
    case 2  % n_sensors x n_sensors

        for sens1 = 1:dims(1) % primer sensor del par
            for sens2 = sens1+1:dims(1) % segundo sensor del par
                        
                    if ttest_mat(sens1,sens2) ~= 0 
                        % puntos significativos (el resto: cluster 0)

                        if cluster(sens1,sens2) == 0 
                            % punto significativo no asignado a cluster

                            cluster(sens1,sens2) = latest_lab; % apertura de cluster nuevo
                            current_lab = latest_lab; % cluster actual abierto (para expandir)
                            latest_lab = latest_lab + 1; % preparamos proximo cluster

                        else % punto significativo ya asignado a un cluster

                            current_lab = cluster(sens1,sens2); % expansion de cluster ya abierto

                        end

                        spatial_labels = find_adjacent_pairs(sens1, sens2, dist_sens, maxdist); % Vemos que pares estan 'proximos' al que estamos mirando

                        ind_spat = find(spatial_labels == 1); % pares de sensores adyacentes...
                        [ind_spat_i, ind_spat_j] = ind2sub(dims(1:2),ind_spat);

                        for i = 1:length(ind_spat)
                            if (sign(ttest_mat(ind_spat_i(i),ind_spat_j(i))) == sign(ttest_mat(sens1,sens2))) 
                                % Si es par adyacente y en el se rechaza la hipotesis nula con una t de igual signo
                                cluster(ind_spat(i)) = current_lab; % .... se anade al cluster actual
                            end
                        end
                    end
             end
        end

    case 3  % n_sensors x n_sensors x t (o f)

        for sens1 = 1:dims(1) % primer sensor del par
            for sens2 = (sens1+1):dims(1) % segundo sensor del par
                for d3 = 1:dims(3) % tiempo o frecuencia
                       
                        if ttest_mat(sens1,sens2,d3) ~= 0 
                            % puntos significativos (el resto: cluster 0)
                            
                            if cluster(sens1,sens2,d3) == 0 
                                % punto significativo no asignado a cluster
                                
                                cluster(sens1,sens2,d3) = latest_lab; % apertura de cluster nuevo
                                current_lab = latest_lab; % cluster actual abierto (para expandir)
                                latest_lab = latest_lab + 1; % preparamos proximo cluster
                              
                            else % punto significativo ya asignado a un cluster

                                current_lab = cluster(sens1,sens2,d3); % expansion de cluster ya abierto
                            
                            end
                                
                            ind_t_f = find(squeeze(t_f_labels(sens1,sens2,:)) == t_f_labels(sens1,sens2,d3)); % puntos adyacentes en el tiempo (o frec)...
                            ind_ind_t_f = squeeze(sign(ttest_mat(sens1,sens2,ind_t_f))) == squeeze(sign(ttest_mat(sens1,sens2,d3))); % ... en los que la t tiene el mismo signo...
                            
                            cluster_t_f = squeeze(cluster(sens1,sens2,:));
                            cluster_t_f(ind_t_f(ind_ind_t_f)) = current_lab;
                            cluster(sens1,sens2,:)  = cluster_t_f; % ... se anaden al cluster actual
                            
                            spatial_labels = find_adjacent_pairs(sens1, sens2, dist_sens, maxdist); % Vemos que pares estan 'proximos' al que estamos mirando
                            
                            ind_spat = find(spatial_labels == 1); % pares de sensores adyacentes...
                            [ind_spat_i, ind_spat_j] = ind2sub(dims(1:2),ind_spat);
                            cluster_spat = squeeze(cluster(:,:,d3));
                            
                            for i = 1:length(ind_spat)
                                if (sign(ttest_mat(ind_spat_i(i),ind_spat_j(i),d3)) == sign(ttest_mat(sens1,sens2,d3))) 
                                    % Si es par adyacente y en el se
                                    % rechaza la hipotesis nula con una t de igual signo
                                    
                                    cluster_spat(ind_spat(i)) = current_lab; % .... se le pone la etiqueta y...
                                
                                end
                            end
                            cluster(:,:,d3) = cluster_spat; % ... se anaden al cluster actual
                            
                        end
                        
                end
            end
        end
              
        
      case 4  % n_sensors x n_sensors x t x f

        for sens1 = 1:dims(1)
            for sens2 = (sens1+1):dims(1)
                for d3 = 1:dims(3)
                    for d4 = 1:dims(4)
                        
        
                        if t_f_labels(sens1,sens2,d3,d4) ~= 0 
                            % puntos significativos (el resto: cluster 0)
                            
                            if cluster(sens1,sens2,d3,d4) == 0 
                                % punto significativo no asignado a cluster
                                
                                cluster(sens1,sens2,d3,d4) = latest_lab; % apertura de cluster nuevo
                                current_lab = latest_lab; % cluster actual abierto (para expandir)
                                latest_lab = latest_lab + 1; % preparamos proximo cluster
                                
                            else % punto significativo ya asignado a un cluster

                                current_lab = cluster(sens1,sens2,d3,d4); % expansion de cluster ya abierto
                            
                            end
                            
                            ind_t_f = find(squeeze(t_f_labels(sens1,sens2,:,:)) == t_f_labels(sens1,sens2,d3,d4)); % puntos adyacentes en el plano tiempo-frecuencia...
                            ind_ind_t_f = squeeze(sign(ttest_mat(sens1,sens2,ind_t_f))) == squeeze(sign(ttest_mat(sens1,sens2,d3,d4))); % ... en los que la t tiene el mismo signo...
                            
                            cluster_t_f = squeeze(cluster(sens1,sens2,:,:));
                            cluster_t_f(ind_t_f(ind_ind_t_f)) = current_lab;
                            cluster(sens1,sens2,:,:) = cluster_t_f; % ... se anaden al cluster actual
                            
                            spatial_labels = find_adjacent_pairs(sens1, sens2, dist_sens, maxdist); % Vemos que pares estan 'proximos' al que estamos mirando
                        
                            ind_spat = find(spatial_labels == 1); % pares de sensores adyacentes...
                            [ind_spat_i, ind_spat_j] = ind2sub(dims(1:2),ind_spat);
                            cluster_spat = squeeze(cluster(:,:,d3,d4));
                            
                            for i = 1:length(ind_spat)
                                if (sign(ttest_mat(ind_spat_i(i),ind_spat_j(i),d3,d4)) == sign(ttest_mat(sens1,sens2,d3,d4))) 
                                    % Si es par adyacente y en el se
                                    % rechaza la hipotesis nula con una t de igual signo
                                    
                                    cluster_spat(ind_spat(i)) = current_lab; % .... se le pone la etiqueta y...
                                
                                end
                            end
                            
                            cluster(:,:,d3,d4) = cluster_spat; % ... se anaden al cluster actual

                        end
                    end
                end
            end                      
        end                        

end

nclusters = latest_lab - 1;

function spatial_labels = find_adjacent_pairs(sens1, sens2, dist_sens, max_dist)

% Da una misma etiqueta a los pares de sensores adyacentes a uno dado para 
% permitir el agrupamiento espacial en clustering.m.
%
% * spatial_labels: etiquetas de adyacencia espacial.n_sensors x n_sensors. 
%   matriz bidimensional de con unos en las posiciones correspondientes a 
%   pares proximos a (sens1,sens2) y ceros en el resto de posiciones

n_sensors = size(dist_sens,1);
spatial_labels = zeros(n_sensors);

ci = find(dist_sens(sens1,:) < max_dist(sens1));
cj = find(dist_sens(sens2,:) < max_dist(sens2));
          
spatial_labels(ci,cj) = 1; % 1 pares proximos, 0 el resto 
spatial_labels(cj,ci) = 1;
% Par proximo a uno dado: aquel que consta de dos sensores adyacentes, cada 
% uno de ellos, a uno de los sensores del par dado

% Ponemos a cero todo lo que queda por debajo de la diagonal principal
% Asi en clustering no se tiene en cuenta dos veces cada par
spatial_labels = triu(spatial_labels); 



function [h,p,ci,stats] = ttest2_mod(x,y,alpha,tail,vartype,dim)
%TTEST2_MOD Two-sample T-test with pooled or unpooled variance estimate.
%   H = TTEST2_MOD(X,Y) performs a T-test of the hypothesis that two
%   independent samples, in the vectors X and Y, come from distributions
%   with equal means, and returns the result of the test in H.  H=0
%   indicates that the null hypothesis ("means are equal") cannot be
%   rejected at the 5% significance level.  H=1 indicates that the null
%   hypothesis can be rejected at the 5% level.  The data are assumed to
%   come from normal distributions with unknown, but equal, variances.  X
%   and Y can have different lengths.
%
%   X and Y can also be matrices or N-D arrays.  For matrices, TTEST2
%   performs separate T-tests along each column, and returns a vector of
%   results.  X and Y must have the same number of columns.  For N-D
%   arrays, TTEST2 works along the first non-singleton dimension.  X and Y
%   must have the same size along all the remaining dimensions.
%
%   TTEST2 treats NaNs as missing values, and ignores them.
%
%   H = TTEST2(X,Y,ALPHA) performs the test at the significance level
%   (100*ALPHA)%.  ALPHA must be a scalar.
%
%   H = TTEST2(X,Y,ALPHA,TAIL) performs the test against the alternative
%   hypothesis specified by TAIL:
%       'both'  -- "means are not equal" (two-tailed test)
%       'right' -- "mean of X is greater than mean of Y" (right-tailed test)
%       'left'  -- "mean of X is less than mean of Y" (left-tailed test)
%   TAIL must be a single string.
%
%   H = TTEST2(X,Y,ALPHA,TAIL,VARTYPE) allows you to specify the type of
%   test.  When VARTYPE is 'equal', TTEST2 performs the default test
%   assuming equal variances.  When VARTYPE is 'unequal', TTEST2 performs
%   the test assuming that the two samples come from normal distributions
%   with unknown and unequal variances.  This is known as the Behrens-Fisher
%   problem. TTEST2 uses Satterthwaite's approximation for the effective
%   degrees of freedom.  VARTYPE must be a single string.
%
%   [H,P] = TTEST2(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis is true.  Small values of P cast doubt on the validity of
%   the null hypothesis.
%
%   [H,P,CI] = TTEST2(...) returns a 100*(1-ALPHA)% confidence interval for
%   the true difference of population means.
%
%   [H,P,CI,STATS] = TTEST2(...) returns a structure with the following fields:
%      'tstat' -- the value of the test statistic
%      'df'    -- the degrees of freedom of the test
%      'sd'    -- the pooled estimate of the population standard deviation
%                 (for the equal variance case) or a vector containing the
%                 unpooled estimates of the population standard deviations
%                 (for the unequal variance case)
%
%   [...] = TTEST2(X,Y,ALPHA,TAIL,VARTYPE,DIM) works along dimension DIM of
%   X and Y.  Pass in [] to use default values for ALPHA, TAIL, or VARTYPE.
%
%   See also TTEST, RANKSUM, VARTEST2, ANSARIBRADLEY.

%   References:
%      [1] E. Kreyszig, "Introductory Mathematical Statistics",
%      John Wiley, 1970, section 13.4. (Table 13.4.1 on page 210)

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 2.15.4.9 $  $Date: 2006/06/20 20:51:53 $

if nargin < 2
    error('stats:ttest2:TooFewInputs','Requires at least two input arguments');
end

if nargin < 3 || isempty(alpha)
    alpha = 0.05;
elseif ~isscalar(alpha) || alpha <= 0 || alpha >= 1
    error('stats:ttest2:BadAlpha','ALPHA must be a scalar between 0 and 1.');
end

if nargin < 4 || isempty(tail)
    tail = 0;
elseif ischar(tail) && (size(tail,1)==1)
    tail = find(strncmpi(tail,{'left','both','right'},length(tail))) - 2;
end
if ~isscalar(tail) || ~isnumeric(tail)
    error('stats:ttest2:BadTail', ...
          'TAIL must be one of the strings ''both'', ''right'', or ''left''.');
end

if nargin < 5 || isempty(vartype)
    vartype = 1;
elseif ischar(vartype) && (size(vartype,1)==1)
    vartype = find(strncmpi(vartype,{'equal','unequal'},length(vartype)));
end
if ~isscalar(vartype) || ~isnumeric(vartype)
    error('stats:ttest2:BadVarType', ...
          'VARTYPE must be one of the strings ''equal'' or ''unequal''.');
end

if nargin < 6 || isempty(dim)
    % Figure out which dimension mean will work along by looking at x.  y
    % will have be compatible. If x is a scalar, look at y.
    dim = find(size(x) ~= 1, 1);
    if isempty(dim), dim = find(size(y) ~= 1, 1); end
    if isempty(dim), dim = 1; end
    
    % If we haven't been given an explicit dimension, and we have two
    % vectors, then make y the same orientation as x.
    if isvector(x) && isvector(y)
        if dim == 2
            y = y(:)';
        else % dim == 1
            y = y(:);
        end
    end
end

% Make sure all of x's and y's non-working dimensions are identical.
sizex = size(x); sizex(dim) = 1;
sizey = size(y); sizey(dim) = 1;
if ~isequal(sizex,sizey)
    error('stats:ttest2:InputSizeMismatch',...
          'The data in a 2-sample t-test must be commensurate.');
end

xnans = isnan(x);
if any(xnans(:))
    nx = sum(~xnans,dim);
else
    nx = size(x,dim); % a scalar, => a scalar call to tinv
end
ynans = isnan(y);
if any(ynans(:))
    ny = sum(~ynans,dim);
else
    ny = size(y,dim); % a scalar, => a scalar call to tinv
end


s2x = nanvar(x,[],dim);
s2y = nanvar(y,[],dim);
difference = nanmean(x,dim) - nanmean(y,dim);
if vartype == 1 % equal variances
    dfe = nx + ny - 2;
    sPooled = sqrt(((nx-1) .* s2x + (ny-1) .* s2y) ./ dfe);
    se = sPooled .* sqrt(1./nx + 1./ny);
    ratio = difference ./ se;
    %PRUEBA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:size(ratio,2)
        ratio(:,i,i,:,:)=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (nargout>3)
        stats = struct('tstat', ratio, 'df', cast(dfe,class(ratio)), ...
                       'sd', sPooled);
        if isscalar(dfe) && ~isscalar(ratio)
            stats.df = repmat(stats.df,size(ratio));
        end
    end
elseif vartype == 2 % unequal variances
    s2xbar = s2x ./ nx;
    s2ybar = s2y ./ ny;
    dfe = (s2xbar + s2ybar) .^2 ./ (s2xbar.^2 ./ (nx-1) + s2ybar.^2 ./ (ny-1));
    se = sqrt(s2xbar + s2ybar);
    ratio = difference ./ se;

    if (nargout>3)
        stats = struct('tstat', ratio, 'df', cast(dfe,class(ratio)), ...
                       'sd', sqrt(cat(dim, s2x, s2y)));
        if isscalar(dfe) && ~isscalar(ratio)
            stats.df = repmat(stats.df,size(ratio));
        end
    end
    
    % Satterthwaite's approximation breaks down when both samples have zero
    % variance, so we may have gotten a NaN dfe.  But if the difference in
    % means is non-zero, the hypothesis test can still reasonable results,
    % that don't depend on the dfe, so give dfe a dummy value.  If difference
    % in means is zero, the hypothesis test returns NaN.  The CI can be
    % computed ok in either case.
    if se == 0, dfe = 1; end
else
    error('stats:ttest2:BadVarType',...
          'VARTYPE must be ''equal'' or ''unequal'', or 1 or 2.');
end

% Compute the correct p-value for the test, and confidence intervals
% if requested.
if tail == 0 % two-tailed test
    p = 2 * tcdf(-abs(ratio),dfe);
    if nargout > 2
        spread = tinv(1 - alpha ./ 2, dfe) .* se;
        ci = cat(dim, difference-spread, difference+spread);
    end
elseif tail == 1 % right one-tailed test
    p = tcdf(-ratio,dfe);
    if nargout > 2
        spread = tinv(1 - alpha, dfe) .* se;
        ci = cat(dim, difference-spread, Inf(size(p)));
    end
elseif tail == -1 % left one-tailed test
    p = tcdf(ratio,dfe);
    if nargout > 2
        spread = tinv(1 - alpha, dfe) .* se;
        ci = cat(dim, -Inf(size(p)), difference+spread);
    end
else
    error('stats:ttest2:BadTail',...
          'TAIL must be ''both'', ''right'', or ''left'', or 0, 1, or -1.');
end

% Determine if the actual significance exceeds the desired significance
h = cast(p <= alpha, class(p));
h(isnan(p)) = NaN; % p==NaN => neither <= alpha nor > alpha

