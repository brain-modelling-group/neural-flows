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

w1  = 2*pi*(nuc+df);   %angular frequency rad/s
k1x = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
k1y = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
w2  = 2*pi*(nuc-df);   %angular frequency rad/s
k2x = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m
k2y = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m

k2 = sqrt(k2x.^2 + k2y.^2); %radial angular wavenumber rad/m
k1 = sqrt(k1x.^2 + k1y.^2); %radial angular wavenumber rad/m

% Group velocity
vg = (w2-w1) / (k2-k1);

% Spatiotemporal grid 
xx = 0:0.02:2;
yy = 0:0.02:3;
tt = 0:0.02:10;
[x, y, t] = meshgrid(xx, yy, tt);

wave1 = cos(w1.*t-k1x.*x+k1y.*y);
wave2 = cos(w2.*t-k2x.*x+k2y.*y);

wv = wave1 + wave2;

%% Plotting of results

nr = 3;
nc = 4;
figure_handle = figure('Name', 'fig2');

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
imagesc(ax(1), yy, xx, wave1(:, :, 1), 'AlphaData', alpha_data);
ax(1).YLabel.String = 'x [m]';
ax(1).XLabel.String = 'y [m]';

plot(ax(1), yy(75), xx(50), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(1), yy(75), xx(50), 'kx', 'markersize', 8)

% Time course -- wave 1
plot(ax(2), tt, squeeze(wave1(75, 50, :)), 'k');
ax(2).XLim = [0 2];
ax(2).XLabel.String = 'time [s]';
ax(2).YLabel.String = 'w_1(x_0, y_0, t)';


% First frame -- wave 2
imagesc(ax(3), yy, xx, wave2(:, :, 1), 'AlphaData', alpha_data);
ax(3).YLabel.String = 'x [m]';
ax(3).XLabel.String = 'y [m]';

plot(ax(3), yy(75), xx(50), 'w+', 'markersize', 10)
plot(ax(3), yy(75), xx(50), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(3), yy(75), xx(50), 'kx', 'markersize', 8)

% Time course -- wave 2
plot(ax(4), tt, squeeze(wave2(75, 50, :)), 'k');
ax(4).XLim = [0 2];
ax(4).XLabel.String = 'time [s]';
ax(4).YLabel.String  = 'w_2(x_0, y_0, t)';

% Frames - wave sum
frames = [1 20 50 80];
for kk=1:length(frames)
    colormap(greenyellowred(256))
    imagesc(ax(kk+4), yy, xx, wv(:, :, frames(kk)), 'AlphaData', alpha_data);
end

plot(ax(5), yy, xx(50).*ones(length(yy), 1), 'k--')
plot(ax(9), yy, wv(:, 50, 1), 'k')
ax(9).XLabel.String = 'y [m]';
ax(9).YLabel.String = 'w(x_0, y, t_0) ';

% Markers
plot(ax(10), tt, squeeze(wv(75, 50, :)), 'k')
plot(ax(10), tt(frames(2:end)), squeeze(wv(75, 50, frames(2:end))), 'r.', 'markersize', 20)
ax(10).XLim = [0 5];
xlabel('time [s]')
ylabel('w(x_0, y_0, t) ')


plot(ax(6), yy(75), xx(50), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(6), yy(75), xx(50), 'kx', 'markersize', 8)

plot(ax(7), yy(75), xx(50), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(7), yy(75), xx(50), 'kx', 'markersize', 8)

plot(ax(8), yy(75), xx(50), 'wo', 'markersize', 8, 'markeredgecolor', 'k', 'markerfacecolor', 'w')
plot(ax(8), yy(75), xx(50), 'kx', 'markersize', 8)

%% Figure 3


figure3_handle = figure('Name', 'fig3');
nr = 4;
nc = 1;

for kk=1:4
   ax(kk) = subplot(nr, nc, kk, 'Parent', figure3_handle);
   hold(ax(kk), 'on')
end

%%
fl1 = 42;
frames = [1 5 10 15];

for kk=1:4
    data = squeeze(wv(:, 50, frames(kk)));
    [up1,lo1] = envelope(data, fl1,'analytic');
    plot(ax(kk), yy, data, 'k')
    plot(ax(kk), yy, up1, 'r')
    plot(ax(kk), yy, lo1, 'g')

end


%%
y = hilbert(wv);
env = abs(y);
%%
colormap(winter)
for tt =1:length(time)
%imagesc(env(:, :, tt))
imagesc(0:0.02:3, 0:0.02:2, wv(:, :, tt))
%imagesc(wave2(:, :, tt))
xlim([1 2])
ylim([0.5 1.5])

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

y = hilbert(wv);
env = abs(y);

plot(unwrap(angle(hilbert(squeeze(real(y(50,50,:)))))))


fl1 = 30;
[up1,lo1] = envelope(squeeze(wv(50,50,:)), fl1,'analytic');


