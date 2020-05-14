function [data, X, Y, Z, time] = generate_data3d_travelling_biharmonic_wave(varargin)
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
%           visual_debugging -- a boolean to determine whther to plot
%                       figures or not.
%                       Default: {true}.
% 
% OUTPUT:
%          data  -- a 2D array of size [num_regions, timepoints].
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

tmp = strcmpi(varargin,'grid_type'); 
if any(tmp)
    grid_type = varargin{find(tmp)+1}; 
else
    grid_type = 'structured';
end

% For unstructured case
tmp = strcmpi(varargin,'locs'); 
if any(tmp)
    locs = varargin{find(tmp)+1}; 
else
    locs = [];
end

tmp = strcmpi(varargin,'lim_type'); 
if any(tmp)
    lim_type = varargin{find(tmp)+1}; 
else
    lim_type = 'none';
end

tmp = strcmpi(varargin,'visual_debugging'); % note really a velocity but an integer scaling for circshift
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else
    plot_stuff = true;
end


% NOTE: hardcoded size 
time = 0:ht:4; % in seconds

switch grid_type
    case {'unstructured', 'scattered', 'nodal'}
        [data, X, Y, Z] = get_unstructured_data();
    case {'structured', 'grid', 'voxel'}
        [data, X, Y, Z] = get_structured_data();
    otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
        
end


 if plot_stuff
     switch grid_type
         case {'unstructured', 'scattered', 'nodal'}
             plot_sphereanim(data, locs*1000, time);
         case {'structured', 'grid', 'voxel'}
             fig_handle = figure('Name', 'nflows-data3-biharmonic-wave-space-time');
             plot3d_debug_data_frame(fig_handle, data, X, Y, Z, time)
         otherwise
             error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
     end
 end

function [wave_temp] = generate_biharmonic_wave(X, Y, Z)
    % Example: phase velocity slower than group velocity and in opposite
    % direction
    % Wave parameters
    fc  = 4;    % Hz
    nuc = 2;    % 1/m
    df  = 0.25; % Hz
    dnu = 0.25; % 1/m

    w1  = 2*pi*(fc+df);    %angular frequency rad/s
    k1x = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
    k1y = 2*pi*(nuc-dnu);  %angular frequency wavenumber rad/m
    w2  = 2*pi*(fc-df);    %angular frequency rad/s
    k2x = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m
    k2y = 2*pi*(nuc+dnu);  %angular frequency wavenumber rad/m

    %k2 = sqrt(k2x.^2 + k2y.^2); %radial angular wavenumber rad/m
    %k1 = sqrt(k1x.^2 + k1y.^2); %radial angular wavenumber rad/m

    % Group velocity
    %dw = (w2-w1);
    %dk = (k2-k1);

    % Spatiotemporal grid 
    yy = Y(:, 1, 1);
    xx = X(1, :, 1);
    zz = Z(1, 1, :);

    [x, y, t] = meshgrid(xx, yy, time);

    wave1 = cos(w1.*t-k1x.*y+k1y.*x);
    wave2 = cos(w2.*t-k2x.*y+k2y.*x);

    % Because imagscale flips the array
    %wave1 = wave1;
    %wave2 = wave2;
    wv = wave1 + wave2;

    wv = reshape(wv, size(wv, 1), size(wv, 2), 1, size(wv, 3));

    z_steps = length(zz);

    wave_temp = wv(:, :, ones(1, 1, z_steps, 1), :);

end % function generate_biharmonic_wave()


function [data, X, Y, Z] = get_unstructured_data()
    [X, Y, Z, ~] = get_structured_grid(locs, hxyz, hxyz, hxyz, lim_type);

    [wave_temp] = generate_biharmonic_wave(X, Y, Z);

    % Preallocate memory
    data(length(time), size(locs, 1)) = 0;

    for tt=1:length(time)
        B = wave_temp(:, :, :, tt);
        data_interpolant = scatteredInterpolant(X(:), Y(:), Z(:), B(:), 'linear', 'nearest');
        data(tt, :) = data_interpolant(locs(:, 1), locs(:, 2), locs(:, 3));
    end

end % function get_unstructured_data()


function [data, X, Y, Z] = get_structured_data()
    x = -0.1:hxyz:0.1
    [X, Y, Z] = meshgrid(x, x, x);
    data = generate_biharmonic_wave(X, Y, Z); 
end % function generate_structured_data()

end % function generaste_data3d_travelling_biharmonic_wave()