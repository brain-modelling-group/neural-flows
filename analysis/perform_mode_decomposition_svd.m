function [U, S, V] = perform_mode_decomposition_svd(mflows_obj, num_modes, time_vec, visual_debugging, quiver_scale_factor)
% Performs singular vector decomposition of a vector field.
% Plots most dominant spatial modes and their time series 
% AUTHOR: 
% Paula Sanz-Leon October 2019
% REFERENCE: 
% Townsend and Gong, 2018

%% Set default values
if ~exist('num_modes', 'var')
    num_modes = 4;
end

if ~exist('quiver_scale_factor', 'var')
    quiver_scale_factor = 1;
end


if ~exist('visual_debugging', 'var')
    visual_debugging = false;
end


in_bdy_idx = find(mflows_obj.in_bdy_mask == true);
num_points = length(in_bdy_idx);

try
    [ny, nx, nz, nt] = size(mflows_obj, 'ux');

catch 
    [ny, nx, nz, nt] = size(mflows_obj.ux);
end

if ~exist('time_vec', 'var')
    time_vec = 1:nt; 
end

if nt > 1024
    disp('This is going to get ugly ...')
end

ux(num_points, nt/16) = 0;
uy(num_points, nt/16) = 0;
uz(num_points, nt/16) = 0;

% NOTE: to check why we get nans in the flows point inside the boundary.
for tt=1:nt/16
    temp = reshape(mflows_obj.ux(:, :, :, tt), nx*ny*nz, []);
    ux(:, tt) = temp(in_bdy_idx);
    ux(isnan(ux)) = 0;
    temp = reshape(mflows_obj.uy(:, :, :, tt), nx*ny*nz, []);
    uy(:, tt) = temp(in_bdy_idx);
    uy(isnan(uy)) = 0;
    temp = reshape(mflows_obj.uz(:, :, :, tt), nx*ny*nz, []);
    uz(:, tt) = temp(in_bdy_idx);
    uz(isnan(uz)) = 0;
end

X = mflows_obj.X;
Y = mflows_obj.Y;
Z = mflows_obj.Z;

X = X(in_bdy_idx);
Y = Y(in_bdy_idx);
Z = Z(in_bdy_idx);

% svd mat is of size [nt x (nx*ny*nz*3)]
svdmat = cat(1, ux, uy, uz).';

[U, S, V] = svd(svdmat, 'econ');

% Calculate total energy then crop to specified number of modes
eig_vals = diag(S);
tot_var = sum(eig_vals.^2);
prct_var = (100 * eig_vals.^2) / tot_var;
U = U(:,1:num_modes);
S = S(1:num_modes, 1:num_modes);
V = V(:,1:num_modes);

% from neuroPatt: Make time modes as positive as possible. But why?
isNegative = mean(real(U), 1) < 0;
U(:, isNegative) = -U(:, isNegative);
V(:, isNegative) = -V(:, isNegative);


% Plot spatial modes containing most energy
if visual_debugging
    
    fig_spatial_modes = figure('Name', 'nflows-spatial-modes');

    for kk=1:num_modes
       ax(kk) = subplot(2, num_modes, kk, 'Parent', fig_spatial_modes);
       hold(ax(kk), 'on')
    end

    ax(num_modes+1) = subplot(2, num_modes, [num_modes+1 2*num_modes], 'Parent', fig_spatial_modes);
    hold(ax(num_modes+1), 'on')

    for imode = 1:num_modes
        x_idx = 1:num_points;
        y_idx = num_points+1:2*num_points;
        z_idx = 2*num_points+1:3*num_points;
        quiver3(ax(imode), X, Y, Z, V(x_idx, imode), V(y_idx, imode), V(z_idx, imode), quiver_scale_factor);
        ax(imode).View = [0 90];
        ax(imode).Title.String = sprintf('Mode %i, Var = %0.1f%%', imode, prct_var(imode));

    end
     [~, Upeak] = envelope(U, 4, 'peak');
     mav_u_val = 1.1*max(abs(Upeak(:)));
     ulims = [-max_u_val max_u_val];
     
     plot(ax(num_modes+1), time_vec, Upeak)
     ax(num_modes+1).Title.String = sprintf('Modes timeseries');
     ax(num_modes+1).YLim = ulims;
     ax(num_modes+1).XLim = [time_vec(1), time_vec(end)];
     line(ax(num_modes+1), ax(num_modes+1).XLim, [0 0], 'Color', 'k')
     ax(num_modes+1).XLabel.String = 'Time';
     ax(num_modes+1).YLabel.String = 'Component score';
end
end % function perform_mode_decomposition()
