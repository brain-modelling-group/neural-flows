function [wave3d, time] = generate_wave3d_spiral_scattered(locs, varargin)
% Generates a spiral wave in 3D space+time. The rotation occurs on the XY-plane. 
% The position of the centre of rotation (the tip) - on xy - changes with 
% depth z.
% 
%  ARGUMENTS:
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

tmp = strcmpi(varargin,'velocity'); 
if any(tmp)
    vel = varargin{find(tmp)+1}; 
else
    ux = 2;
    uy = 2;
    vel = [ux uy];
end

tmp = strcmpi(varargin,'tip_centre'); % min value in the grid along each axis
if any(tmp)
    tip_centre = varargin{find(tmp)+1};
    tip_a = tip_centre(1);
    tip_b = tip_centre(2);
else
    tip_a = 0;
    tip_b = 0;
end

tmp = strcmpi(varargin,'visual_debugging');
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else
    plot_stuff = true;
end


% Get limits of grid without actually calculating the grid arrays.
[min_x_val, min_y_val, min_z_val, max_x_val, max_y_val, max_z_val, ~] = get_grid_limits(locs, hxyz, hxyz, hxyz);


% generate a spiral wave in a regular grid cause it's easier
[temp_wave3d, X, Y, Z, time] = generate_spiralwave3d_grid('hxyz', hxyz, 'ht', ht, ...
                            'velocity', vel, ...
                            'tip_centre', [tip_a, tip_b], ...
                            'filament', 'line', 'visual_debugging', false, ...
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

if plot_stuff
    plot_sphereanim(wave3d, locs, time);
end
   

end % end generate_spiralwave3d_grid()
