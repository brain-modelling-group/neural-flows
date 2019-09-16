function [X, Y, Z, grid_size] = get_structured_grid(points_xyz, hx, hy, hz)
% This function sgenreates a structured grid using meshgrid, from a
% collection of scatterd points/locationss in 3D space.

% Get limits for the structured grid if people did not give those
% Author: Paula Sanz-Leon, QIMR February 2019

% Human-readable labels for indexing dimensions of 4D arrays
x_dim = 1;
y_dim = 2;
z_dim = 3;

% Round up to the nearest integer, using ceil avoids errors in the interpolated data.    
int_locs = ceil(abs(points_xyz)).*sign(points_xyz);

% Minima 
min_x = min(int_locs(:, x_dim));
min_y = min(int_locs(:, y_dim));
min_z = min(int_locs(:, z_dim));  

% Maxima
max_x = max(int_locs(:, x_dim));
max_y = max(int_locs(:, y_dim));
max_z = max(int_locs(:, z_dim));
    
% Create the grid -- THIS IS THE PROBLEM WITH SPACING
xx = min_x:hx:max_x;
yy = min_y:hy:max_y;
zz = min_z:hz:max_z;
    
[X, Y, Z] = meshgrid(xx, yy, zz);
grid_size = size(X);
 
end % function get_structured_grid() 
    