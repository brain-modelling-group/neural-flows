function [wave3d] = generate_spiralwave3d_grid(varargin)
% Generates a rotating wave in 3D space+time. The rotation occurs on the XY-plane. 
% The position of the centre of rotation (the tip) - on xy - changes with 
% depth z.
% 
%  ARGUMENTS:
%        ht         -- time step in seconds
%        hx         -- 
%        T          -- maximum time in seconds 
%        frequency  -- frequency in [Hz]
%        lambda     -- radial wavelength in [m].
%        direction  -- and integer +1 or -1, defines the direction of rotation. 
%
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

hx = opts.hx;
hy = opts.hy;
hz = opts.hz;
ht = opts.ht;
max_val = 16;
max_val_time = 8;

xdim = 1;
ydim = 2;
zdim = 3;

time = 0:ht:max_val_time;
x = -max_val:hx:max_val;
y = -max_val:hy:max_val;
z = -max_val:hz:max_val;

[XX, YY, TT] = meshgrid(x, y, time);

% Wave parameter - hardcoded
freq =      0.1; % Hz
wavelength = 16; % m
gausswidth = 20; 

amp = 1.0;
tip_centre = [0, 0]; % in metres
vel = [0.00 0.00]; % shift the tip location


% Convert parameters into more useful quantities
% Angular frequency
w = 2*pi*freq;
% Wavenumber
k = 2*pi/wavelength;
% Gaussian width parameter
if exist('gausswidth', 'var') && isscalar(gausswidth) && gausswidth~=0
    c = gausswidth / (2*sqrt(2*log(2)));
end

% Set velocity as zero by default if not specified
if ~exist('vel', 'var') || isempty(vel)
    ux = 5;
    uy = 5;
    uz = 0;
    vel = [ux uy uz];
end


% Spiral wave on a 2D plane
% wave2d = exp(1i*(-w*TT + angle(XX-tip_centre(xdim)-vel(xdim)*TT + 1i*(YY-tip_centre(ydim)-vel(ydim)*TT)) - ...
%                   k*sqrt((XX-tip_centre(xdim)-vel(xdim)*TT).^2 + (YY-tip_centre(ydim)-vel(ydim)*TT).^2)));


%% Rotating spiral tip
tip = z;
radius = abs(z).^2/5; 
tip_y = radius.*sin(tip);
tip_x = radius.*cos(tip);

wave3d(length(time), length(x), length(y), length(z)) = 0;

for kk=1:length(tip)
            
       wave2d = exp(1i*(-w*TT + angle(XX-tip_x(kk)-vel(xdim)*TT + 1i*(YY-tip_y(kk)-vel(ydim)*TT)) - ...
                  k*sqrt((XX-tip_x(kk)-vel(xdim)*TT).^2 + (YY-tip_y(kk)-vel(ydim)*TT).^2)));
       wave2d(wave2d~=0) = amp * wave2d(wave2d~=0) ./ abs(wave2d(wave2d~=0));
       
       gaussian = @(c, loc, kk) exp(-1/(2*c^2) * (((XX(:, :, 1)-tip_x(kk)).^2 + ...
                                                   (YY(:, :, 1)-tip_y(kk)).^2)));
       wave2d = spatiotemporal_masks(wave2d, gaussian(c, tip_centre, kk));
       
       % Ensure that the maximum amplitude is still AMP
       wave2d = wave2d / max(abs(wave2d(:))) * amp;

       wave2d = permute(wave2d, [3 1 2]);       
       wave3d(:, :, :, kk) = real(wave2d); 
    
    
end


end % end generate_spiralwave3d_grid()
