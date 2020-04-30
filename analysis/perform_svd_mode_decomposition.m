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
         [output] = svd_grid();
     case {'unstructured', 'nodal', 'scattered'}
         [output] = svd_nodal();
     otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
                   'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
 end 


function [output] = svd_grid(params, obj_flows)
    masks = obj_flows.masks;
    innies_idx = find(masks.innies == true);
    num_points = length(innies_idx);
    nt = params.flows.data.shape.t;

    if nt > 1024
        disp('This is going to get ugly ...')
    end

    ux(num_points, nt) = 0;
    uy(num_points, nt) = 0;
    uz(num_points, nt) = 0;


    X = mflows_obj.X;
    Y = mflows_obj.Y;
    Z = mflows_obj.Z;

    X = X(in_bdy_idx);
    Y = Y(in_bdy_idx);
    Z = Z(in_bdy_idx); 

end

function svd_nodal()

    [num_points, ~, nt] = size(mflows_obj.uxyz);
     xdim = 1;
     ydim = 2;
     zdim = 3;
     ux(num_points, nt) = 0;
     uy(num_points, nt) = 0;
     uz(num_points, nt) = 0;

     for tt=1:nt
        temp = squeeze(mflows_obj.uxyz_sc(:, xdim, tt));
        %temp(isnan(temp)) = 0;
        ux(:, tt) = temp;
        temp = squeeze(mflows_obj.uxyz_sc(:, ydim, tt));
        %temp(isnan(temp)) = 0;
        uy(:, tt) = temp;
        temp = squeeze(mflows_obj.uxyz_sc(:, zdim, tt));
        %temp(isnan(temp)) = 0;
        uz(:, tt) = temp;
    end


    X = mflows_obj.locs(:, xdim);
    Y = mflows_obj.locs(:, ydim);
    Z = mflows_obj.locs(:, zdim);
end

%   
time_vec = inparams.data.ht:inparams.data.ht:nt*inparams.data.ht; 




   quiver_scale_factor = params.visualisation.quiver.scale

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
if params.flows.visualisation.enabled;
    fig_spatial_modes =  plot_svd_modes(V, U, X, Y, Z, time_vec, num_modes, num_points, prct_var, quiver_scale_factor);
    varargout{1} = fig_spatial_modes;
end
end % function perform_mode_decomposition()
