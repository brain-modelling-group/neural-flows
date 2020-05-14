function [data, X, Y, Z, time] = generate_wave3d_travelling_grid(varargin)
% Generates a plane "travelling" wave moving along one of the three main 
% orthogonal axes of Euclidean space. The data is generating as a linear 
% function of space (x, Y, or Z), so in a sense is a like sinusoidal plane
% wave of infinite (temporal) period.
%
% (VAR)ARGUMENTS:
%           direction -- a string with the desired wave propagation direction.
%                        Available: {'x', 'y', 'z'}.
%                        Default: {'x'}.
%           velocity -- an integer number between 1-4. Will fail
%                       otherwise.
%           visual_debugging -- a boolean to determine whther to plot
%                       figures or not.
%                       Default: {true}.
% 
% OUTPUT:
%           wave3d   -- a 4D array of size [21, 21, 21, 22]. The last
%                       dimension is time, and the first three dimensions are space.
%                       This wave moves at exaclty 1 m/s.
% REQUIRES: 
%          pcolor3() for visual debugging
%          make_movie_gif() for visual debugging
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, June 2019
%
% USAGE:
%{

[wave3d, X, Y, Z, time] = generate_data3d_travelling_wave('direction', 'x');
[wave3d, X, Y, Z, time] = generate_data3d_travelling_wave('direction', 'y');
[wave3d, X, Y, Z, time] = generate_data3d_travelling_wave('direction', 'z');


%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: generalise set different propogation velocities.

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


tmp = strcmpi(varargin,'grid_type'); 
if any(tmp)
    grid_type = varargin{find(tmp)+1}; 
else
    grid_type = 'structured';
end

tmp = strcmpi(varargin,'velocity'); % note really a velocity but an integer scaling for circshift
if any(tmp)
    velocity = varargin{find(tmp)+1}; 
else
    velocity = 1;
end

tmp = strcmpi(varargin,'visual_debugging'); % note really a velocity but an integer scaling for circshift
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else
    plot_stuff = true;
end

% 
max_val_x = 10;
max_val_x1 = 10*max_val_x;
x = -max_val_x:hxyz:max_val_x;
len_x = length(x);
x1 = -max_val_x1:hxyz:max_val_x1;
len_x1 = length(x1);

[X, ~, ~] = meshgrid(x1, x, x); % in metres

% NOTE: hardcoded size 
time = 0:ht:21; % in seconds

A = -X;
% Preallocate memory
data(len_x, len_x, len_x, length(time)) = 0;

idx_start = ceil(len_x1/2);
idx_end   = idx_start+len_x-1;
for tt=1:length(time)
    B = circshift(A, velocity*tt, 2);
    data(:, :, :, tt) = B(:, idx_start:idx_end, :);
end

[X, Y, Z] = meshgrid(x, x, x); % in metres

switch direction
    case 'y'
        data = permute(data, [2 1 3 4]);        
    case 'z'
        data = permute(data, [3 1 2 4]);        
    otherwise
end

if plot_stuff 
    fig_handle = figure('Name', 'nflows-data3-travelling-wave-space');
    switch grid_type
    case {'unstructured', 'scattered', 'nodal'}
        plot_sphereanim(data, locs, time);
    case {'structured', 'grid', 'voxel'}
        plot3d_debug_data_frame(fig_handle, data, X, Y, Z, time)
    otherwise
         error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
    end
end
end % function generate_travellingwave3d_grid()
