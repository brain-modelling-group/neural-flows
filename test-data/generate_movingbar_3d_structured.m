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
x1 = -40:40;


[X, ~, ~] = meshgrid(x1, x, x); % in metres


% NOTE: hardcoded size 
time = 0:len_x; % in seconds

% Amplitude of the wave.
% NOTE: can be turned into a parameter
A = exp(-abs(X)/50);
% Preallocate memory
data(length(time), len_x, len_x, len_x) = 0;



for tt=0:length(time)-1
    % The - sign of omega * t means the direction of propagation will be
    % along the + direction of the corresponding axes.
    %data(tt, tt, :, 9) = 1;
    B = circshift(A, tt, 2);
    data(tt+1, :, :, :) = B(:, 31:51, :);
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


end % function generate_planewave3d_structured()

