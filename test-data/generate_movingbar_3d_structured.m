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
%         pcolor3() for visual debugging
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

[X, Y, Z] = meshgrid(x, x, x); % in metres

R = sqrt(X.^2+Y.^2+Z.^2);

% NOTE: hardcoded size 
time = 0:len_x; % in seconds

% Amplitude of the wave.
% NOTE: can be turned into a parameter
A = 1;
% Preallocate memory
data(length(time), len_x, len_x, len_x) = 0;

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
        generate_planewave_3d_structured('x');
        generate_planewave_3d_structured('y');
        generate_planewave_3d_structured('z');
        generate_planewave_3d_structured('radial');
        generate_planewave_3d_structured('blah');
        return
        
    otherwise
        kr = 0;
end

% Generate the wave

for tt=0:length(time)-1
    % The - sign of omega * t means the direction of propagation will be
    % along the + direction of the corresponding axes.
    %data(tt, tt, :, 9) = 1;
    data(tt+1, :, :, :) = circshift(exp(-abs(X)/50), tt, 2);
end


% Visual debugging of the first time point
% TODO: generate a movie, perhaps of projections onto a 2d plane.
figure('Name', 'nflows-planewave3d-space');
tt = 1;
pcolor3(X, Y, Z, squeeze(data(tt, :, :, :)));
xlabel('X')
ylabel('Y')
zlabel('Z')


end % function generate_planewave3d_structured()

