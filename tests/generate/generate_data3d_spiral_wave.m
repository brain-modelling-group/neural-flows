function [data, X, Y, Z, time] = generate_data3d_spiral_wave(varargin)
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


tmp = strcmpi(varargin,'grid_type'); 
if any(tmp)
    grid_type = varargin{find(tmp)+1}; 
else
    grid_type = 'structured';
end


tmp = strcmpi(varargin,'visual_debugging');
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else
    plot_stuff = true;
end

tmp = strcmpi(varargin,'filament'); % filament type 
if any(tmp)
    filament = varargin{find(tmp)+1}; 
else
    filament = 'helix';
end

tmp = strcmpi(varargin,'max_val_space'); % max value in the grid along each axis
if any(tmp)
    max_xyz = varargin{find(tmp)+1};
    max_val_x  = max_xyz(1);
    max_val_y  = max_xyz(2);
    max_val_z  = max_xyz(3);
else
    max_val_x = 16;
    max_val_y = 16;
    max_val_z = 16;
end

tmp = strcmpi(varargin,'min_val_space'); % min value in the grid along each axis
if any(tmp)
    min_xyz = varargin{find(tmp)+1};
    min_val_x  = min_xyz(1);
    min_val_y  = min_xyz(2);
    min_val_z  = min_xyz(3);
else
    min_val_x = -16;
    min_val_y = -16;
    min_val_z = -16;
end

% For unstructured case
tmp = strcmpi(varargin,'locs'); 
if any(tmp)
    locs = varargin{find(tmp)+1}; 
else
    locs = [];
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

max_val_time = 8;   % in seconds / milliseconds

xdim = 1;
ydim = 2;

time = 0:ht:max_val_time;
x = min_val_x:hxyz:max_val_x;
y = min_val_y:hxyz:max_val_y;
z = min_val_z:hxyz:max_val_z;

[XX, YY, TT] = meshgrid(x, y, time);

% Wave parameter - hardcoded to get well behaved waves
freq =      0.1; % Hz
wavelength = (max_val_y-min_val_y)/2; % m
gausswidth = (max_val_y-min_val_y)/2;

amp = 1.0;
tip_centre = [0, 0]; % in metres

% Convert parameters into more useful quantities
% Angular frequency
w = 2*pi*freq;
% Wavenumber
k = 2*pi/wavelength;
% Gaussian width parameter
c = gausswidth / (2*sqrt(2*log(2)));

%Behaviour of the spiral tip/centre or rotiation along z-axis form the
%filament of a wave.

tip = z;
switch filament
    case 'helix'
        radius = 1;
        tip_y = radius.*sin(tip);
        tip_x = radius.*cos(tip);
    case 'cone'
        radius = abs(z).^2; 
        tip_y = radius.*sin(tip);
        tip_x = radius.*cos(tip);
    case 'line'
        tip_y = tip_a.*ones(size(z));
        tip_x = tip_b.*ones(size(z));    
end 

switch grid_type
  case {'structured'}
    data = get_structured_data();
  case {'unstructured'}
    data = get_unstructured_data();
  otherwise
    body
end


[X, Y, Z] = meshgrid(x, y, z);


if plot_stuff
    switch grid_type
    case {'structured'}
        fig_spiral = figure('Name', 'nflows-spiraldata-space-time');
        plot3d_pcolor3_movie(fig_spiral, X, Y, Z, data)
    case {'unstructured'}
        plot_sphereanim(data, locs, time);
    otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
    end
end     


function data = get_unstructured_data()
    % Get limits of grid without actually calculating the grid arrays.
    [min_x_val, min_y_val, ...
     min_z_val, max_x_val, ...
     max_y_val, max_z_val, ~] = get_grid_limits(locs, hxyz, hxyz, hxyz);

    % Generate a spiral wave in a regular grid cause it's easier
    [temp_data, XXX, YYY, ZZZ, t] = generate_data3d_spiral_wave('hxyz', hxyz, 'ht', ht, ...
                                                                'velocity', vel, ...
                                                                'tip_centre', [tip_a, tip_b], ...
                                                                'filament', filament, ...
                                                                'visual_debugging', false, ...
                                                                'min_val_space', [min_x_val, min_y_val, min_z_val], ...
                                                                'max_val_space', [max_x_val, max_y_val, max_z_val]);
                        
    data(length(t), size(locs, 1)) = 0;
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
                            
    for tt=1:length(t)
        B = temp_data(:, :, :, tt);
        data_interpolant = scatteredInterpolant(XXX(:), YYY(:), ZZZ(:), B(:), 'linear', 'none');
        data(tt, :) = data_interpolant(locs(:, x_dim), locs(:, y_dim), locs(:, z_dim));
        
    end  
end % function get_unstructured_data()


function data = get_structured_data()
    len_y = length(y);
    len_x = length(x);
    len_z = length(z);
    len_t = length(time);
    data(len_y, len_x, len_z, len_t) = 0;

    for kk=1:length(tip)   
           wave2d = exp(1i*(-w*TT + angle(XX-tip_x(kk)-vel(xdim)*TT + 1i*(YY-tip_y(kk)-vel(ydim)*TT)) - ...
                        k*sqrt((XX-tip_x(kk)-vel(xdim)*TT).^2 + (YY-tip_y(kk)-vel(ydim)*TT).^2)));
           wave2d(wave2d~=0) = amp * wave2d(wave2d~=0) ./ abs(wave2d(wave2d~=0));
           
           gaussian = @(c, loc, kk) exp(-1/(2*c^2) * (((XX(:, :, 1)-tip_x(kk)).^2 + ...
                                                       (YY(:, :, 1)-tip_y(kk)).^2)));
           wave2d = apply_spatiotemporal_mask(wave2d, gaussian(c, tip_centre, kk));
           
           % Ensure that the maximum amplitude is still AMP
           wave2d = wave2d / max(abs(wave2d(:))) * amp;
           wave2d = reshape(wave2d, len_y, len_x, 1, len_t);

             
           data(:, :, kk, :) = real(wave2d); 
    end
end % function get_structured_data()
    
end % function generate_data3d_spiral_wave()
