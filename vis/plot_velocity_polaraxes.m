function [figure_handle] = plot_velocity_polaraxes(vx, vy, vz, scaling_factor)

% vx, vy, vz, 1D arrays of size (1 x tpts)


if nargin < 4
    scaling_factor = 1;
end

% Fixed axes
x_angle = 0;
y_angle = 30;
z_angle = 90;

% Build angle vectors
%x
theta_x = zeros(1, length(vx));
theta_x(sign(vx) >= 0) = x_angle;
theta_x(sign(vy) < 0) = x_angle+180;
theta_x = [theta_x; theta_x];
%y
theta_y = zeros(1, length(vy));
theta_y(sign(vy) >= 0) = y_angle;
theta_y(sign(vy) < 0) = y_angle+180;
theta_y = [theta_y; theta_y];
%z
theta_z = zeros(1, length(vz));
theta_z(sign(vz) >= 0) = z_angle;
theta_z(sign(vz) < 0) = z_angle+180;
theta_z = [theta_z; theta_z];
% Make data vectors
data_x = [zeros(size(vx));abs(vx./scaling_factor)];
data_y = [zeros(size(vy));abs(vy./scaling_factor)];
data_z = [zeros(size(vz));abs(vz./scaling_factor)];

% Get some info for
mxx = max(data_x(:));
mxy = max(data_y(:));
mxz = max(data_z(:));
mxv = max([mxx, mxy, mxz]);

% Figure
figure_handle = figure;
pax = polaraxes('Parent', figure_handle);
hold(pax, 'on')

% Radius properties
rticks = linspace(0, mxv, 5);

for ii=1:length(rticks) 
    rticks_label{ii} = num2str(rticks(ii));
end
pax.RTick = rticks;
pax.RTickLabel = rticks_label;
pax.RLim = [0 mxv];
pax.RAxisLocation = 150;

% Theta axes
pax.ThetaTick =  [0 30 90 180 210 270];
pax.ThetaTickLabel = {'vx', 'vy', 'vz', '-vx', '-vy', '-vz'};
% Positive axes
axx = polarplot([0 0], [0 1.2*mxv], 'color', [0.75 0.75 0.75], 'linewidth', 3);
axy = polarplot([y_angle y_angle]*pi/180, [0 1.2*mxv], 'color', [0.75 0.75 0.75], 'linewidth', 3);
axz = polarplot([z_angle z_angle]*pi/180, [0 1.2*mxv], 'color', [0.75 0.75 0.75], 'linewidth', 3);
% Negative axes
ax_x = polarplot([180 180]*pi/180, [0 1.2*mxv], 'color', [0.75 0.75 0.75], 'linewidth', 3, 'linestyle', ':');
ax_y = polarplot([210 210]*pi/180, [0 1.2*mxv], 'color', [0.75 0.75 0.75], 'linewidth', 3, 'linestyle', ':');
ax_z = polarplot([270 270]*pi/180, [0 1.2*mxv], 'color', [0.75 0.75 0.75], 'linewidth', 3, 'linestyle', ':');

tt = 1;
red   = [228,26,28]./255;
green = [77,175,74]./255;
blue  = [55,126,184]./255;

hx = polarplot(pax, theta_x(:, tt)*pi/180, data_x(:, tt), 'color', red, 'linewidth', 2);
hy = polarplot(pax, theta_y(:, tt)*pi/180, data_y(:, tt), 'color', green, 'linewidth', 2);
hz = polarplot(pax, theta_z(:, tt)*pi/180, data_z(:, tt), 'color', blue, 'linewidth', 2);


for tt=1:size(vx, 2)
    hx.RData      = data_x(:, tt);
    hx.ThetaData  = theta_x(:, tt)*pi/180;
    hy.RData      = data_y(:, tt);
    hy.ThetaData  = theta_y(:, tt)*pi/180;
    hz.RData      = data_z(:, tt);
    hz.ThetaData  = theta_z(:, tt)*pi/180;
    drawnow
    pause(0.2)
    %export_fig(sprintf( './frame_%03d.png', tt ), '-r150', '-nocrop', figure_handle)
end

end % plot_velocity_polaraxes()
