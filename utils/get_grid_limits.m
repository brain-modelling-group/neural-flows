function [min_x, min_y, min_z, max_x, max_y, max_z, int_locs] = get_grid_limits(points_xyz, hx, hy, hz)
% basic function that I've been using again and again 
% TODO - document etc

% Human-readable labels for indexing dimensions of 3D arrays
x_dim = 1;
y_dim = 2;
z_dim = 3;

% Round up to the nearest integer, using ceil avoids errors in the interpolated data.    
int_locs = ceil(abs(points_xyz)).*sign(points_xyz);

% Minima 
min_x = min(int_locs(:, x_dim)) - 2*hx;
min_y = min(int_locs(:, y_dim)) - 2*hy;
min_z = min(int_locs(:, z_dim)) - 2*hz;  

% Maxima
max_x = max(int_locs(:, x_dim)) + 2*hx;
max_y = max(int_locs(:, y_dim)) + 2*hy;
max_z = max(int_locs(:, z_dim)) + 2*hz;

end % get_get_grid_boundaries()