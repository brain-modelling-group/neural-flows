function [mfile_interp_obj, mfile_interp_sentinel] = data3d_interpolate_parallel(data, locs, X, Y, Z, mask, keep_interp_data, root_fname)
% This is a wrapper function for Matlab's ScatteredInterpolant. We can interpolate
% each frame of a 4D array independtly using parfor and save the interpolated data for 
% later use with optical flow. Then, just delete the interpolated data
% or offer to keep it, because this step is really a time piggy.
% ARGUMENTS:
%           locs: locations of known data
%           data: scatter data known at locs of size tpts x nodes
%           X, Y Z: -- grid points to get interpolation out, must be 3D
%                      arrays
%           mask -- indices of points within the brain's convex hull boundary. 
%                    Same size as X, Y, or Z.
%    
% OUTPUT:
%       mfile_interp_obj: matfile handle to the file with the interpolated
%                         data.
%       mfile_interp_sentinel: OnCleanUp object. If keep_interp_data is
%                              true, then this variable is an empty array.
%
% AUTHOR:   
%     Paula Sanz-Leon
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    % These parameter values are essential
    neighbour_method = 'natural';
    extrapolation_method = 'nearest';


    x_dim = 2;
    y_dim = 1;
    z_dim = 3;
    tpts = size(data, 1);
    
    if tpts < 2
        disp('NOTE to self: This will fail because there is only one data point')
    end
    
    if nargin < 8
        root_fname = 'temp_interp';
    end

    % Create file for the interpolated data
    [mfile_interp_obj, mfile_interp_sentinel] = create_temp_file(root_fname, keep_interp_data);
    
    % Write dummy data to disk
    mfile_interp_obj.data(size(Y, y_dim), size(X, x_dim), size(Z, z_dim), tpts) = 0;          
    
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @interpolate_step;
    interpolation_3d_storage_expression = 'data(:, :, :, jdx)';
    [mfile_interp_obj] = spmd_parfor_with_matfiles(tpts, parfun, mfile_interp_obj, interpolation_3d_storage_expression);

    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = interpolate_step(idx)
            % Create nan array so the output is in the right shape
            temp_data = nan(size(X));
            data_interpolant = scatteredInterpolant(locs(:, x_dim), ...
                                                    locs(:, y_dim), ...
                                                    locs(:, z_dim), ...
                                                    data(idx, :).', ...
                                                    neighbour_method, ...
                                                    extrapolation_method);

            temp_data(mask) = single(data_interpolant(X(mask).', Y(mask).', Z(mask).'));
    end

end
