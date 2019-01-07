% This script has the code to generate a meandering spiral in a sqaure 2D
% domain. We generate the flow directly.

% Time
t = 1/100:1/100:2;
% Envelope of the amplitude
env_exp = exp(-0.5*t)+1;


% Centroid of the spiral
xo = env_exp.*sin(10*t);
yo = env_exp.*cos(10*t);

% Standardise range so the centroid coordinates are always around the
% centre of [0 1]
xo = standardise_range(xo,  [0.25, 0.75]);
yo = standardise_range(yo,  [0.25, 0.75]);

% Plot the trajectory of the centroid
plot3(t, xo, yo)
xlabel('Time')
ylabel('x-coord')
zlabel('y-coord')


% Generate the flow
V = zeros(64, 64, 2, length(t));

rotating_centre = 1;
node_centre     = 0;



for tt=1:length(t)
   centroid = [xo(tt); yo(tt)];
   V(:, :, :, tt) = generate_flow_2d_rectangular(centroid, rotating_centre, node_centre);
   plot_velocity_field(V(:, :, :, tt))
   drawnow
end

