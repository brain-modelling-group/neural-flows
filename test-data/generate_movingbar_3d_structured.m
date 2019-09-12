function [data, X, Y, Z, time] = generate_movingbar_3d_structured()
% Generates a moving bar across 3d space.
%
% ARGUMENTS:
%           direction -- a string with the desired wave propagation direction.
%                        Available: {'x', 'y', 'z', 'radial', 'any', 'all'}.
%                        Default: {'x'}.
% OUTPUT:
%           wave3d   -- a 4D array of size [21, 21, 21, 50]. The first 
%                       three dimensions are space and the last one is time.
% REQUIRES: 
%          pcolor3() for visual debugging
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, June 2019
%
% USAGE:
%{

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% NOTE: hardcoded stuff size
x = -10:10;
len_x = length(x);
x1 = -100:100;


[X, ~, ~] = meshgrid(x1, x, x); % in metres


% NOTE: hardcoded size 
time = 0:len_x; % in seconds

% Amplitude of the wave.
% NOTE: can be turned into a parameter
A = X;
% Preallocate memory
data(length(time), len_x, len_x, len_x) = 0;



for tt=1:length(time)
    % The - sign of omega * t means the direction of propagation will be
    % along the + direction of the corresponding axes.
    %data(tt, tt, :, 9) = 1;
    B = circshift(A, 4*tt, 2);
    data(tt, :, :, :) = B(:, 101:121, :);
end

[X, Y, Z] = meshgrid(x, x, x); % in metres

% Visual debugging of the first time point
% TODO: generate a movie, perhaps of projections onto a 2d plane.
figure('Name', 'nflows-planewave3d-space');
tt = 1;
pcolor3(X, Y, Z, squeeze(data(tt, :, :, :)));
xlabel('X')
ylabel('Y')
zlabel('Z')

figure('Name', 'nflows-planewave3d-time')
plot(time, squeeze(data(:, 11, 12, 12)));
xlabel('time')
ylabel('p(x, y, z)')

figure('Name', 'nflows-planewave3d-space-time-1d')
plot(time, squeeze(data(:, 11, :, 12)), 'color', [0.65 0.65 0.65]);
xlabel('time')
ylabel('space: x-axis')

end % function generate_movingfront_3d_structured()

