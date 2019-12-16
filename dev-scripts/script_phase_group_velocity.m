% This script explores the differences between using the amplitude, the phase
% and the unwrapped phase to determine the group velocity of a travelling. 
% PSL - Dec 2019


% Example: phase velocity slower than group velocity and in opposite
% direction
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

% Spatiotemporal grid 
dx = 0.02;
dy = 0.02;
dt = 0.02;
xx = 0:dx:2;
yy = 0:dy:2;
tt = 0:dt:5;
[x, y, t] = meshgrid(xx, yy, tt);

wave1 = cos(w1.*t-k1x.*x+k1y.*y);
wave2 = cos(w2.*t-k2x.*x+k2y.*y);

% Because imagscale flips the array
wave1 = fliplr(wave1);
wave2 = fliplr(wave2);
wv = wave1 + wave2;

%% Plotting of results
[pdg_sentinel] = set_default_groot({'light', 'medium'});
save_formats = {'tiff', 'jpeg'};
output_path = '~/Work/Articles/neural-flows-article/figures';
%%
nr = 3;
nc = 4;
figure2_handle = figure('Name', 'fig2');
figure2_handle.Position = [-35.0838   14.2875 28 19];

for kk=1:8
   ax(kk) = subplot(nr, nc, kk);
   hold(ax(kk), 'on')
end

ax(9)  = subplot(nr, nc, 9);
hold(ax(9), 'on')

ax(10) = subplot(nr, nc, [10 12]);
hold(ax(10), 'on')

alpha_data = 0.75;

% First frame -- wave 1
imagesc(ax(1), xx, yy, wave1(:, :, 1), 'AlphaData', alpha_data);
ax(1).YLabel.String = 'y [m]';
ax(1).XLabel.String = 'x [m]';

plot(ax(1), xx(50), yy(75), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(1), xx(50), yy(75), 'kx', 'markersize', 8)

% Time course -- wave 1
plot(ax(2), tt, squeeze(wave1(75, 50, :)), 'k');
ax(2).XLim = [0 2];
ax(2).XLabel.String = 'time [s]';
ax(2).YLabel.String = 'w_1(x_0, y_0, t)';


% First frame -- wave 2
imagesc(ax(3), xx, yy, wave2(:, :, 1), 'AlphaData', alpha_data);
ax(3).YLabel.String = 'y [m]';
ax(3).XLabel.String = 'x [m]';

plot(ax(3), xx(50), yy(75), 'w+', 'markersize', 10)
plot(ax(3), xx(50), yy(75), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(3), xx(50), yy(75), 'kx', 'markersize', 8)

% Time course -- wave 2
plot(ax(4), tt, squeeze(wave2(75, 50, :)), 'k');
ax(4).XLim = [0 2];
ax(4).XLabel.String = 'time [s]';
ax(4).YLabel.String  = 'w_2(x_0, y_0, t)';

% Frames - wave sum
frames = [1 20 50 80];
for kk=1:length(frames)
    colormap(redyellowblue(256, 'rev'))
    imagesc(ax(kk+4), xx, yy, wv(:, :, frames(kk)), 'AlphaData', alpha_data);
    ax(kk+4).YLabel.String = 'y [m]';
    ax(kk+4).XLabel.String = 'x [m]';
end
 locs = COG(1:256, :)/100;

plot(ax(5), xx(50)*ones(length(yy), 1), yy,  'k--')

% Wave in 1D
data =  wv(:, 50, 1);
%plot(ax(9), yy, wv(:, 50, 1), 'color', [0.65 0.65 0.65 0.5])
surf(ax(9), [yy(:) yy(:)], [data(:) data(:)], [data(:) data(:)], ...  % Reshape and replicate data
     'FaceColor', 'none', ...    % Don't bother filling faces with color
     'EdgeColor', 'interp', ...  % Use interpolated color for edges
     'EdgeAlpha', 0.9,...
     'LineWidth', 4);
colormap(redyellowblue(256, 'rev'))
ax(9).XLabel.String = 'y [m]';
ax(9).YLabel.String = 'w(x_0, y, t_0) ';

% Markers
plot(ax(10), tt, squeeze(wv(75, 50, :)), 'k')
plot(ax(10), tt(frames(2:end)), squeeze(wv(75, 50, frames(2:end))), 'r.', 'markersize', 20)
ax(10).XLim = [0 5];
xlabel('time [s]')
ylabel('w(x_0, y_0, t) ')


plot(ax(6), xx(50), yy(75), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(6), xx(50), yy(75), 'kx', 'markersize', 8)

plot(ax(7), xx(50), yy(75), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(7), xx(50), yy(75), 'kx', 'markersize', 8)

plot(ax(8), xx(50), yy(75), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(8), xx(50), yy(75), 'kx', 'markersize', 8)

%% Figure 3 - plot slice across one dimension and at different time points  
figure3_handle = figure('Name', 'fig3');
nr = 4;

nc = 1;

for kk=1:4
   ax(kk) = subplot(nr, nc, kk, 'Parent', figure3_handle);
   hold(ax(kk), 'on')
end

figure3_handle.Position = [ -35.0573   14.2081 13.6 19.2];

%%
fl1 = 50;
frames = [1 5 10 15];

for kk=1:4
    data = squeeze(wv(:, 50, frames(kk)));
    [up1,lo1] = envelope(data, fl1,'analytic');
    %plot(ax(kk), yy, data, 'k')
    %scatter(ax(kk), yy,data,[],data,'fill')
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


annotation(figure3_handle,'line',[0.43 0.315], ...
                                 [0.88 0.25],'LineStyle','--');

% Create line
annotation(figure3_handle,'line',[0.52 0.63],...
                                 [0.84 0.185],'LineStyle','-.');

%%
y   = hilbert(fliplr(wv));
env = abs(y);
%%
wv_lr = fliplr(wv);

%% Envelope
for kk=1:size(wv_lr, 1)
    
    for jj=1:size(wv_lr, 2)
    [up1, ~] = envelope(squeeze((wv_lr(kk, jj, :))), 60,'analytic');
    env_wv(kk, jj, :) = up1;
    end
end

%% Envelope phase
for tpt = 1:length(tt)
    data = env_wv(:, :, tpt);
    wv_phi(:, tpt) = angle(hilbert(data(:)));
end
wv_phi = reshape(wv_phi, 51,51, 251);

%%
colormap(redyellowblue(256, 'rev'))
%colormap(hsv(256))
for tpt = 1:length(tt)
%imagesc(yy, xx, env(:, :, tpt))
%imagesc(yy, xx, env_wv(:, :, tpt))

imagesc(yy, xx, fliplr(wv(:, :, tpt)))
%imagesc(yy, xx, wv_phi(:, :, tpt))

%imagesc(wave2(:, :, tt))
%xlim([1 2])
%ylim([0.5 1.5])

drawnow
pause(0.1)
end

%%


data = permute(wv, [3 1 2]);
data = reshape(data, 501, 101*101);
phi = calculate_insta_phase(data);
phi = reshape(phi, 501, 101, 101);

phi = permute(phi, [2 3 1]);

figure
plot(squeeze(phi(25, :, 1)))

figure
plot(squeeze(phi(50, 50, :)))



%%

%y = hilbert(wv);
%env = abs(y);

for tpt = 1:length(tt)
    data = (fliplr(wv(:, :, tpt)));
    wv_phi(:, tpt) = angle(hilbert(data(:)));
end
wv_phi = reshape(wv_phi, 51,51, 251);

%%
% Wave
NeuroPattGUI(fliplr(wv), 50)

% Phase
NeuroPattGUI(wv_phi, 50)

%%
fl1 = 30;
[up1,lo1] = envelope(squeeze(wv(50,50,:)), fl1,'analytic');


