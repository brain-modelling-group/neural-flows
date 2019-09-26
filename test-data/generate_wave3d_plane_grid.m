function [wave3d, X, Y, Z, time] = generate_wave3d_plane_grid(varargin)
% Generates plane harmonic waves in 3D physical space +
% time. The size of space and time vector are hardcoded as these waves are
% intended for fast debugging and testing purposes. 
% The wave numbers and frequency are also hardcoded.
%
% ARGUMENTS:
%           direction -- a string with the desired wave propagation direction.
%                        Available: {'x', 'y', 'z', 'radial', 'any', 'all'}.
%                        Default: {'x'}.
% OUTPUT:
%           wave3d   -- a 4D array of size [21, 21, 21, 50]. The first 
%                       three dimensions are space and the last one is time.
% REQUIRES: 
%         pcolor3() for visual debugging
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, June 2019
%
% USAGE:
%{
    generate_planewave_3d_grid('x');

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% NOTE: hardcoded stuff size

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

tmp = strcmpi(varargin,'visual_debugging'); % note really a velocity but an integer scaling for circshift
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else 
    plot_stuff = true;
end


max_val_time = 150;
time = 0:ht:max_val_time;
x = min_val_x:hxyz:max_val_x;
y = min_val_y:hxyz:max_val_y;
z = min_val_z:hxyz:max_val_z;


len_x = length(x);
len_y = length(y);
len_z = length(z);

[X, Y, Z] = meshgrid(x, y, z); % in metres
R = sqrt(X.^2+Y.^2+Z.^2);

% NOTE: hardcoded size 
omega = 0.2;%2*pi*0.05; % in rad sec^-1

% NOTE: Hardocoded frequencies
kx = 0.1; % in m^-1
ky = 0.1; % in m^-1
kz = 0.1; % in m^-1
kr = sqrt(kx.^2 + ky.^2 + kz.*2);

%NOTE: estimation of wave propagation speed, should be output parameter if
% we allow for input temp and spatial freqs.
%c = omega ./ kr;

% Amplitude of the wave.
% NOTE: can be turned into a parameter
A = 1;
% Preallocate memory
wave3d(length(time), len_y, len_x, len_z) = 0;

if nargin < 1
    direction = 'x';
end

switch direction
    case 'x'
        ky = 0;
        kz = 0;
        kr = 0;
        
    case 'y'
        kx = 0;
        kz = 0;
        kr = 0;
    case 'z'
        kx = 0;
        ky = 0;
        kr = 0;
    case 'xy'
        kz = 0;
        kr = 0;
    case 'radial'
        kx = 0;
        ky = 0;
        kz = 0;
        
    case 'all'
        % I wonder about my sanity and state of mind when I find myself doing
        % recursive function calls in matlab.
        generate_planewave3d_grid('x');
        generate_planewave3d_grid('y');
        generate_planewave3d_grid('z');
        generate_planewave3d_grid('radial');
        generate_planewave3d_grid('blah');
        return
        
    otherwise
        kr = 0;
end

omega_sign = 1;
% Generate the wave
for tt=1:length(time)
    % The - sign of omega * t means the direction of propagation will be
    % along the + direction of the corresponding axes.
    wave3d(tt, :, :, :) = A.* exp(1i.*(kx.*X + ky.*Y + kz.*Z + kr.*R - omega_sign.*omega.*time(tt)));
end

% Save only the real part
wave3d = real(wave3d);

if plot_stuff 
    % Visual debugging of the first time point
    % TODO: generate a movie, perhaps of projections onto a 2d plane.
    figure('Name', 'nflows-planewave3d-space');
    tt = 1;
    %colormap(bluegred(256))
    pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)));
    colormap(bluegred(256))

    xlabel('X')
    zlabel('Z')

    figure('Name', 'nflows-planewave3d-time')
    plot(time, squeeze(wave3d(:, 11,12, 12)));
    xlabel('time')
    ylabel('p(x, y, z)')
end
end % function generate_planewave3d_structured()

