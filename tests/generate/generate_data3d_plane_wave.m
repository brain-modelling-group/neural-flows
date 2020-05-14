function [data, X, Y, Z, time] = generate_data3d_plane_wave(varargin)
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
%           wave3d   -- is actually a 4D array of size [21, 21, 21, 50]. The first 
%                       three dimensions are space and the last one is time.
% REQUIRES: 
%         pcolor3() for visual debugging
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, June 2019
%
% USAGE:
%{
    generate_wave3d_plane('direction', 'x');

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

tmp = strcmpi(varargin,'grid_type'); 
if any(tmp)
    grid_type = varargin{find(tmp)+1}; 
else
    grid_type = 'structured';
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

% For unstructured case
tmp = strcmpi(varargin,'locs'); 
if any(tmp)
    locs = varargin{find(tmp)+1}; 
else
    locs = [];
end

tmp = strcmpi(varargin,'max_val_space'); % max value in the grid along each axis
if any(tmp)
    max_xyz = varargin{find(tmp)+1};
    max_val_x  = max_xyz(1);
    max_val_y  = max_xyz(2);
    max_val_z  = max_xyz(3);
else
    max_val_x = 16;
    max_val_y = 18;
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
    min_val_y = -18;
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
k_x = 0.1; % in m^-1
k_y = 0.1; % in m^-1
k_z = 0.1; % in m^-1
k_r = sqrt(k_x.^2 + k_y.^2 + k_z.*2);

%NOTE: estimation of wave propagation speed, should be output parameter if
% we allow for input temp and spatial freqs.
%c = omega ./ kr;


if nargin < 1
    direction = 'x';
end

switch direction
    case 'y'
        k_x = 0;
        k_z = 0;
        k_r = 0;
        idx_expr = '(11:20, 12, 12, :)'; 
        
    case 'x'
        k_y = 0;
        k_z = 0;
        k_r = 0;
        idx_expr = '(12, 11:20, 12, :)'; 

    case 'z'
        k_x = 0;
        k_y = 0;
        k_r = 0;
        idx_expr = '(12, 12, 11:20, :)'; 
    case 'xy'
        k_z = 0;
        k_r = 0;
        idx_expr = '(12, 12, 12, :)'; 
    case 'radial'
        k_x = 0;
        k_y = 0;
        k_z = 0;
        idx_expr = '(12, 12, 12, :)'; 
    case 'all'
        % I wonder about my sanity and state of mind when I find myself doing
        % recursive function calls in matlab.
        generate_data3d_plane_wave('direction', 'x');
        generate_data3d_plane_wave('direction', 'y');
        generate_data3d_plane_wave('direction', 'z');
        generate_data3d_plane_wave('direction', 'radial');
        generate_data3d_plane_wave('direction', 'xy');
        data = [];
        X = [];
        Y = [];
        Z = [];
        time = [];
        return
    otherwise
        kr = 0;
end

switch grid_type
    case {'unstructured', 'scattered', 'nodal'}
        data = get_plane_wave_unstructured();
    case {'structured', 'grid', 'voxel'}
        data = get_plane_wave_structured();
    otherwise
        
end


% eval(['wave2d = squeeze(wave3d' idx_expr ');']);  


if plot_stuff 
    fig_handle = figure('Name', 'nflows-planewave3d-space');
    plot3d_debug_data_frame(fig_handle, data, X, Y, Z, time)
end


function data = get_plane_wave_structured()

    % Amplitude of the wave.
    % NOTE: can be turned into a parameter
    A = 1;
    % Preallocate memory
    data(len_y, len_x, len_z, length(time)) = 0;
    omega_sign = 1;
    % Generate the wave
    for tt=1:length(time)
        % The - sign of omega * t means the direction of propagation will be
        % along the + direction of the corresponding axes.
        data(:, :, :, tt) = A.* exp(1i.*(k_x.*X + k_y.*Y + k_z.*Z + k_r.*R - omega_sign.*omega.*time(tt)));
    end

    % Save only the real part
    data = real(data);
end % function get_plane_wave_structured()


function data = get_plane_wave_unstructured()

    % Get limits of grid without actually calculating the grid arrays.
    [min_x_val, min_y_val, min_z_val, max_x_val, max_y_val, max_z_val, ~] = get_grid_limits(locs, hxyz, hxyz, hxyz);


    % generate a plane wave in a regular grid cause it's easier
    [temp_wave3d, X, Y, Z, time] = generate_data3d_plane_wave('hxyz', hxyz, 'ht', ht, ...
                                                              'direction', direction, ...
                                                              'visual_debugging', false, ...
                                                              'min_val_space', [min_x_val, min_y_val, min_z_val], ...
                                                              'max_val_space', [max_x_val, max_y_val, max_z_val]);

                            
    wave3d(length(time), size(locs, 1)) = 0;

    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
                            
    for tt=1:length(time)
        B = temp_wave3d(:, :, :, tt);
        data_interpolant = scatteredInterpolant(X(:), Y(:), Z(:), B(:), 'linear', 'none');
        data(tt, :) = data_interpolant(locs(:, x_dim), locs(:, y_dim), locs(:, z_dim));
    end
end % function get_plane_wave_unstructured()
end % function generate_data3d_plane_wave()
