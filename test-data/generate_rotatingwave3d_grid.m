function [data] = generate_rotating_wave_3d(half_size, dt, T, frequency, lambda, direction, varargin)
% Generates a rotating wave in 3D space. The rotation occurs on the XY-plane. 
% The position of the centre of rotation (the tip) - on xy - changes with 
% depth z.
% 
%  ARGUMENTS:
%        half_size  -- integer with specifying half of sidelength of the image cube
%        dt         -- time step in seconds
%        T          -- maximum time in seconds 
%        frequency  -- frequency in [Hz]
%        lambda     -- radial wavelength in [m].
%        direction  -- and integer +1 or -1, defines the direction of rotation. 
%
%  OUTPUT:
%        data -- a 4D array of size [side_size, side_size, side_size, T/dt]; 
%                where side_size = 2*half_size - 1; 
%
%  REQUIRES:
%
%
%  AUTHOR:
%    Paula Sanz-Leon, QIMR, 2019
%
%
%  USAGE:
%{

%}

side_size = 2*half_size - 1; % Always odd number of points
if ~isempty(varargin) 
    phase_offset = varargin{1}; 
    if nargin > 5
        center_point = varargin{2};
    else
        center_point = [floor(side_size/2) floor(side_size/2), floor(side_size/2)];
    end
else
    phase_offset = 0; 
    center_point = [floor(side_size/2) floor(side_size/2),  floor(side_size/2)];
end


% Time axis 
time = dt:dt:T;

% Rotating spiral tip
tip = (1:side_size)-center_point(3);
tip_y = sin(tip);
tip_x = cos(tip);

data = zeros(side_size, side_size, side_size, T/dt );

for ii = 1:side_size
    for jj = 1:side_size
        for kk=1:side_size
            
        % Spatial domain
        [X, Y, ~] = meshgrid((1:side_size)-center_point(2)-tip_x(kk), ...
                             (1:side_size)-center_point(1)-tip_y(kk), ...
                             (1:side_size)-center_point(3));

        % Rotation plane is XY
        [TH, ~] = cart2pol(X,Y);

        data(ii, jj, kk, :) = exp(sign(frequency).*1i.*( 2*pi*abs(frequency)*time - direction.*TH(ii,jj)* ((2*pi)./lambda) ));
        
        end
    end
    
end
data = data .* exp( 1i .* phase_offset );  
data = real(data);
end % end generate_rotating_wave_3d()