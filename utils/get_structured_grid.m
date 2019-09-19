function [X, Y, Z, grid_size] = get_structured_grid(points_xyz, hx, hy, hz)
% This function sgenreates a structured grid using meshgrid, from a
% collection of scatterd points/locationss in 3D space.
% 
% ARGUMENTS:
%   points_xyz -- a 2D array of size [num_regions/nodes/locations x 3]
%                               
%   hx         -- a scalar, desired space step size of the regular grid along x
%   hy         -- a scalar, desired space step size of the regular grid along y
%   hz         -- a scalar, desired space step size of the regular grid along z
%
% OUTPUTS:
%   X, Y, Z    -- 3D arrays of size [M, N, P] generated using meshgrid.
%   grid_size  -- vector with the size of the grid (ie [M, N, P]) 
%
% REQUIRES: 
%         None()
%
% USAGE:
%{     
  
%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
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
    
% Create the grid -- THIS IS THE PROBLEM WITH SPACING
xx = min_x:hx:max_x;
yy = min_y:hy:max_y;
zz = min_z:hz:max_z;
    
[X, Y, Z] = meshgrid(xx, yy, zz);
grid_size = size(X);
 
end % function get_structured_grid() 
    