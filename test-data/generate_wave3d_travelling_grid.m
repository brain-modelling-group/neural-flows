function [wave3d, X, Y, Z, time] = generate_wave3d_travelling_grid(varargin)
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
%           step     -- a scalar with the space step size to generate the grid
%           visual_debugging -- a boolean to determine whther to plot
%                       figures or not.
%                       Default: {true}.
% 
% OUTPUT:
%           wave3d   -- a 4D array of size [21, 21, 21, 22]. The first 
%                       dimension is time, and the last three dimensions are space.
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

[wave3d, X, Y, Z, time] = generate_travellingwave_3d_structured('x');
[wave3d, X, Y, Z, time] = generate_travellingwave_3d_structured('y');
[wave3d, X, Y, Z, time] = generate_travellingwave_3d_structured('z');


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
wave3d(length(time), len_x, len_x, len_x) = 0;

idx_start = ceil(len_x1/2);
idx_end   = idx_start+len_x-1;
for tt=1:length(time)
    B = circshift(A, velocity*tt, 2);
    wave3d(tt, :, :, :) = B(:, idx_start:idx_end, :);
end

[X, Y, Z] = meshgrid(x, x, x); % in metres

idx_1 = floor(len_x/2);
idx_2 = idx_1 + 1;
switch direction
    case 'y'
        wave3d = permute(wave3d, [1 3 2 4]);
        %temp = squeeze(wave3d(:, :, idx_1, idx_2));
        %temp2 = squeeze(wave3d(:, :, :, idx_2));
        %ylabel_str = 'y-axis';
        
    case 'z'
        wave3d = permute(wave3d, [1 4 2 3]);
        %temp  = squeeze(wave3d(:, idx_1, idx_2, :)); % indices do not mean anything special -- just selecting a plane of 3d space
        %temp2 = squeeze(wave3d(:, idx_2, :, :)); 
        %ylabel_str = 'z-axis';
        
    otherwise
        % assume x direction
        %temp = squeeze(wave3d(:, idx_1, :, idx_2));
        %temp2 = wave3d(:, :, :, idx_2); 
        %ylabel_str = 'x-axis';
end

% Visual debugging of the first time point
% TODO: generate a movie, perhaps of projections onto a 2d plane.
if plot_stuff
    
    min_val = min(wave3d(:));
    max_val = max(wave3d(:));
    
%     fig_pcolor3 = figure('Name', 'nflows-travellingwave3d-space');
%     these_axes = subplot(1,1,1, 'Parent', fig_pcolor3);
%     tt = 1;
%     pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)), 'axes', these_axes);
%     xlabel('X')
%     ylabel('Y')
%     zlabel('Z')
% 
%     figure('Name', 'nflows-travellingwave3d-time')
%     plot(time, squeeze(wave3d(:, idx_1, idx_2, idx_2)));
%     xlim([time(1) time(end)])
%     xlabel('time')
%     ylabel('p(x, y, z)')
% 
%     figure('Name', 'nflows-travellingwave3d-space-time-1d')
%     plot(time, temp, 'color', [0.65 0.65 0.65]);
%     xlim([time(1) time(end)])
%     xlabel('time')
%     ylabel(['space: ' ylabel_str])
    
    fig_spiral = figure('Name', 'nflows-spiralwave3d-space-time');
    for tt=1:length(time)
        these_axes = subplot(1, 1, 1, 'Parent', fig_spiral);
        these_axes.XLabel.String = 'X';
        these_axes.YLabel.String = 'Y';
        these_axes.ZLabel.String = 'Z';
        cla;
        pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)), 'axes', these_axes); 
        caxis([min_val  max_val]);pause(0.5); 
    end     

    %make_movie_gif(temp2)
end
end % function generate_travellingwave3d_grid()
