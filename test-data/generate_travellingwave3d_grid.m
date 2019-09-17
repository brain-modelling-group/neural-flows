function [wave3d, X, Y, Z, time] = generate_travellingwave3d_grid(direction, velocity)
% Generates a plane "travelling" wave moving along one of the three main 
% orthogonal axes of Euclidean space. The data is generating as a linear 
% function of space (x, Y, or Z), so in a sense is a like sinusoidal plane
% wave of infinite (temporal) period.
%
% ARGUMENTS:
%           direction -- a string with the desired wave propagation direction.
%                        Available: {'x', 'y', 'z', 'radial', 'any', 'all'}.
%                        Default: {'x'}.
%           velocity -- an integer number between 1-4. Will fail
%                       otherwise.
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
% TODO: generalise so we can define grids of different sizes and set different
%       propogation velocities.
%       consider addding a flag to use visual debugging or not

% NOTE: hardcoded stuff size

if nargin < 1
    direction = 'x';
    velocity = 1;
end

if nargin < 2
    velocity = 1;
end

x = -10:10;
len_x = length(x);
x1 = -100:100;

[X, ~, ~] = meshgrid(x1, x, x); % in metres

% NOTE: hardcoded size 
time = 0:len_x; % in seconds

A = -X;
% Preallocate memory
wave3d(length(time), len_x, len_x, len_x) = 0;



for tt=1:length(time)
    B = circshift(A, velocity*tt, 2);
    wave3d(tt, :, :, :) = B(:, 101:121, :);
end

[X, Y, Z] = meshgrid(x, x, x); % in metres

switch direction
    case 'y'
        wave3d = permute(wave3d, [1 3 2 4]);
        temp = squeeze(wave3d(:, :, 11, 12));
        temp2 = squeeze(wave3d(:, :, :, 12));
        ylabel_str = 'y-axis';
        
    case 'z'
        wave3d = permute(wave3d, [1 4 2 3]);
        temp  = squeeze(wave3d(:, 11, 12, :)); % indices do not mean anything special -- just selecting a plane of 3d space
        temp2 = squeeze(wave3d(:, 12, :, :)); 
        ylabel_str = 'z-axis';
        
    otherwise
        % assume x direction
        temp = squeeze(wave3d(:, 11, :, 12));
        temp2 = wave3d(:, :, :, 12); 
        ylabel_str = 'x-axis';
end


% Visual debugging of the first time point
% TODO: generate a movie, perhaps of projections onto a 2d plane.
fig_pcolor3 = figure('Name', 'nflows-travellingwave3d-space');
these_axes = subplot(1,1,1, 'Parent', fig_pcolor3);
tt = 1;
pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)), 'axes', these_axes);
xlabel('X')
ylabel('Y')
zlabel('Z')

figure('Name', 'nflows-travellingwave3d-time')
plot(time, squeeze(wave3d(:, 11, 12, 12)));
xlim([time(1) time(end)])
xlabel('time')
ylabel('p(x, y, z)')

figure('Name', 'nflows-travellingwave3d-space-time-1d')
plot(time, temp, 'color', [0.65 0.65 0.65]);
xlim([time(1) time(end)])
xlabel('time')
ylabel(['space: ' ylabel_str])

make_movie_gif(temp2)

end % function generate_travellingwave3d_grid()
