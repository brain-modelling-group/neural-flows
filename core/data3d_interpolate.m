function params = data3d_interpolate(params)
% This is a wrapper function for data interpolation step

    % Write internal interpolation and extrapolation methods
    if strcmp(params.interpolation.neighbour_method, '')
       params.interpolation.neighbour_method = 'linear';
    end
    if strcmp(params.interpolation.extrapolation_method, '')
       params.interpolation.extrapolation_method = 'linear';
    end
    % Load data
    [data, params] = load_data(params); 

    % Calculate boundary

    % Calcualte grids

    if params.general.parallel.enabled
        params = data3d_interpolate_parallel(data, locs, X, Y, Z, params)
    else
        params = data3d_interpolate_serial(data, locs, X, Y, Z, params)
    end
 
end % function data3d_interpolate()
