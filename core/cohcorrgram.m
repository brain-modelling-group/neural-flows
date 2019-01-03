function out=cohcorrgram(y,n1,n2,opts)
%  CC = cohcorrgram(y,n1,n2,opts)
% Calculate time-windowed cross-correlation between coherences for subsets
% n1 and n2 of multivariate timeseries y.
%
% Calling with no output args will plot.
%
% Inputs: y - matrix of time series, time running down the columns
%         n1,n2 - subsets of nodes indexing which columns in y to group
%         opts - options struct (set according to the desired temporal
%                  resolution), with fields:
%                dt - time step in physical units
%                maxlag - max time lag, in physical units
%                winlen - window length, in physical units
%                overlapfrac - window overlap, in the interval [0,1)
%                inputphases - 1 if input y is already the phases (0 default)
%
% Output: struct with fields:
%         cc - cross-correlogram, a matrix with rows indexed by lag and
%              columns indexed time
%         cl - lag vector
%         ct - time vector
%         opts - the opts struct
%         n1 - the input n1
%         n2 - the input n2
%
% Uses a modified version of corrgram.m (MATLAB FEX 15299)
%
% JA Roberts, QIMR Berghofer, 2018

    
if nargin<4
    opts.dt=1; % time step in physics units
    % default settings for time-windowed cross correlation
    opts.maxlag=30; % max time lag, in physical units
    opts.winlen=20; % window length, in physical units
    opts.overlapfrac=0.8; % window overlap, in the interval [0,1)
    opts.inputphases=0; % 1 if the input y is the phases
end
dt=opts.dt;
maxlag=round(opts.maxlag/dt); % convert to time points
winlen=round(opts.winlen/dt); %
overlapfrac=opts.overlapfrac;

% corrgram
if opts.inputphases
    yphase=y;
else
    yphase=phases_nodes(y);
end

coh1=abs(mean(exp(1i*yphase(:,n1)),2)); % coherence 'order parameter'
coh2=abs(mean(exp(1i*yphase(:,n2)),2)); % 
% sliding-window cross correlation between the two order parameters
[cc,cl,ct]=corrgram(coh1,coh2,maxlag,winlen,floor(winlen*overlapfrac));
ct=ct*dt; % back into physical units
cl=cl*dt; %

if nargout==0
    %figure('position',[360 748 1200 200])
    imagesc(ct,cl,cc)
    set(gca,'YDir','normal')
    xlabel('t (ms)'), ylabel('lag (ms)')
    caxis([-1 1])
    cbar=colorbar;
    ylabel(cbar,'cc')
else
    out.cc=cc;
    out.cl=cl;
    out.ct=ct;
    out.opts=opts;
    out.n1=n1;
    out.n2=n2;
end