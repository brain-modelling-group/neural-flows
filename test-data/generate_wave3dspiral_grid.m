function [wave3d, X, Y, Z, time] = generate_spiralwave3d_grid(varargin)
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


%Beahviour of the spiral tip/centre or rotiation along z-axis form the
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

wave3d(length(time), length(y), length(x), length(z)) = 0;

for kk=1:length(tip)
            
       wave2d = exp(1i*(-w*TT + angle(XX-tip_x(kk)-vel(xdim)*TT + 1i*(YY-tip_y(kk)-vel(ydim)*TT)) - ...
                  k*sqrt((XX-tip_x(kk)-vel(xdim)*TT).^2 + (YY-tip_y(kk)-vel(ydim)*TT).^2)));
       wave2d(wave2d~=0) = amp * wave2d(wave2d~=0) ./ abs(wave2d(wave2d~=0));
       
       gaussian = @(c, loc, kk) exp(-1/(2*c^2) * (((XX(:, :, 1)-tip_x(kk)).^2 + ...
                                                   (YY(:, :, 1)-tip_y(kk)).^2)));
       wave2d = apply_spatiotemporal_mask(wave2d, gaussian(c, tip_centre, kk));
       
       % Ensure that the maximum amplitude is still AMP
       wave2d = wave2d / max(abs(wave2d(:))) * amp;

       wave2d = permute(wave2d, [3 1 2]);       
       wave3d(:, :, :, kk) = real(wave2d); 
    
end

[X, Y, Z] = meshgrid(x, y, z);

min_val = min(wave3d(:));
max_val = max(wave3d(:));


if plot_stuff
    fig_spiral = figure('Name', 'nflows-spiralwave3d-space-time');
    
    for tt=1:length(time)
        these_axes = subplot(1, 1, 1, 'Parent', fig_spiral);
        these_axes.XLabel.String = 'X';
        these_axes.YLabel.String = 'Y';
        these_axes.ZLabel.String = 'Z';
        cla;
        colormap(bluegred(256))
        pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)), 'axes', these_axes); 
        caxis([min_val  max_val]);pause(0.5); 
    end
end     
    

end % end generate_spiralwave3d_grid()
