function [wave3d, time] = generate_travellingwave3d_scattered(locs, varargin)
% Generates a plane "travelling" wave moving along one of the three main 
% orthogonal axes of Euclidean space. The data is generating as a linear 
% function of space (x, Y, or Z), so in a sense is a like sinusoidal plane
% wave of infinite (temporal) period. However, the wave3d array is a 2D
% array 
% ARGUMENTS: 
%           locs      -- a 2D array of size [node/regions, 3] with the points 
%                        in 3d used to sample the solid travelling 3d wave.
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
%           wave3d   -- a 2D array of size [num_regions, timepoints].
% REQUIRES: 
%          pcolor3() for visual debugging
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, August 2019
%
% USAGE:
%{



%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: generalise set different propogation velocities.


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

[X, Y, Z, ~] = get_structured_grid(locs, hxyz, hxyz, hxyz);

%x = min(X(:)):hxyz:max(X(:));
%x1 = (min(X(:))-10):hxyz:(max(X(:))+10);
%len_x1 = length(x1);

% NOTE: hardcoded size 
time = 0:ht:10; % in seconds

A = -X;
% Preallocate memory
wave3d(length(time), size(locs, 1)) = 0;


for tt=1:length(time)
    B = circshift(A, velocity*tt, 2);
    data_interpolant = scatteredInterpolant(X(:), Y(:), Z(:), B(:), 'linear', 'none');
    wave3d(tt, :) = data_interpolant(locs(:, 1), locs(:, 2), locs(:, 3));
end

if plot_stuff
    plot_sphereanim(wave3d, locs, time);
end


end % function generate_travellingwave3d_grid()
