function [params, obj_interp, obj_interp_sentinel] = data3d_interpolate(params)
% This is a wrapper function for data interpolation step
% works only for unstructured data

    % Write internal interpolation and extrapolation methods
    % ::TODO:: this field may not exist in the original json file 
    if strcmp(params.interpolation.neighbour_method, '')
       params.interpolation.neighbour_method = 'linear';
    end
    if strcmp(params.interpolation.extrapolation_method, '')
       params.interpolation.extrapolation_method = 'linear';
    end
    % Load data
    [data, params, locs] = load_data(params); 

    % Determine meshgrid for interpolated data.
    [X, Y, Z, params] = data3d_get_interpolation_meshgrid(locs, params);

    % Calculate boundary masks
    [masks, params]  = data3d_calculate_boundary_masks(locs, X, Y, Z, params);

    if params.general.parallel.enabled
        data3d_interpolate_fun = @data3d_interpolate_parallel;
    else
        data3d_interpolate_fun = @data3d_interpolate_serial;
    end
    % Interpolate data
    [params, obj_interp, obj_interp_sentinel] = data3d_interpolate_fun(data, locs, X, Y, Z, masks.outties, params);
    
    % Save
    obj_interp.masks = masks;

    % Update parameter fields on params.data
    params.data.resolution.hx = params.interpolation.resolution.hx;
    params.data.resolution.hy = params.interpolation.resolution.hy;
    params.data.resolution.hz = params.interpolation.resolution.hz;
    params.data.shape.x = params.interpolation.data.shape.x; 
    params.data.shape.y = params.interpolation.data.shape.y;
    params.data.shape.z = params.interpolation.data.shape.z;

    % Disable interpolation if we already did it
    params.general.interpolation.enabled = false;
    params.interpolation.file.exists = true;
end % function data3d_interpolate()
