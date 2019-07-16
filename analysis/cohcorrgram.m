function out = cohcorrgram(data, n1, n2, opts)
% Calculate time-windowed cross-correlation between coherences for subsets
% n1 and n2 of multivariate timeseries y.
%
% Calling with no output args will plot.
%
% Inputs: data   -- a 2D array of size [time x nodes/locs/vertices/channels]
%         n1, n2 -- vectors with indices of subsets of nodes 'data' to group
%                   cross-correlation is between n1 and n2.
%         opts   -- a struct with options (set according to the desired temporal
%                  resolution), with fields:
%                  .dt     -- time step in physical units
%                  .maxlag -- max time lag, in physical units
%                  .winlen -- window length, in physical units
%                  .overlapfrac -- window overlap, in the interval [0,1)
%                  .inputphases -- 1 if input data is already instantanous phases (0 default)
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
% REQUIRES: 
%          corrgram() -- a modified version of original corrgram (MATLAB FEX 15299)
%          compute_inst_phase() -- calculate unwrapped instantaneous phases
%          bluegred() -- blue-grey-red colormap
% 
% MODIFICATION HISTORY:
%          JA Roberts, QIMR Berghofer, 2018
%          PSL, QIMR Berghofer, 2019, use diverging colourmap.

if nargin < 4
    opts.dt = 1; % time step in physics units
    % default settings for time-windowed cross correlation
    opts.maxlag = 30; % max time lag, in physical units
    opts.winlen = 20; % window length, in physical units
    opts.overlapfrac = 0.8; % window overlap, in the interval [0,1)
    opts.inputphases = 0; % 1 if the input y is the phases
end

% Local variables
dt = opts.dt;
maxlag = round(opts.maxlag/dt); % convert to time points
winlen = round(opts.winlen/dt); %
overlapfrac = opts.overlapfrac;

% corrgram
if opts.inputphases
    yphase = data;
else
    yphase = compute_inst_phase(data);
end

coh1 = abs(mean(exp(1i*yphase(:,n1)),2)); % coherence 'order parameter'
coh2 = abs(mean(exp(1i*yphase(:,n2)),2)); % 

% sliding-window cross correlation between the two order parameters
[cc, cl, ct] = corrgram(coh1, coh2, maxlag, winlen, floor(winlen*overlapfrac));

ct=ct*dt; % back into physical units
cl=cl*dt; %

if nargout==0
    %figure('position',[360 748 1200 200])
    cmap = bluegred(256);
    imagesc(ct,cl,cc)
    set(gca,'YDir','normal')
    xlabel('t (physical units)'), ylabel('lag (physical units)')
    caxis([-1 1])
    colormap(cmap);
    cbar = colorbar;
    ylabel(cbar,'cc')
else
    out.cc = cc; % Corr coeff
    out.cl = cl; % Lag
    out.ct = ct; % Time
    out.opts = opts;
    out.n1 = n1;
    out.n2 = n2;
end