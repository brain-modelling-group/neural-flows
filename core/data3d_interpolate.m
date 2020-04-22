function [params, masks] = data3d_interpolate(params)
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
    [masks, params]  = data3d_define_boundary_masks();

    if params.general.parallel.enabled
        params = data3d_interpolate_parallel(data, locs, X, Y, Z, masks.outties, params)
    else
        params = data3d_interpolate_serial(data, locs, X, Y, Z, masks.outties, params)
    end
 
end % function data3d_interpolate()
