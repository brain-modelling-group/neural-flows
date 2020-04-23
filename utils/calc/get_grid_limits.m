function [min_x, min_y, min_z, max_x, max_y, max_z, int_locs] = get_grid_limits(points_xyz, hx, hy, hz, lim_type)
% basic function that I've been using again and again 
% TODO - document etc
if nargin < 5
    lim_type = 'ceil';
end

% Human-readable labels for indexing dimensions of 3D arrays
x_dim = 1;
y_dim = 2;
z_dim = 3;

if strcmp(lim_type, 'ceil')
    % Round up to the nearest integer, using ceil avoids errors in the interpolated data.    
    int_locs = ceil(abs(points_xyz)).*sign(points_xyz);
    border_factor = 2;
else
    int_locs = points_xyz;
    border_factor = 3;
end

% Minima 
min_x = min(int_locs(:, x_dim)) - border_factor*hx;
min_y = min(int_locs(:, y_dim)) - border_factor*hy;
min_z = min(int_locs(:, z_dim)) - border_factor*hz;  

% Maxima
max_x = max(int_locs(:, x_dim)) + border_factor*hx;
max_y = max(int_locs(:, y_dim)) + border_factor*hy;
max_z = max(int_locs(:, z_dim)) + border_factor*hz;

end % get_get_grid_boundaries()