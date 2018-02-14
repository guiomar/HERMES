function output = H_methods_IT ( data, config, waitbar )

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
% This function calls the toolbox TIM
% http://www.cs.tut.fi/~timhome/tim/tim.htm
%
% Authors:  Guiomar Niso, 2012
%           Guiomar Niso, Ricardo Bruna, Ernesto Pereda, 2014


% Checks the existence of the waitbar.
if nargin < 3, waitbar = []; end

% Fetchs option data
MI_on  = H_check ( config.measures, 'MI'  );
PMI_on = H_check ( config.measures, 'PMI' );
TE_on  = H_check ( config.measures, 'TE'  );
PTE_on = H_check ( config.measures, 'PTE' );

% Windows the data.
data = H_window ( data, config.window );

% Gets the size of the analysis data.
[ samples, channels, windows, trials ] = size ( data );

% if channels<15
%     Nlags = channels-1; 
% else
    Nlags = 1; % 1, to save time but...
% end

Npart     = channels-2; % para la parcializacion
% tWindRad  = 10; % para la TMI

% Reservamos memoria para cada indice.
if MI_on,  output.MI.data  = zeros ( channels, channels, windows ); end
if PMI_on, output.PMI.data = zeros ( channels, channels, windows ); end
if TE_on,  output.TE.data  = zeros ( channels, channels, windows ); end
if PTE_on, output.PTE.data = zeros ( channels, channels, windows ); end

% Throttled variables.
interval_between_checks = 0.2;
tic

%  We go over all windows and all pairs of sensors.
for window = 1: windows
    for ch1 = 1: channels-1
        
        % Prepare the data in the first channel (of each pair ) for analysis
        data_ch1 = squeeze( data( :, ch1, window, : ) );
        
        if trials > 1
            celldata_ch1 = squeeze( mat2cell( permute( data_ch1,[ 3 1 2 ] ), 1, samples, ones( trials, 1 ) ) )';
        else
            celldata_ch1 = { data_ch1' };
        end
        
        %%%%
        celldata_ch1 = delay_embed( celldata_ch1, config.TimeDelay, config.EmbDim);
        %%%%
        
        if TE_on || PTE_on
            w1 = delay_embed_future( celldata_ch1, config.TimeDelay );
        end
        
        % Now run for channels greater than ch1
        for ch2 = ch1 + 1: channels
            
            data_ch2 = squeeze( data( :, ch2, window, : ) );
            
            % Places each trial in a separate cell field.
            if trials > 1
                celldata_ch2 = squeeze( mat2cell( permute ( data_ch2,[ 3 1 2 ] ), 1, samples, ones( trials, 1 ) ) )';
            else
                celldata_ch2 = { data_ch2' };
            end
            %%%%
            celldata_ch2 = delay_embed( celldata_ch2, config.TimeDelay, config.EmbDim);
            %%%%
            
            if MI_on
                output.MI.data( ch1, ch2, window ) = max( mutual_information( celldata_ch1, celldata_ch2, 'yLag', 0: Nlags - 1, 'k', config.Nneighbours ) );
                output.MI.data( ch2, ch1, window ) = output.MI.data( ch1, ch2, window );
            end
            
%             if H_check ( config.measures, 'TMI' )
%                 output.TMI.data ( i, j, window ) = max(mutual_information_t ( celldata_i, celldata_j, tWindRad,'yLag',0:Nlags-1,'k',config.Nneighbours));
%                 % asimetrica? output.TMI.data ( j, i, window ) = output.MI.data ( i, j, window );
%             end
            
            % Throttled check.
            if toc > interval_between_checks
                
                % Checks for user cancelation.
                if ( H_stop ), return, end
            end
            
            if PMI_on
                
                PartNodes = setdiff( 1: channels,[ ch1, ch2 ] );
                Groups    = nchoosek( PartNodes, Npart );
                
                for n3 = 1: size( Groups, 1 )
                    PMI_origen = zeros( 1, Nlags );
                    
                    data_ch3 = squeeze( data( :, Groups( n3,: ), window, : ) );
                    data_ch3 = reshape( data_ch3, [samples*Npart, trials]);

                    if trials > 1,     
                        celldata_ch3 = squeeze( mat2cell( permute ( data_ch3,[ 3 1 2 ] ), 1, samples*Npart, ones( trials, 1 ) ) )';
                    else
                        celldata_ch3 = { data_ch3' };   
                    end
                    %%%%
                    celldata_ch3 = delay_embed( celldata_ch3, config.TimeDelay, config.EmbDim);
                    %%%%
                    
                    for lag = 0: Nlags - 1
                        PMI_origen( lag + 1 ) = min( mutual_information_p( celldata_ch1, celldata_ch2, celldata_ch3,'yLag',lag,'zLag',0:Nlags-1,'k',config.Nneighbours ) );
                    end
                    output.PMI.data ( ch1, ch2, window ) = max( PMI_origen );
                end
            end
            
            % Throttled check.
            if toc > interval_between_checks
                
                % Checks for user cancelation.
                if ( H_stop ), return, end
            end
            
            % This loop only is executed if some TE index is required.
            
            if TE_on || PTE_on
                
                %     for dt = config.TimeDelay
                
                w2 = delay_embed_future( celldata_ch2, config.TimeDelay );
                
                
                if TE_on
                    
                    TE_origen = zeros ( 2, Nlags );

                    for lag = 0: Nlags-1
                        TE_origen( 1, lag + 1 ) = max( transfer_entropy( celldata_ch1, celldata_ch2, w1, 'yLag', 0: Nlags - 1, 'k', config.Nneighbours ) );
                        TE_origen( 2, lag + 1 ) = max( transfer_entropy( celldata_ch2, celldata_ch1, w2, 'yLag', 0: Nlags - 1, 'k', config.Nneighbours ) );
                    end
                    
                    output.TE.data( ch2, ch1, window ) = max( TE_origen ( 1, : ) );
                    output.TE.data( ch1, ch2, window ) = max( TE_origen ( 2, : ) );
                end
                
%                 if H_check ( config.measures, 'TTE' )
%                     output.TTE.data ( i, j, window ) = max(transfer_entropy_t ( celldata_i, celldata_j, w, tWindRad,'yLag',0:Nlags-1,'k',config.Nneighbours));
%                     output.TTE.data ( j, i, window ) = max(transfer_entropy_t ( celldata_j, celldata_i, w, tWindRad,'yLag',0:Nlags-1,'k',config.Nneighbours));
%                 end
                
                if PTE_on
                    
                    PartNodes = setdiff ( 1: channels, [ ch1, ch2 ] );
                    Groups    = nchoosek ( PartNodes, Npart );
                    
                    for n3 = 1: size( Groups, 1 )
                        PTE_origen = zeros ( 2, Nlags );
                        data_ch3   = squeeze( data( :, Groups( n3,: ), window, : ) );
                        data_ch3   = reshape(data_ch3, [samples*Npart, trials]);
                        
                        % Places each trial in a separate cell field.
                        if trials > 1,     
                            celldata_ch3 = squeeze( mat2cell( data_ch3, samples*Npart, ones( trials, 1 ) ) );
                        else
                            celldata_ch3 = { data_ch3' };     
                        end
                        %%%%
                        celldata_ch3 = delay_embed( celldata_ch3, config.TimeDelay, config.EmbDim);
                        %%%%
                        
                        for lag = 0: Nlags-1
                            PTE_origen( 1, lag + 1 ) = min ( transfer_entropy_p ( celldata_ch1, celldata_ch2, celldata_ch3, w1,'yLag', lag, 'zLag', 0: Nlags - 1, 'k', config.Nneighbours ) );
                            PTE_origen( 2, lag + 1 ) = min ( transfer_entropy_p ( celldata_ch2, celldata_ch1, celldata_ch3, w2,'yLag', lag, 'zLag', 0: Nlags - 1, 'k', config.Nneighbours ) );
                        end
                        
                        output.PTE.data( ch2, ch1, window ) = max( PTE_origen ( 1, : ) );
                        output.PTE.data( ch1, ch2, window ) = max( PTE_origen ( 2, : ) );
                    end
                end                
            end
            % end
            
            % Throttled check.
            if toc > interval_between_checks
                tic
                
                % Checks for user cancelation.
                if ( H_stop ), return, end
                
                % Updates the waitbar.
                if ~isempty ( waitbar )
                    waitbar.progress( 5:6 ) = [ window windows ];
                    waitbar.progress( 7 )   = ( 2 * channels - ch1 ) * ( ch1 - 1 ) / 2 + ( ch2 - ch1 );
                    waitbar.progress( 8 )   = channels * ( channels - 1 ) / 2;
                    waitbar                 = H_waitbar( waitbar );
                end
            end
        end
    end
    
    % Updates the waitbar.
    if ~isempty( waitbar )
        waitbar.progress( 5:6 )    =  [ window windows ];
        waitbar.progress( 7: end ) = [];
        waitbar                    = H_waitbar( waitbar );
    end
end
