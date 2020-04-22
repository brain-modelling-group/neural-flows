function [X, Y, Z, params] = data3d_get_interpolation_meshgrid(locs, params)

% TODO: document 

    hx = params.interpolation.hx; 
    hy = params.interpolation.hy;
    hz = params.interpolation.hz; 
  
    % Generate a structured grid 
    scaling_factor = 1.05; % inflate locations a little bit, so the grids have enough blank space around the volume
    [X, Y, Z, grid_size] = get_structured_grid(scaling_factor*locs, hx, hy, hz);
        
    params.interpolation.x_lims = [min(X(:)) max(X(:))];
    params.interpolation.y_lims = [min(Y(:)) max(Y(:))];
    params.interpolation.z_lims = [min(Z(:)) max(Z(:))];
    params.interpolation.data.shape = grid_size;

end % function data3d_get_interpolation_meshgrid()