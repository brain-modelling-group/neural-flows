function [wave3d, time] = generate_wave3d_travelling_biharmonic_scattered(locs, varargin)
% Generates a plane "travelling" wave moving along one of the three main 
% orthogonal axes of Euclidean space. The data is generating as a linear 
% function of space (x, Y, or Z), so in a sense is a like sinusoidal plane
% wave of infinite (temporal) period. However, the wave3d array is a 2D
% array 
% ARGUMENTS: 
%           locs      -- a 2D array of size [node/regions, 3] with the points 
%                        in 3d used to sample the solid travelling 3d wave.
%                       
% (VAR)ARGUMENTS:
%           direction -- a string with the desired wave propagation direction.
%                        Available: {'x', 'y'}.
%                        Default: {'x'}.
%           step     -- a scalar with the space step size to generate the grid
%           visual_debugging -- a boolean to determine whther to plot
%                       figures or not.
%                       Default: {true}.
% 
% OUTPUT:
%          wave3d   -- a 2D array of size [num_regions, timepoints].
% REQUIRES: 
%          pcolor3() for visual debugging
%edit
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, August 2019
%
% USAGE:
%{



%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: generalise set different propogation velocities.
% TODO: generalise for travelling waves along the other dimensions.


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

tmp = strcmpi(varargin,'lim_type'); 
if any(tmp)
    lim_type = varargin{find(tmp)+1}; 
else
    lim_type = 'none';
end

tmp = strcmpi(varargin,'visual_debugging'); % note really a velocity but an integer scaling for circshift
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else
    plot_stuff = true;
end


[X, Y, Z, ~] = get_structured_grid(locs, hxyz, hxyz, hxyz, lim_type);

[wave_temp, time] = genereate_fake_wave(X, Y, Z, ht);

% Preallocate memory
wave3d(length(time), size(locs, 1)) = 0;

for tt=1:length(time)
    B = wave_temp(:, :, :, tt);
    data_interpolant = scatteredInterpolant(X(:), Y(:), Z(:), B(:), 'linear', 'nearest');
    wave3d(tt, :) = data_interpolant(locs(:, 1), locs(:, 2), locs(:, 3));
end

if plot_stuff
    plot_sphereanim(wave3d, locs*1000, time);
end


end % function generate_wave3d_travelling_biharmonic_scattered()

function [wave_temp, time] = genereate_fake_wave(X, Y, Z, ht)

% Example: phase velocity slower than group velocity and in opposite
% direction
% Wave parameters
fc  = 4;    % Hz
nuc = 2;    % 1/m
df  = 0.25; % Hz
dnu = 0.25; % 1/m

w1  = 2*pi*(fc+df);   %angular frequency rad/s
k1x = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
k1y = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
w2  = 2*pi*(fc-df);   %angular frequency rad/s
k2x = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m
k2y = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m

%k2 = sqrt(k2x.^2 + k2y.^2); %radial angular wavenumber rad/m
%k1 = sqrt(k1x.^2 + k1y.^2); %radial angular wavenumber rad/m

% Group velocity
%dw = (w2-w1);
%dk = (k2-k1);

% Spatiotemporal grid 
yy = Y(:, 1, 1);
xx = X(1, :, 1);
zz = Z(1,1,:);

% NOTE: hardcoded size 
time = 0:ht:4; % in seconds

[x, y, t] = meshgrid(xx, yy, time);

wave1 = cos(w1.*t-k1x.*y+k1y.*x);
wave2 = cos(w2.*t-k2x.*y+k2y.*x);

% Because imagscale flips the array
%wave1 = wave1;
%wave2 = wave2;
wv = wave1 + wave2;

wv = reshape(wv, size(wv, 1), size(wv, 2), 1, size(wv, 3));

z_steps = length(zz);

wave_temp = wv(:, :, ones(1, 1, z_steps, 1), :);

end