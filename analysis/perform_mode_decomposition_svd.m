function [U, S, V, varargout] = perform_mode_decomposition_svd(mflows_obj, data_type, num_modes, time_vec, visual_debugging, quiver_scale_factor)
% Performs singular vector decomposition of a vector field.
% Plots most dominant spatial modes and their time series 
% ARGUMENTS:
%            mflows_obj --  a matflab object, a handle to a Matfile or a struct(), with the flows and locations 
%            data_type  -- a string specifying if it;s gridded data or scattered data
%
%            num_modes --  an integer with the maximum number of modes to display
%            
%            time_vec  -- a vector of size [1 x tpts], must match the temporal dimension of the flows 
%            visual_debugging    -- a boolean to define whther to plot stuff or not
%            quiver_scale_factor -- one of the varargin for quiver3
% OUTPUT:
%      [U, S, V]  -- svd matrices 
% 
% USAGE:
%{
    
%}
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer, November 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
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


if strcmp(data_type, 'grid')


    in_bdy_idx = find(mflows_obj.in_bdy_mask == true);
    num_points = length(in_bdy_idx);

    try
        [ny, nx, nz, nt] = size(mflows_obj, 'ux');
        nt = nt/2;

    catch 
        [ny, nx, nz, nt] = size(mflows_obj.ux);
    end


    ux(num_points, nt) = 0;
    uy(num_points, nt) = 0;
    uz(num_points, nt) = 0;
    % NOTE: to check why we get nans in the flows point inside the boundary.
    for tt=1:nt
        temp = reshape(mflows_obj.ux(:, :, :, tt), nx*ny*nz, []);
        temp = temp(in_bdy_idx);
        temp(isnan(temp)) = 0;
        ux(:, tt) = temp;
        temp = reshape(mflows_obj.uy(:, :, :, tt), nx*ny*nz, []);
        temp = temp(in_bdy_idx);
        temp(isnan(temp)) = 0;
        uy(:, tt) = temp;
        temp = reshape(mflows_obj.uz(:, :, :, tt), nx*ny*nz, []);
        temp = temp(in_bdy_idx);
        temp(isnan(temp)) = 0;
        uz(:, tt) = temp;
    end

    X = mflows_obj.X;
    Y = mflows_obj.Y;
    Z = mflows_obj.Z;

    X = X(in_bdy_idx);
    Y = Y(in_bdy_idx);
    Z = Z(in_bdy_idx);

else
     [num_points, ~, nt] = size(mflows_obj.usc_xyz);
     xdim = 1;
     ydim = 2;
     zdim = 3;
     ux(num_points, nt) = 0;
     uy(num_points, nt) = 0;
     uz(num_points, nt) = 0;

     for tt=1:nt
        temp = squeeze(mflows_obj.usc_xyz(:, xdim, tt));
        ux(:, tt) = temp;
        ux(isnan(ux)) = 0;
        temp = squeeze(mflows_obj.usc_xyz(:, ydim, tt));
        uy(:, tt) = temp;
        uy(isnan(uy)) = 0;
        temp = squeeze(mflows_obj.usc_xyz(:, zdim, tt));
        uz(:, tt) = temp;
        uz(isnan(uz)) = 0;
    end


    X = mflows_obj.locs(:, xdim);
    Y = mflows_obj.locs(:, ydim);
    Z = mflows_obj.locs(:, zdim);
    
end

if ~exist('time_vec', 'var')
        time_vec = 1:nt; 
end

if nt > 1024
    disp('This is going to get ugly ...')
end



% svd mat is of size [nt x (nx*ny*nz*3)]
svdmat = cat(1, ux, uy, uz).';

[U, S, V] = svd(svdmat, 'econ');

% Calculate total energy then crop to specified number of modes
eig_vals = diag(S);
tot_var = sum(eig_vals.^2);
prct_var = (100 * eig_vals.^2) / tot_var;
U = U(:, 1:num_modes);
S = S(1:num_modes, 1:num_modes);
V = V(:, 1:num_modes);

% from neuroPatt: Make time modes as positive as possible. But why?
isNegative = mean(real(U), 1) < 0;
U(:, isNegative) = -U(:, isNegative);
V(:, isNegative) = -V(:, isNegative);


% Plot spatial modes containing most energy
if visual_debugging
    
    fig_spatial_modes =  plot_svd_modes(V, U, X, Y, Z, time_vec, num_modes, num_points, prct_var, quiver_scale_factor);
    varargout{1} = fig_spatial_modes;
end
end % function perform_mode_decomposition()
