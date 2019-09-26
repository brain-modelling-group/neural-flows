function generate_singularity3d_hyperbolic_critical_points()


% Sink in 3D
[X, Y, Z] = meshgrid(-0.25:2^-4:0.25);
U = -X;
V = -Y;
W = -Z;
quiver3(X, Y, Z, U, V, W)

plot3([-1 1], [0 0], [0 0], 'r')
plot3([0 0], [-1 1], [0 0], 'g')
plot3([0 0], [0 0], [-1 1], 'b')

xlim([-0.25 0.25])
ylim([-0.25 0.25])
zlim([-0.25 0.25])

xlabel('x [mm]')
ylabel('y [mm]')
zlabel('z [mm]')


% box
plot3([-0.25 -0.25], [-0.25 -0.25], [-0.25 0.25], 'k--')
plot3([-0.25 0.25], [-0.25 -0.25], [0.25 0.25], 'k--')
plot3([-0.25 -0.25], [-0.25 0.25], [0.25 0.25], 'k--')

% Source
U = X;
V = Y;
W = Z;

% Saddle-source (2-out, 1-in)
TH = atan2(Y, X);
R = sqrt(X.^2+Y.^2);
U = R.* cos(TH);
V = R.* sin(TH);
W = -Z;

% Saddle-sink (1-out, 2-in)
TH = atan2(Y, X);
R = sqrt(X.^2+Y.^2);
U = -R.* cos(TH);
V = -R.* sin(TH);
W = Z;
unorm = sqrt(U.^2+V.^2+W.^2);


quiver3(X, Y, Z, U, V, W)
xlabel('x')
ylabel('y')
zlabel('z')

end