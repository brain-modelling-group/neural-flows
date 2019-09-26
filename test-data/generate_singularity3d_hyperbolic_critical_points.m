%function generate_singularity3d_hyperbolic_critical_points(varargin)


% Sink in 3D
x = -1:2^-4:1;
y = -1:2^-4:1;
z = -1:2^-4:1;

 [X, Y, Z] = meshgrid(x, y, z);
% U = -X;
% V = -Y;
% W = -Z;
% 
% % Source in 3D
% U = X;
% V = Y;
% W = Z;
% 
% % Spiral sink
% U = Y-X;
% V = -X-Y;
% W = -(1/sign(Z).*(Z.^2)); %zeros(size(Z));
% W(isnan(W)) = 0;
 
 
% Spiral source
U = 0.01*Y-0.0*X;
V = -0.01*X-(0.01.*abs(z)).*Y;
W = -((0.5*Z)); %zeros(size(Z));
W(isnan(W)) = 0;

U = -U;
V = -V;
UV = sqrt(U.^2 + V.^2);
%U = U./UV;
%V = V./UV;
U(isnan(U)) = 0;
V(isnan(V)) = 0;
W = -W;
 

% 
% xlim([-0.25 0.25])
% ylim([-0.25 0.25])
% zlim([-0.25 0.25])
% 
% xlabel('x [mm]')
% ylabel('y [mm]')
% zlabel('z [mm]')
% 
% 
% % box
% plot3([-0.25 -0.25], [-0.25 -0.25], [-0.25 0.25], 'k--')
% plot3([-0.25 0.25], [-0.25 -0.25], [0.25 0.25], 'k--')
% plot3([-0.25 -0.25], [-0.25 0.25], [0.25 0.25], 'k--')
% 
% % Source
% U = X;
% V = Y;
% W = Z;
% 
% % Saddle-source (2-out, 1-in)
% TH = atan2(Y, X);
% R = sqrt(X.^2+Y.^2);
% U = R.* cos(TH);
% V = R.* sin(TH);
% W = -Z;
% 
% % Saddle-sink (1-out, 2-in)
% TH = atan2(Y, X);
% R = sqrt(X.^2+Y.^2);
% U = -R.* cos(TH);
% V = -R.* sin(TH);
% W = Z;
% unorm = sqrt(U.^2+V.^2+W.^2);




fig_sing3d = figure('Name', 'nflows-singularity3d_hyperbolic-cp');
fig_sing3d.Color = [1, 1, 1];
ax = subplot(1, 1, 1, 'Parent', fig_sing3d);
hold(ax, 'on')
quiv_handle = quiver3(X, Y, Z, U, V, W);
quiv_handle.Color = [0.2 0.2 0.2];
quiv_handle.LineWidth = 1.5;
plot3(ax, [-1 1], [0 0], [0 0], 'r', 'linewidth', 1.5)
plot3(ax, [0 0], [-1 1], [0 0], 'g', 'linewidth', 1.5)
plot3(ax, [0 0], [0 0], [-1 1], 'b', 'linewidth', 1.5)
ax.XLim = [-1 1];
ax.YLim = [-1 1];
ax.ZLim = [-1 1];

ax.XLabel.String = 'x [mm]';
ax.YLabel.String = 'y [mm]';
ax.ZLabel.String = 'z [mm]';

%h=streamline(X, Y, Z, U, V, W, -0.5, -0.5, 2);
h1=streamline(X, Y, Z, U, V, W, 0.0, 0.01, 0.05);
h2=streamline(X, Y, Z, U, V, W, 0.0, 0.01, -0.05);

%h=streamline(X, Y, Z, U, V, W, -0.01, 0.01, 0.05);

set(h1,'Color','red');
set(h2,'Color','blue');

view(3);

% 
 options.stream_length_steps=21;
 options.curved_arrow = 1;
 options.start_points_mode = 'random-sparse';
% 
 draw_stream_arrow(X(:, :, 16), Y(:, :, 16), U(:, :, 16), V(:, :, 16), options)


%end