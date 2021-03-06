function [svd_struct] = svd_3d(params)
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
     case {'grid', 'structured', 'voxel', 'meshgrid'}
         svd_fun = @svd_meshgrid;
     case {'unstructured', 'nodal', 'scattered', 'meshless'}
         svd_fun = @svd_meshless;
     otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
 end 

% get locations and data
[X0, Y0, Z0, ux, uy, uz, num_points] = svd_fun(params, obj_flows);

num_modes = params.flows.decomposition.svd.modes;
[U, ~, V, prct_var] = svd_decomposition(ux, uy, uz, num_modes);

[vx, vy, vz] = reshape_svd_modes(V, num_points);
clear V 
V.vx = vx;
V.vy = vy;
V.vz = vz;

XYZ.X = X0;
XYZ.Y = Y0;
XYZ.Z = Z0;

svd_struct.XYZ = XYZ;
svd_struct.V = V;
svd_struct.U = U;
svd_struct.num_points = num_points;
svd_struct.prct_var = prct_var;

end % function perform_svd_mode_decomposition()


function [X, Y, Z, ux, uy, uz, num_points] = svd_meshgrid(params, obj_flows)
    obj_interp = load_iomat_interp(params);
    masks = obj_interp.masks;
    innies_idx = find(masks.innies == true);
    num_points = length(innies_idx);
    
    
    [nx, ny, nz] = deal(params.flows.data.shape.x, ...
                        params.flows.data.shape.y, ...
                        params.flows.data.shape.z);
    nt = params.flows.data.shape.t;

    if isempty(innies_idx)
        num_points = nx*ny*nz;
        innies_idx = ones(num_points, 1);
    end
    
    if nt > 1024
        disp('This is going to get ugly ...')
    end

    ux(num_points, nt) = 0;
    uy(num_points, nt) = 0;
    uz(num_points, nt) = 0;
    threshold = 1e-4; % Should be a parameter
    for tt=1:nt
        temp = reshape(obj_flows.ux(:, :, :, tt), nx*ny*nz, []);
        temp = temp(innies_idx);
        temp(isnan(temp)) = 0;
        temp(abs(temp) <= threshold) = 0;
        ux(:, tt) = temp;
        temp = reshape(obj_flows.uy(:, :, :, tt), nx*ny*nz, []);
        temp = temp(innies_idx);
        temp(isnan(temp)) = 0;
        temp(abs(temp) <= threshold) = 0;
        uy(:, tt) = temp;
        temp = reshape(obj_flows.uz(:, :, :, tt), nx*ny*nz, []);
        temp = temp(innies_idx);
        temp(isnan(temp)) = 0;
        temp(abs(temp) <= threshold) = 0;
        uz(:, tt) = temp;
    end

    X = obj_flows.X;
    Y = obj_flows.Y;
    Z = obj_flows.Z;

    X = X(innies_idx);
    Y = Y(innies_idx);
    Z = Z(innies_idx); 

end % function svd_grid()


function [X, Y, Z, ux, uy, uz, num_points] = svd_meshless(params, obj_flows)

    num_points = params.data.shape.nodes;
    nt = params.flows.data.shape.t;
    xdim = params.data.x_dim_locs;
    ydim = params.data.y_dim_locs;
    zdim = params.data.z_dim_locs;
    ux(num_points, nt) = 0;
    uy(num_points, nt) = 0;
    uz(num_points, nt) = 0;
    
    if strcmp(params.flows.modality, 'amplitude') 
         threshold = 1e-4; % Should be a parameter
         for tt=1:nt
            temp = squeeze(obj_flows.uxyz(:, xdim, tt));
            temp(abs(temp) <= threshold) = 0;
            ux(:, tt) = temp;
            temp = squeeze(obj_flows.uxyz(:, ydim, tt));
            temp(abs(temp) <= threshold) = 0;
            uy(:, tt) = temp;
            temp = squeeze(obj_flows.uxyz(:, zdim, tt));
            temp(abs(temp) <= threshold) = 0;
            uz(:, tt) = temp;
         end
    else % assume phase
         for tt=1:nt
            ux(:, tt) = obj_flows.vx(tt, :);
            uy(:, tt) = obj_flows.vy(tt, :);
            uz(:, tt) = obj_flows.vz(tt, :);
         end
    end
        
    X = obj_flows.locs(:, xdim);
    Y = obj_flows.locs(:, ydim);
    Z = obj_flows.locs(:, zdim);

end % function svd_nodal()


function [U, S, V, prct_var] = svd_decomposition(ux, uy, uz, num_modes)
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

 function [Vx, Vy, Vz] = reshape_svd_modes(V, num_points)
    x_idx = 1:num_points;
    y_idx = num_points+1:2*num_points;
    z_idx = 2*num_points+1:3*num_points;
    Vx = V(x_idx, :); 
    Vy = V(y_idx, :);
    Vz = V(z_idx, :);                                         
 end % function reshape_svd_modes()
