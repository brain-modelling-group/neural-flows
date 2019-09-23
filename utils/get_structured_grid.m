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
%        get_grid_limits()
%
% USAGE:
%{     
  
%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer February 2019



[min_x, min_y, min_z, max_x, max_y, max_z, ~] = get_grid_limits(points_xyz, hx, hy, hz);

    
% Create the grid -- THIS IS THE PROBLEM WITH SPACING
xx = min_x:hx:max_x;
yy = min_y:hy:max_y;
zz = min_z:hz:max_z;
    
[X, Y, Z] = meshgrid(xx, yy, zz);
grid_size = size(X);
 
end % function get_structured_grid() 
    