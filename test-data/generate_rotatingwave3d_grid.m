function [wave3d] = generate_rotatingwave3d_grid(ht, T, frequency, hx, lambda, direction, varargin)
% Generates a rotating wave in 3D space+time. The rotation occurs on the XY-plane. 
% The position of the centre of rotation (the tip) - on xy - changes with 
% depth z.
% 
%  ARGUMENTS:
%        half_size  -- integer with specifying half of sidelength of the image cube
%        ht         -- time step in seconds
%        hx         -- 
%        T          -- maximum time in seconds 
%        frequency  -- frequency in [Hz]
%        lambda     -- radial wavelength in [m].
%        direction  -- and integer +1 or -1, defines the direction of rotation. 
%
%  OUTPUT:
%        data -- a 4D array of size [side_size, side_size, side_size, T/ht]; 
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

ht = 0.0625;
T = 8;
f = 2;
hx = 0.25;
lambda = 4; % wavelength
direction = 1;
wave3d = generate_rotatingwave3d_grid(ht, T, f, hx, lambda, direction);

%}

if ~isempty(varargin) 
    phase_offset = varargin{1}; 
    if nargin > 5
        center_point = varargin{2};
    else
        center_point = [0 0 0];
    end
else
    phase_offset = 0; 
    center_point = [0 0 0];
end


% Time axis 
time = ht:ht:T;



max_val = 5;

x = (-max_val:hx:max_val)-center_point(2);
y = (-max_val:hx:max_val)-center_point(1);
z = (-max_val:hx:max_val)-center_point(3);
len_x = length(x);
wave3d = zeros(T/ht, len_x, len_x, len_x);


k = (2*pi)/lambda;
% Rotating spiral tip
tip = z;
tip_y = sin(tip);
tip_x = cos(tip);

for ii = 1:length(x)
    for jj = 1:length(x)
        for kk=1:length(x)
            
        % Spatial domain
        [X, Y, ~] = meshgrid(x-tip_x(kk), ...
                             y-tip_y(kk), ...
                             z);

        % Rotation plane is XY
        [TH, ~] = cart2pol(X,Y);

        wave3d(:, ii, jj, kk) = exp(1i.*(direction.*TH(ii,jj, kk)* ((2*pi)./lambda) -  2*pi*abs(frequency)*time));
        
        end
    end
    
end
wave3d = wave3d .* exp(1i .* phase_offset);  
wave3d = real(wave3d);
end % end generate_rotatingwave3d_grid()
