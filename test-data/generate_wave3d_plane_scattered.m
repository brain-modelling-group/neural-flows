function [wave3d, time] = generate_wave3d_plane_scattered(locs, varargin)
% Generates a spiral wave in 3D space+time. The rotation occurs on the XY-plane. 
% The position of the centre of rotation (the tip) - on xy - changes with 
% depth z.
% 
%  ARGUMENTS:
%        locs              --  locations in x y z
%        ht                -- time step in seconds (milliseconds)
%        hx                -- space step size in metres (millimetres)
%        visual_debugging  -- a boolean
%  OUTPUT:
%        data -- a 4D array of size [side_size, side_size, side_size, T/ht]; 
%                where side_size = 2*half_size - 1; 
%
%  REQUIRES:
%
%
%  AUTHOR:
%    Paula Sanz-Leon, QIMR, 2019
%
%
%  USAGE:
%{


%}

% TODO -- generalise to accept almost all harcoded values as parameters
% TODO -- check memory consumption, may get slow for high resolution
% domains.
% TODO -- update documentation

tmp = strcmpi(varargin,'direction'); 
if any(tmp)
    direction = varargin{find(tmp)+1}; 
else
    direction = 'x';
end

tmp = strcmpi(varargin,'hxyz'); 
if any(tmp)
    hxyz = varargin{find(tmp)+1}; 
else
    hxyz = 1;
end

tmp = strcmpi(varargin,'ht'); 
if any(tmp)
    ht = varargin{find(tmp)+1}; 
else
    ht = 1;
end


% Get limits of grid without actually calculating the grid arrays.
[min_x_val, min_y_val, min_z_val, max_x_val, max_y_val, max_z_val, ~] = get_grid_limits(locs, hxyz, hxyz, hxyz);


% generate a plane wave in a regular grid cause it's easier
[temp_wave3d, X, Y, Z, time] = generate_planewave3d_grid('hxyz', hxyz, 'ht', ht, ...
                            'direction', direction, ...
                            'visual_debugging', false, ...
                            'min_val_space', [min_x_val, min_y_val, min_z_val], ...
                            'max_val_space', [max_x_val, max_y_val, max_z_val]);

                        
wave3d(length(time), size(locs, 1)) = 0;

x_dim = 1;
y_dim = 2;
z_dim = 3;
                        
for tt=1:length(time)
    B = temp_wave3d(tt, :, :, :);
    data_interpolant = scatteredInterpolant(X(:), Y(:), Z(:), B(:), 'linear', 'none');
    wave3d(tt, :) = data_interpolant(locs(:, x_dim), locs(:, y_dim), locs(:, z_dim));
end

end % end generate_planewave3d_scattered()
