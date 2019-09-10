function [wave3d] = generate_planewave_3d_structured(direction)
% This function produces a plane harmonic waves in 3D physical space +
% time.
% 
% NOTE: hardcoded stuff size
x = -10:10;
len_x = length(x);

[X, Y, Z] = meshgrid(x, x, x); % in metres
R = sqrt(X.^2+Y.^2+Z.^2);

time = linspace(0, 1, 1000);   % in seconds
omega = 2*pi*2;

kx = 0.25;
ky = 0.25;
kz = 0.25;
kr = sqrt(kx.^2 + ky.^2 + kz.*2);

% estimation of wave propagation speed
%c = omega ./ kr;

% Amplitude of the wave.
% NOTE: can be turned into a parameter
A = 1.0;
wave3d(len_x, len_x, len_x, length(time)) = 0;

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
for tt=1:length(time)
    % The - sign of omega * t means the direction of propagation will be
    % along the + direction of the corresponding axes.
    wave3d(:, :, :, tt) = A.* exp(1i.*(kx.*X+ky.*Y+kz.*Z + kr.*R - omega.*time(tt)));
end

% Visual debugging of the first time point
% TODO: generate a movie, perhaps of projections onto a 2d plane.
figure('Name', 'nflows-planewave3d');
tt = 1;
pcolor3(X, Y, Z, real(wave3d(:, :, :, tt)));
xlabel('X')
ylabel('Y')
zlabel('Z')

end % function generate_planewave3d_structured()

