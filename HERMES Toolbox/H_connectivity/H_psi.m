function output = H_psi ( data, freqRange )
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
%

[Nsamples, Nchannels, Nwindows, Ntrials] = size(data);

% Each trial is subdivided in 9 overlapping segments.
epleng   = Nsamples;
segleng  = floor ( epleng / 4.5 );
freqbins = freqRange;

dataT = zeros (Nsamples*Ntrials,Nchannels);

for t = 1:Ntrials
    dataT( (t-1)*Nsamples+1:t*Nsamples,: ) = squeeze( data(:,:,:,t) );
end

[psi, stdpsi, psisum, stdpsisum] = data2psi( dataT, segleng, epleng, freqbins );
output = psi./(stdpsi+eps);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [psi, stdpsi, psisum, stdpsisum]=data2psi(data,segleng,epleng,freqbins)

% Calculates phase slope index (PSI) as formulated in the paper:
%    Nolte G, Ziehe A, Nikulin VV, Schl\"ogl A, Kr\"amer N, Brismar T, M\"uller KR. 
%    Robustly estimating the flow direction of information in complex physical systems. 
%    Physical Review Letters. To appear. 
%    (for further information:    http://doc.ml.tu-berlin.de/causality/ )
% usage:
% [psi, stdpsi, psisum, stdpsisum]=data2psi(data,segleng,epleng,freqbins);
%
% Input:
% data:  NxM matrix for N data points in M channels;
% segleng: segment length in bins, (frequency resolution is determined by it) 
% epleng:  length of epochs in bins. This is needed only to estimate the 
%          standard deviation of PSI. Setting epleng=[] avoids estimation 
%          of the standard deviation (which is faster). 
% freqbins:  KxQ matrix. Each row contains the frequencies (in bins), over
%            which  PSI is calculated. (freqbins includes the last frequency
%            (f+delta f), i.e. the band F in the paper is given for the 
%             k.th row as F=freqbins(k,1:end-1).  
%             By setting freqbins=[] PSI is calculated across all frequencies (wide band). 
% 
% Output: 
% psi:  non-normalized PSI values. For M channels PSI is either an MxM matrix (if freqbins has one or zero rows) 
%                   or an MxMxK tensor if freqbins has K rows (with K>1).
%                   psi(i,j) is the (non-normalized) flow from channel i to
%                   channel j, (e.g., channel i is the sender if psi(i,j) is
%                   positive.) 
% stdpsi: estimated standard deviation for PSI. 
%         PSI in the paper is given by psi./(stdpsi+eps) (eps is included
%         to avoid 0/0 for the diagonal elements) 
% psisum =sum(psi,2) is the net flux for each channel. 
% stdpsisum  is the estimated standard deviation of psisum. (stdpsisum cannot be 
%             calculated from psi and stdpsi - therefore the extra output) 
%
%
% License
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see http://www.gnu.org/licenses/.

[ndat, nchan] = size(data);
method        = 'jackknife';
segshift      = segleng/2;
epjack        = epleng;
  
if isempty(epleng)
    method = 'none';
    epleng = ndat;
end
if isempty(freqbins)
    maxfreqbin = floor(segleng/2)+1;
    freqbins   = 1:maxfreqbin;
else
    maxfreqbin = max(max(freqbins));
end
  
   
%     nepoch=floor(ndat/epleng);
if epjack>0
    nepochjack = floor(ndat/epjack);
else
    nepochjack = 2;  
end
      
para.segave=1;
para.subave=0;
[cs,nave]=data2cs_event(data,segleng,segshift,epleng,maxfreqbin,para);

[nm, nf] = size(freqbins);
psall    = zeros(nchan,nchan,nm);
pssumall = zeros(nchan,nm);

for ii=1:nm;
      psall(:,:,ii)  = cs2ps(cs(:,:,freqbins(ii,:)));
      pssumall(:,ii) = sum(psall(:,:,ii),2);
end

psisum=squeeze(pssumall);
      
csall    = cs;
psloc    = zeros(nchan,nchan,nepochjack,nm);
pssumloc = zeros(nchan,nepochjack,nm);

if strcmp(method,'jackknife')
    if epjack>0
        for i=1:nepochjack
            dataloc=data((i-1)*epjack+1:i*epjack,:);
            csloc=data2cs_event(dataloc,segleng,segshift,epleng,maxfreqbin,para);
            cs=(nepochjack*csall-csloc)/(nepochjack+1);
            for ii=1:nm;
              psloc(:,:,i,ii)=cs2ps(cs(:,:,freqbins(ii,:)));
              pssumloc(:,i,ii)=sum(psloc(:,:,i,ii),2);
            end
        end
    end

    psi=squeeze(psall);
    stdpsi=squeeze(std(psloc,0,3))*sqrt(nepochjack);

    stdpsisum=squeeze(std(pssumloc,0,2))*sqrt(nepochjack);
elseif strcmp(method,'none')
    psi=psall;
    stdpsi=0;
    stdpsisum=0;
    %disp('no standard deviation calculated')  
end
   
%   psi=ps;
%   psisim=pssum;
%   stdpsi=stdps;
%   stdpsisum=stdpssum; 
  
%  return
 
function ps = cs2ps(cs)
    
df=1;
nf = size(cs,3);
pp=cs;
for f=1:nf
    pp(:,:,f)=cs(:,:,f)./sqrt(diag(cs(:,:,f))*diag(cs(:,:,f))');
end
ps=sum(imag(conj(pp(:,:,1:end-df)).*pp(:,:,1+df:end)),3);

% return
            
function [cs,nave]=data2cs_event(data,segleng,segshift,epleng,maxfreqbin,para)
% usage: [cs,nave]=data2cs_event(data,segleng,segshift,epleng,maxfreqbin,para)
% 
% calculates cross-spectra from data for event-related measurement
% input: 
% data: ndat times nchan matrix each colum is the time-series in one
%             channel;
% segleng: length of each segment in bins, e.g. segleng=1000;  
% segshift: numer of bins by which neighboring segments are shifted;
%           e.g. segshift=segleng/2 makes overlapping segments
% epleng: length of each epoch
% maxfreqbin: max frequency in bins
% para: optional structure:
%       para.segave=0  -> no averaging across segments 
%       para.segave neq 0 -> averaging across segments (default is 0)% \
%       para.subave =1 subtracts the average across epochs,  
%       para.subave ~= 1 -> no subtraction (default is 1) 
%       IMPORTANT: if you just one epoch (e.g. for continuous data)
%         set para.subave=0 
%         
%       -> averaging across segments (default is 0)
%       para.proj must be a set of vector in channel space,  
%       if it exists then the output raw contains the single trial 
%       Fourier-transform in that channel   
%     
%         
% output: 
% cs: nchan by chan by maxfreqbin by nseg tensor cs(:,:,f,i) contains 
%     the cross-spectrum at frequency f and segment i
%     
% nave: number of averages

subave=1; 

if nargin<6
    para=[];
end

maxfreqbin=min([maxfreqbin,floor(segleng/2)+1]);

segave=0;
mydetrend=0;
proj=[];
  if isfield(para,'segave')
    segave=para.segave;
  end 
   if isfield(para,'detrend')
    mydetrend=para.detrend;
  end 
  if isfield(para,'proj')
    proj=para.proj;
  end 
  if isfield(para,'subave')
    subave=para.subave;
  end 

npat=size(proj,2);

[ndat,nchan]=size(data);
if npat>0 
   data=data*proj;
   nchan=npat;
end

nep=floor(ndat/epleng);

nseg=floor((epleng-segleng)/segshift)+1; %total number of segments



if segave==0
 cs=zeros(nchan,nchan,maxfreqbin,nseg); 
 av=zeros(nchan,maxfreqbin,nseg);
else
 cs=zeros(nchan,nchan,maxfreqbin); 
 av=zeros(nchan,maxfreqbin);
end

if npat>0
  if segave==0
    cs=zeros(nchan,nchan,maxfreqbin,nep,nseg); 
    av=zeros(nchan,maxfreqbin,nep,nseg);
  else
    cs=zeros(nchan,nchan,maxfreqbin,nep); 
    av=zeros(nchan,maxfreqbin,nep);
  end
end


mywindow=repmat(hanning(segleng),1,nchan);
if isfield(para,'mywindow');
    mywindow=repmat(para.mywindow,1,nchan);
end

%figure;plot(mywindow);
nave=0;
for j=1:nep;
    dataep=data((j-1)*epleng+1:j*epleng,:);
    for i=1:nseg; %average over all segments;
        dataloc=dataep((i-1)*segshift+1:(i-1)*segshift+segleng,:);
        if mydetrend==1
           datalocfft=fft(detrend(dataloc,0).*mywindow);
        else
           datalocfft=fft(dataloc.*mywindow);
        end
        
         for f=1:maxfreqbin % for all frequencies
          if npat==0
             if segave==0
                 cs(:,:,f,i)=cs(:,:,f,i)+conj(datalocfft(f,:)'*datalocfft(f,:)); 
		 av(:,f,i)=av(:,f,i)+conj(datalocfft(f,:)');
             else 
                %disp([i,f,size(datalocfft)])
                cs(:,:,f)=cs(:,:,f)+conj(datalocfft(f,:)'*datalocfft(f,:)); 
		av(:,f)=av(:,f)+conj(datalocfft(f,:)');
             end
          else 
             if segave==0
                 cs(:,:,f,j,i)=conj(datalocfft(f,:)'*datalocfft(f,:));
                 av(:,f,j,i)=conj(datalocfft(f,:)');  
             else 
                %disp([i,f,size(datalocfft)])
                cs(:,:,f,j)=cs(:,:,f,j)+conj(datalocfft(f,:)'*datalocfft(f,:));
                av(:,f,j)=av(:,f,j)+conj(datalocfft(f,:)');  
             end
          end

        end
    end
    nave=nave+1;
end

if segave==0
  cs=cs/nave;
  av=av/nave;
else
  nave=nave*nseg;  
  cs=cs/nave;
  av=av/nave;
end

for f=1:maxfreqbin
  if subave==1
       if npat==0
          if segave==0
              for i=1:nseg;cs(:,:,f,i)=cs(:,:,f,i)-av(:,f,i)*av(:,f,i)';end;
          else 
              cs(:,:,f)=cs(:,:,f)-av(:,f)*av(:,f)';
          end
       else 
          if segave==0
              for i=1:nseg;
                for j=1:nep;
                    cs(:,:,f,j,i)=cs(:,:,f,j,i)-av(:,f,j,i)*av(:,f,j,i)';
                end
              end
          else 
              for j=1:nep;cs(:,:,f,j)=cs(:,:,f,j)-av(:,f,j)*av(:,f,j)';end
          end
       end
  end
end
% 
% return;