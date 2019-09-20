function [wave3d] = generate_spiralwave3d_grid(ht, T, frequency, hx, lambda, direction, varargin)
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
max_val = 32;
max_val_time = 10;

time = 0:ht:max_val_time;
x = -max_val:hx:max_val;
y = -max_val:hy:max_val;
z = -max_val:hz:max_val;

[XX, YY, TT] = meshgrid(x, y, time);


freq =      0.1; % Hz
wavelength = 20; % m
gausswidth = 20; % in ??


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
    vel = [-2 0];
end

% A source pattern is just a sink pattern with negative frequency

%if strcmp(sing_type, 'source')
    %sing_type = 'sink';
    w = -w;
%end

%[wave2d, ~, time] = generate_neuropatt_2d_waves(grid_size, wave_type, amp, freq, wavelength, tip_centre, vel, gaussWidth, opts);

% Spiral wave
wave2d = exp(1i*(-w*TT + angle(XX-tip_centre(1)-vel(1)*TT + 1i*(YY-tip_centre(2)-vel(2)*TT)) - ...
                  k*sqrt((XX-tip_centre(1)-vel(1)*TT).^2 + (YY-tip_centre(2)-vel(2)*TT).^2)));


%% Rotating spiral tip
tip = z;
tip_y = sin(tip);
tip_x = cos(tip);

for ii = 1:length(x)
    for jj = 1:length(x)
        for kk=1:length(x)
            
        % Spatial domain
        [X, Y, ~] = meshgrid(x-tip_x(kk), ...
                             y-tip_y(kk), ...
                             z);

        % Rotation plane is XY
        [TH, ~] = cart2pol(X,Y);

        wave3d(:, ii, jj, kk) = exp(1i.*(direction.*TH(ii,jj, kk)* ((2*pi)./lambda) -  2*pi*abs(frequency)*time));
        
        end
    end
    
end
wave3d = wave3d .* exp(1i .* phase_offset);  
wave3d = real(wave3d);


%% Apply amplitude mask
% Ensure that wave has equal amplitude everywhere
wave2d(wave2d~=0) = amp * wave2d(wave2d~=0) ./ abs(wave2d(wave2d~=0));

% Apply gaussian mask around centre location if specified
if exist('c', 'var')
    gaussian = @(c, loc) exp(-1/(2*c^2) * (((XX(:, :,1)-loc(1)).^2 + ...
        (YY(:, :, 1)-loc(2)).^2)));
    wave2d = spatiotemporal_masks(wave2d, gaussian(c, tip_centre));
end

% Ensure that the maximum amplitude is still AMP
wave2d = wave2d / max(abs(wave2d(:))) * amp;
end % end generate_spiralwave3d_grid()
