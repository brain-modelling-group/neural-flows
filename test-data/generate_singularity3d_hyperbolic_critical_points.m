%function generate_singularity3d_hyperbolic_critical_points(varargin)


% Sink in 3D
x = -1:2^-4:1;
y = -1:2^-4:1;
z = -1:2^-4:1;

 [X, Y, Z] = meshgrid(x, y, z);
%% Sink
% U = -X;
% V = -Y;
% W = -Z;
% 
%% Source in 3D
% U = X;
% V = Y;
% W = Z;

%% Saddle-source (2-out, 1-in)
%TH = atan2(Y, X);
%R = sqrt(X.^2+Y.^2);
%U = R.* cos(TH);
%V = R.* sin(TH);
%W = -Z;

%% Saddle-sink (1-out, 2-in)
%TH = atan2(Y, X);
%R = sqrt(X.^2+Y.^2);
%U = - R.* cos(TH);
%V = - R.* sin(TH);
%W = Z;

%% Spiral sink
U =  Y-X;
V = -X-Y;
W = -Z; %zeros(size(Z));
W(isnan(W)) = 0;

%% Spiral source
a = 0.2;
b = 0.5;
U =  a*Y-(a.*abs(z)).*X;
V = -a*X-(a.*abs(z)).*Y;
W = -((b*Z)); %zeros(size(Z));
W(isnan(W)) = 0;

U = -U;
V = -V;
UV = sqrt(U.^2 + V.^2);
U = U./UV;
V = V./UV;
U(isnan(U)) = 0;
V(isnan(V)) = 0;
W = -W;

%% Spiral saddle - 2-out 1-in

U = U;
V = V;
W = -W;

%% Spiral saddle 1-out 2-in

U = -U;
V = -V;
W = W;

%%

fig_sing3d = figure('Name', 'nflows-singularity3d_hyperbolic-cp');
fig_sing3d.Color = [1, 1, 1];
ax = subplot(1, 1, 1, 'Parent', fig_sing3d);
hold(ax, 'on')
quiv_handle = quiver3(X, Y, Z, U, V, W);
quiv_handle.Color = [0.2 0.2 0.2 0.01];
quiv_handle.LineWidth = 0.5;
plot3(ax, [-1 1], [0 0], [0 0], 'r', 'linewidth', 1.5)
plot3(ax, [0 0], [-1 1], [0 0], 'g', 'linewidth', 1.5)
plot3(ax, [0 0], [0 0], [-1 1], 'b', 'linewidth', 1.5)
ax.XLim = [-1 1];
ax.YLim = [-1 1];
ax.ZLim = [-1 1];

ax.XLabel.String = 'x [mm]';
ax.YLabel.String = 'y [mm]';
ax.ZLabel.String = 'z [mm]';

%% Spiral source
h1=streamline(X, Y, Z, U, V, W, 0.0, 0.01, 0.01);
h2=streamline(X, Y, Z, U, V, W, 0.0, 0.01, -0.01);

%% Spiral Saddle 2-out(uy, ux), 1-in (uz)
h1=streamline(X, Y, Z, U, V, W, 0.01, 0.01, 0.5);
h2=streamline(X, Y, Z, U, V, W, 0.01, 0.01, -0.5);

%% Spiral Saddle 1-out(uz), 2-in (ux,uy)
h1=streamline(X, Y, Z, U, V, W, 0.5, -0.5, 0.05);
h2=streamline(X, Y, Z, U, V, W, -0.5, -0.5, -0.05);
%%
set(h1,'Color','red');
set(h2,'Color','blue');

view(3);

%   
 %options.stream_length_steps=21;
 %options.curved_arrow = 1;
 %options.start_points_mode = 'random-sparse';
% 
 %draw_stream_arrow(X(:, :, 16), squeeze(Z(:, 16, :)), V(:, :, 16), squeeze(W(:, 16, :)), options)


%end