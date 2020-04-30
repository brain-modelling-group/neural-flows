function [U, S, V, varargout] = perform_svd_mode_decomposition(params, data_type, num_modes, time_vec, visual_debugging, quiver_scale_factor)
% Performs singular vector decomposition of a vector field.
% Plots most dominant spatial modes and their time series 
% ARGUMENTS:
%            params --- almighty structure
%            mflows_obj --  a matflab object, a handle to a Matfile or a struct(), with the flows and locations 
%            data_type  -- a string specifying if it's gridded data or scattered data
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
% Paula Sanz-Leon October 2019
%
% REFERENCE: 
% Townsend and Gong, 2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

% Load flows data
obj_flows = load_iomat_flows(params);


%% Define which function we will use
switch params.flows.decomposition.svd.grid.type
     case {'grid', 'structured', 'voxel'}
         svd_fun = @svd_grid;
     case {'unstructured', 'nodal', 'scattered'}
         svd_fun = @svd_nodal;
     otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
 end 

% get locations and data
[X, Y, Z, ux, uy, uz, num_points] = svd_fun(params, obj_flows)

num_modes = params.flows.decomposition.svd.modes;
[U, S, V, prct_var] = svd_decomposition(ux, uy, uz, num_modes);

% Plot spatial modes containing most energy
if params.flows.visualisation.enabled
    time_vec = inparams.data.ht:inparams.data.ht:nt*inparams.data.ht; 
    quiver_scale_factor = params.visualisation.quiver.scale;

    fig_spatial_modes =  plot_svd_modes(V, U, X, Y, Z, ...
                                        time_vec, num_modes, num_points, ...
                                        prct_var, quiver_scale_factor);
    varargout{1} = fig_spatial_modes;
end

end % function perform_svd_mode_decomposition()


function [X, Y, Z, ux, uy, uz, num_points] = svd_grid(params, obj_flows)
    masks = obj_flows.masks;
    innies_idx = find(masks.innies == true);
    num_points = length(innies_idx);
    [nx, ny, nz] = [params.flows.data.shape.x, ...
                    params.flows.data.shape.y, ...
                    params.flows.data.shape.nz];
    nt = params.flows.data.shape.t;

    if nt > 1024
        disp('This is going to get ugly ...')
    end

    ux(num_points, nt) = 0;
    uy(num_points, nt) = 0;
    uz(num_points, nt) = 0;

    for tt=1:nt
        temp = reshape(mflows_obj.ux(:, :, :, tt), nx*ny*nz, []);
        temp = temp(innies_idx);
        temp(isnan(temp)) = 0;
        ux(:, tt) = temp;
        temp = reshape(mflows_obj.uy(:, :, :, tt), nx*ny*nz, []);
        temp = temp(innies_idx);
        temp(isnan(temp)) = 0;
        uy(:, tt) = temp;
        temp = reshape(mflows_obj.uz(:, :, :, tt), nx*ny*nz, []);
        temp = temp(innies_idx);
        temp(isnan(temp)) = 0;
        uz(:, tt) = temp;
    end

    X = obj_flows.X;
    Y = obj_flows.Y;
    Z = obj_flows.Z;

    X = X(innies_idx);
    Y = Y(innies_idx);
    Z = Z(innies_idx); 

end % function svd_grid()


function [X, Y, Z, ux, uy, uz, num_points] = svd_nodal(params, obj_flows)

    num_points = params.data.shape.nodes;
    nt = params.flows.data.shape.t;
    xdim = params.data.x_dim_locs;
    ydim = params.data.y_dim_locs;
    zdim = params.data.z_dim_locs;
    ux(num_points, nt) = 0;
    uy(num_points, nt) = 0;
    uz(num_points, nt) = 0;

     for tt=1:nt
        temp = squeeze(obj_flows.uxyz_sc(:, xdim, tt));
        %temp(isnan(temp)) = 0;
        ux(:, tt) = temp;
        temp = squeeze(obj_flows.uxyz_sc(:, ydim, tt));
        %temp(isnan(temp)) = 0;
        uy(:, tt) = temp;
        temp = squeeze(obj_flows.uxyz_sc(:, zdim, tt));
        %temp(isnan(temp)) = 0;
        uz(:, tt) = temp;
    end
    X = obj_flows.locs(:, xdim);
    Y = obj_flows.locs(:, ydim);
    Z = obj_flows.locs(:, zdim);

end % function svd_nodal()


function [U, S, V, prct_var] = svd_decomposition(ux, uy, uz, prct_var)
    % svd mat is of size [nt x (nx*ny*nz*3)]
    svdmat = cat(1, ux, uy, uz).';

    % Pefrom svd
    [U, S, V] = svd(svdmat, 'econ');

    % Calculate total energy then crop to specified number of modes
    eig_vals = diag(S);
    tot_var  = sum(eig_vals.^2);
    prct_var = (100 * eig_vals.^2) / tot_var;
    U = U(:, 1:num_modes);
    S = S(1:num_modes, 1:num_modes);
    V = V(:, 1:num_modes);

    % from neuroPatt: Make time modes as positive as possible. But why?
    is_negative = mean(real(U), 1) < 0;
    U(:, is_negative) = -U(:, is_negative);
    V(:, is_negative) = -V(:, is_negative);

end % function svd_decomposition()
