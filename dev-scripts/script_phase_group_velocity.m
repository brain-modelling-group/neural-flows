% This script explores the differences between using the amplitude, the phase
% and the unwrapped phase to determine the group velocity of a travelling wave. 
% PSL - Dec 2019
% This script shows, I hope, a few things: 
% 1) that using the phase and amplitude of a (raw) signal can yield different results in terms of flows 
% 2) that group velocity and phsae velocity are/can be two different quantities
% 3) that applying the hilbert transfrom mindlessly will get you in trouble
% 4) that filtering the signal only in time does not yield a good
%    representation of the actual physical wave -- by that I mean that in this
%    example the temporal frequency of the wave (ie, amplitude modulation)
%    is approximately 0.5 Hz, but if we calculate the power
%    spectrum/spectrogram, we see the individual frequencies of wave1
%    and wave2. So when we filter we most likely select one of those freq peaks and
%    probably filter out the frequency of interest. 
% 5) that there is enough evidence now and a strong argument to stop considering space and time as
%    separable variables.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      BIHARMONIC SURFACE WAVE                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this example the phase velocity and group velocity are in opposite
% directions.

% Wave parameters
fc  = 4;    % Hz
nuc = 2;    % 1/m
df  = 0.25; % Hz
dnu = 0.25; % 1/m

w1  = 2*pi*(fc+df);    %angular frequency rad/s
k1x = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
k1y = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
w2  = 2*pi*(fc-df);    %angular frequency rad/s
k2x = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m
k2y = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m

k2 = sqrt(k2x.^2 + k2y.^2); %radial angular wavenumber rad/m
k1 = sqrt(k1x.^2 + k1y.^2); %radial angular wavenumber rad/m

% Group velocity
dw = (w2-w1);
dk = (k2-k1);
vg = dw / dk;

% Wave velocity -- velocity of the carrier wave 1
vp = w1 / k1;

% Spatiotemporal grid 
dx = 0.02;
dy = 0.02;
dt = 0.02;
xx = 0:dx:1;
yy = 0:dy:1;
tt = 0:dt:5;
[x, y, t] = meshgrid(xx, yy, tt);

% Wave components
wave1 = cos(w1.*t-k1x.*x+k1y.*y);
wave2 = cos(w2.*t-k2x.*x+k2y.*y);
 
wave1 = fliplr(wave1);
wave2 = fliplr(wave2);
wv = wave1 + wave2;

%% Plotting of results
[pdg_sentinel] = set_default_groot({'light', 'medium'});
save_formats = {'tiff', 'jpeg'};
output_path = '~/Work/Articles/neural-flows-article/figures';

%% Figure 2 -- 2D+t wave
nr = 3;
nc = 4;
these_units = 'centimeters';
figure2_handle = figure('Name', 'fig2');
% Assumes figure units are in cm
figure2_handle.Position = [-35.0838  14.2875 28 19];

for kk=1:8
   ax(kk) = subplot(nr, nc, kk);
   ax(kk).Units = these_units;
   hold(ax(kk), 'on')
end

ax(9)  = subplot(nr, nc, 9);
ax(9).Units = these_units;
hold(ax(9), 'on')

ax(10) = subplot(nr, nc, [10 12]);
ax(10).Units = these_units;
hold(ax(10), 'on')

alpha_data = 0.75;
x_idx = floor(length(xx)/2);
y_idx = floor(length(yy)/2);

% First frame -- wave 1
imagesc(ax(1), xx, yy, wave1(:, :, 1), 'AlphaData', alpha_data);
ax(1).YDir = 'reverse';
ax(1).XAxisLocation = 'top';
ax(1).YLabel.String = 'y [m]';
ax(1).XLabel.String = 'x [m]';

plot(ax(1), xx(x_idx), yy(y_idx), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(1), xx(x_idx), yy(y_idx), 'kx', 'markersize', 8)

% Time course -- wave 1
plot(ax(2), tt, squeeze(wave1(y_idx, x_idx, :)), 'k');
ax(2).XAxisLocation = 'top';
ax(2).XLim = [0 2];
ax(2).XLabel.String = 'time [s]';
ax(2).YLabel.String = 'w_1(x_0, y_0, t)';


% First frame -- wave 2
imagesc(ax(3), xx, yy, wave2(:, :, 1), 'AlphaData', alpha_data);
ax(3).YDir = 'reverse';
ax(3).XAxisLocation = 'top';
ax(3).YLabel.String = 'y [m]';
ax(3).XLabel.String = 'x [m]';

plot(ax(3), xx(x_idx), yy(y_idx), 'w+', 'markersize', 10)
plot(ax(3), xx(x_idx), yy(y_idx), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(3), xx(x_idx), yy(y_idx), 'kx', 'markersize', 8)

% Time course -- wave 2
plot(ax(4), tt, squeeze(wave2(y_idx, x_idx, :)), 'k');
ax(4).XAxisLocation = 'top';
ax(4).XLim = [0 2];
ax(4).XLabel.String = 'time [s]';
ax(4).YLabel.String  = 'w_2(x_0, y_0, t)';

% Frames - wave sum
frames = [1 20 50 80];
for kk=1:length(frames)
    colormap(redyellowblue(256, 'rev'))
    imagesc(ax(kk+4), xx, yy, wv(:, :, frames(kk)), 'AlphaData', alpha_data);
    ax(kk+4).YDir = 'reverse';
    ax(kk+4).XAxisLocation = 'top';
    ax(kk+4).YLabel.String = 'y [m]';
    ax(kk+4).XLabel.String = 'x [m]';
end

plot(ax(5), xx(x_idx)*ones(length(yy), 1), yy,  'k--')

% Wave in 1D
data =  wv(:, x_idx, 1);
surf(ax(9), [yy(:) yy(:)], [data(:) data(:)], [data(:) data(:)], ...  % Reshape and replicate data
     'FaceColor', 'none', ...    % Don't bother filling faces with color
     'EdgeColor', 'interp', ...  % Use interpolated color for edges
     'EdgeAlpha', 0.9,...
     'LineWidth', 4);
colormap(redyellowblue(256, 'rev'))
ax(9).XLabel.String = 'y [m]';
ax(9).YLabel.String = 'w(x_0, y, t_0) ';

% Markers
plot(ax(10), tt, squeeze(wv(y_idx, x_idx, :)), 'k')
plot(ax(10), tt(frames(2:end)), squeeze(wv(y_idx, x_idx, frames(2:end))), 'r.', 'markersize', 20)
ax(10).XLim = [0 5];
xlabel('time [s]')
ylabel('w(x_0, y_0, t) ')


plot(ax(6), xx(x_idx), yy(y_idx), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(6), xx(x_idx), yy(y_idx), 'kx', 'markersize', 8)

plot(ax(7), xx(x_idx), yy(y_idx), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(7), xx(x_idx), yy(y_idx), 'kx', 'markersize', 8)

plot(ax(8), xx(x_idx), yy(y_idx), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(8), xx(x_idx), yy(y_idx), 'kx', 'markersize', 8)
%% Frames - wave sum - amplitude
vidfile = VideoWriter('wave_velocity.avi');
open(vidfile);

figure2a_handle = figure('Name', 'fig2a');
ax_mov = subplot(1,1,1);
axis equal
for kk=1:length(tt)
    colormap(redyellowblue(256, 'rev'))
    imagesc(ax_mov, xx, yy, wv(:, :, kk), 'AlphaData', alpha_data);
    ax_mov.YDir = 'reverse';
    ax_mov.XAxisLocation = 'top';
    ax_mov.YLabel.String = 'y [m]';
    ax_mov.XLabel.String = 'x [m]';
    pause(0.1)
    drawnow
    f = getframe(figure2a_handle);
    writeVideo(vidfile, f);
end
 close(vidfile)
 
%% Frames - wave sum - phase
vidfile = VideoWriter('wave_velocity_phase.avi');
phi = angle(hilbert(wv));
open(vidfile);

figure2b_handle = figure('Name', 'fig2b');
ax_mov = subplot(1,1,1);
axis equal
cmap = pmkmp_new('ostwald_o', 256);
for kk=1:length(tt)
    colormap(cmap) % from neuropatt
    imagesc(ax_mov, xx, yy, phi(:, :, kk), 'AlphaData', alpha_data);
    ax_mov.YDir = 'reverse';
    ax_mov.XAxisLocation = 'top';
    ax_mov.YLabel.String = 'y [m]';
    ax_mov.XLabel.String = 'x [m]';
    pause(0.1)
    drawnow
    f = getframe(figure2b_handle);
    writeVideo(vidfile, f);
end
 close(vidfile)

%% Figure 3 - plot slice across one spatal dimension, at 4 different time points  
figure3_handle = figure('Name', 'fig3');
nr = 4;
nc = 1;

for kk=1:4
   ax(kk) = subplot(nr, nc, kk, 'Parent', figure3_handle);
   hold(ax(kk), 'on')
end

figure3_handle.Position = [ -35.0573   14.2081 13.6 19.2];

fl1 = 50; % samples to estimate the envelope
frames = [1 5 10 15];

for kk=1:4
    data = squeeze(wv(:, x_idx, frames(kk)));
    [up1,lo1] = envelope(data, fl1,'analytic');
    surf(ax(kk), [yy(:) yy(:)], [data(:) data(:)], [data(:) data(:)], ...  % Reshape and replicate data
     'FaceColor', 'none', ...    % Don't bother filling faces with color
     'EdgeColor', 'interp', ...  % Use interpolated color for edges
     'EdgeAlpha', 0.9,...
     'LineWidth', 4);     
    colormap(redyellowblue(256, 'rev'))
    plot(ax(kk), yy, up1, 'k', 'linewidth', 2)
    plot(ax(kk), yy, lo1, 'k', 'linewidth', 2)
    ax(kk).YLim = [-2 2];
    ax(kk).XLim = [0 2];
    ax(kk).Box = 'on';
    t_time = num2str(tt(frames(kk)), '%.2f');
    ax(kk).YLabel.String = ['f(x_0, y, ', t_time, ' )'];
end

ax(4).XLabel.String = 'y [m]';

% Create lines across subplots
an_h1 = annotation(figure3_handle,'line',[0, 0], [1, 1],'LineStyle','--',...
                          'Units', these_units);

% Create line
an_h2 = annotation(figure3_handle,'line',[0, 0], [1, 1],'LineStyle','-.', ...
                           'Units', these_units);
an_h1.Position =  [4.4450    4.0217    2.6988   13.8112];                                         
an_h2.Position =  [8.4138 5.0800 -1.2700 12.7529];                   

%% Figure 4a -- neuropatt amplitude-based estimation raw signal
% TODO: automate the following 4 cells. At the momemnbt neuropatt part is
% handded via gui and it isn't automatic. Unselect filter and baseline
% substraction. Select phase or amplitude. Select real SVD, top 2 modes.
tstart = 20;
wv_t = wv(:, :, tstart:end-tstart); 
NeuroPattGUI(wv_t, 50);

% Get figure handle to SVD plots
figure_handle = figure(1);
ax(1) = figure_handle.Children(5);
ax(2) = figure_handle.Children(3);

% Save data
U1(:, :, 1) =  ax(1).Children.UData;
V1(:, :, 1) =  ax(1).Children.VData;

U2(:, :, 1) =  ax(2).Children.UData;
V2(:, :, 1) =  ax(2).Children.VData;

%% Clear figures
close all
%% Figure 4b -- neuropatt phase-based estimation -- hilbert transform of raw signal
phi   = angle(hilbert(wv));% Frames - wave sum
phi   = phi(:, :, tstart:end-tstart);
NeuroPattGUI(phi, 50)

figure_handle = figure(1);
ax(1) = figure_handle.Children(5);
ax(2) = figure_handle.Children(3);

% Save data
U1(:, :, 2) =  ax(1).Children.UData;
V1(:, :, 2) =  ax(1).Children.VData;

U2(:, :, 2) =  ax(2).Children.UData;
V2(:, :, 2) =  ax(2).Children.VData;
%% Clear figures
close all
%% Figure 4c -- neuropatt amplitude-based estimation envelope of signal
env   = abs(hilbert(wv));
env   = env(:, :, tstart:end-tstart);
NeuroPattGUI(env, 50)

figure_handle = figure(1);
ax(1) = figure_handle.Children(5);
ax(2) = figure_handle.Children(3);

% Save data
U1(:, :, 3) =  ax(1).Children.UData;
V1(:, :, 3) =  ax(1).Children.VData;

U2(:, :, 3) =  ax(2).Children.UData;
V2(:, :, 3) =  ax(2).Children.VData;

%% Clear figures
close all
%% Figure 4d -- neuropatt phase-based estimation -- via hilbert transform of envelope
env     = abs(hilbert(wv));
phi_env = angle(hilbert(env));
phi_env = phi_env(:,:, tstart:end-tstart);

NeuroPattGUI(phi_env, 50)
figure_handle = figure(1);
ax(1) = figure_handle.Children(5);
ax(2) = figure_handle.Children(3);

% Save data
U1(:, :, 4) =  ax(1).Children.UData;
V1(:, :, 4) =  ax(1).Children.VData;

U2(:, :, 4) =  ax(2).Children.UData;
V2(:, :, 4) =  ax(2).Children.VData;

%%
figure4_handle = figure('Name', 'fig4_comparison');
% Frames - wave sum
ds = 5;
frames = 1:ds:ds*4;

nr = 4;
nc = 6;

% Indices to look at one bit inside the space
idx_start = 5;
idx_stop  = 46;

clear waveforms
waveforms(:, :, :, 1) = wv;
waveforms(:, :, :, 2) = angle(hilbert(wv));
waveforms(:, :, :, 3) = abs(hilbert(wv));
waveforms(:, :, :, 4) = angle(hilbert(abs(hilbert(wv))));
waveforms = waveforms(idx_start:idx_stop, idx_start:idx_stop, tstart:end-tstart, :);

xv = xx(idx_start:idx_stop);
yv = yy(idx_start:idx_stop);

for kk=1:nr*nc
    ax(kk) = subplot(nr, nc, kk);
    hold(ax(kk), 'on')
end

cmap_phi = pmkmp_new('ostwald_o', 256);
cmap_amp = redyellowblue(256, 'rev');
caxis_phi = [-pi pi];
caxis_amp = [-2 2];

% Plot frames with input data to neuropatt
for ww=1:4
    if mod(ww, 2)
        cmap = cmap_amp;
        caxis_val = caxis_amp;
    else
        cmap = cmap_phi;
        caxis_val = caxis_phi;
    end
    for kk=1:length(frames)
        r = ww;
        c = kk;
        idx = sub2ind([nc, nr], c, r);
        imagesc(ax(idx), xv, yv, squeeze(waveforms(:, :, frames(kk), ww)));
        caxis(caxis_val)
        ax(idx).YDir = 'reverse';
        ax(idx).Colormap = cmap;
        if idx > 1 
            ax(idx).XTickLabel = [];
            ax(idx).YTickLabel = [];
            ax(idx).XLabel.String = [];
            ax(idx).YLabel.String = [];
        else
            ax(idx).XAxisLocation = 'top';
            ax(idx).YLabel.String = 'y [m]';
            ax(idx).XLabel.String = 'x [m]';
        end
        ax(idx).XLim = [xv(1) xv(end)];
        ax(idx).YLim = [yv(1) yv(end)];
        
    end
end


subp = [19 20 21 22];
subpl_labels = {'t_0', 't_1', 't_2', 't_3'};

for kk = 1:length(subp)
  ax(subp(kk)).XLabel.String = subpl_labels{kk};
end

% Plot SVD modes
X = x(idx_start:idx_stop, idx_start:idx_stop, 1);
Y = y(idx_start:idx_stop, idx_start:idx_stop, 1);


idx_st = floor(length(yv)/2)-5;
idx_sp = floor(length(yv)/2)+5;

Y = Y(idx_st:idx_sp, idx_st:idx_sp);
X = X(idx_st:idx_sp, idx_st:idx_sp);

for ww=1:4
    for c=5:6
        r = ww;   
        idx = sub2ind([nc, nr], c, r);

        if c==5
          quiver(ax(idx), X, Y, U1(idx_st:idx_sp, idx_st:idx_sp, ww), V1(idx_st:idx_sp, idx_st:idx_sp, ww), 'Color', [0.35 0.35 0.35]);
        else
          quiver(ax(idx), X, Y, U2(idx_st:idx_sp, idx_st:idx_sp, ww), V2(idx_st:idx_sp, idx_st:idx_sp, ww), 'Color', [0.35 0.35 0.35]);
        end
                  
        ax(idx).YDir = 'reverse';
        ax(idx).XTickLabel = [];
        ax(idx).YTickLabel = [];
        ax(idx).XLabel.String = [];
        ax(idx).YLabel.String = [];
        
        ax(idx).XLim = [min(X(:)) max(X(:))];
        ax(idx).YLim = [min(Y(:)) max(Y(:))];
    end
end

ax(nc).XAxisLocation = 'top';
ax(nc).YAxisLocation = 'left';

ax(nc).XLabel.String = 'x [m]';
ax(nc).YLabel.String = 'y [m]';

ax(nc).XTick = [min(X(:)) max(X(:))];
ax(nc).XTickLabel = {num2str(min(X(:)), '%.2f'), num2str(max(Y(:)), '%.2f')};
ax(nc).YTick = [min(Y(:)) max(Y(:))];
ax(nc).YTickLabel = {num2str(min(Y(:)), '%.2f'), num2str(max(Y(:)), '%.2f')};

%% Small rectangle to illustarte what part of the field we're visualising
subp = [4 10 16 22];

for kk=1:4
    patch(ax(subp(kk)), 'XData', [xv(idx_st) xv(idx_st) xv(idx_sp) xv(idx_sp) xv(idx_st)], ...
                        'YData', [yv(idx_st) yv(idx_sp) yv(idx_sp) yv(idx_st) xv(idx_st)], 'FaceColor', 'None');
end
