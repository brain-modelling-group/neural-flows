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
%edit
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019, August 2019
%
% USAGE:
%{



%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO: generalise set different propogation velocities.
% TODO: generalise for travelling waves along the other dimensions.


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

tmp = strcmpi(varargin,'direction'); 
if any(tmp)
    direction = varargin{find(tmp)+1}; 
else
    direction = 'x';
end

[X, Y, Z, ~] = get_structured_grid(locs, hxyz, hxyz, hxyz);

% NOTE: hardcoded size 
time = 0:ht:10; % in seconds

% Preallocate memory
wave3d(length(time), size(locs, 1)) = 0;

switch direction
    case 'x'
        
      y = min(Y(:)):hxyz:max(Y(:));
      z = min(Z(:)):hxyz:max(Z(:));
      offset = 25;
      x1 = (min(X(:))-2*offset):hxyz:max(X(:));
      [X1, ~, ~] = meshgrid(x1, y, z);
      circshift_dim = 2;
      A = X1;
      % X
      idx_start = offset;
      idx_end   = offset+size(X, 2)-1;
      % Y
      idy_start = 1;
      idy_end = length(y);
      % Z
      idz_start = 1;
      idz_end = length(z);
      
    case 'y'
      x = min(X(:)):hxyz:max(X(:));
      z = min(Z(:)):hxyz:max(Z(:));
      offset = 25;
      y1 = (min(Y(:))-2*offset):hxyz:max(Y(:));
      [~, Y1, ~] = meshgrid(x, y1, z);
      circshift_dim = 1;
      A = Y1;
      idx_start = 1;
      idx_end = length(x);
      idy_start = offset;
      idy_end   = offset+size(X, 1)-1;
      idz_start = 1;
      idz_end = length(z);
    case 'z'
      x = min(X(:)):hxyz:max(X(:));
      y = min(Y(:)):hxyz:max(Y(:));
      offset = 25;
      z1 = (min(Z(:))-2*offset):hxyz:max(Z(:));
      [~, ~, Z1] = meshgrid(x, y, z1);
      circshift_dim = 3;
      A = Z1;
      idx_start = 1;
      idx_end = length(x);
      idy_start = 1;
      idy_end = length(y);
      idz_start = offset;
      idz_end   = offset+size(X, 3)-1;
end



for tt=1:length(time)
    B = circshift(A, velocity*tt, circshift_dim);
    B = B(idy_start:idy_end, idx_start:idx_end, idz_start:idz_end);
    % This step is super slow -- so do not run this example for long
    % timeseries.
    data_interpolant = scatteredInterpolant(X(:), Y(:), Z(:), B(:), 'linear', 'none');
    %data_interpolant = scatteredInterpolant(Y(:), X(:), Z(:), B(:), 'linear', 'none');
    wave3d(tt, :) = data_interpolant(locs(:, 1), locs(:, 2), locs(:, 3));
end

if plot_stuff
    plot_sphereanim(wave3d, locs, time);
end


end % function generate_travellingwave3d_grid()
