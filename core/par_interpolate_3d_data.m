function [mfile_interp_obj, mfile_interp_sentinel] = par_interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_data)
% This is a wrapper function for scattered interpolant. We can interpolate
% each frame independtly using parfor and save the interpolated data for 
% later use with optical flow and then just delete the interpolated data
% or offer to keep it.

%  locs: locations of known data
%  data: scatter data known at locs of size tpts x nodes
% X, Y Z -- grid points to get interpolation out
% in_bdy_mask -- indices with points of the grid that are inside the
% convex hull of the brain/cortex

    % These parameters are essential
    neighbour_method = 'natural';
    extrapolation_method = 'none';


    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    tpts = size(data, 1);

    % Create file for the interpolated data
    root_fname = 'temp_interp';
    [mfile_interp_obj, mfile_interp_sentinel] = create_temp_file(root_fname, keep_interp_data);
    
    % Write dummy data to disk
    mfile_interp_obj.data(size(X, x_dim), size(Y, y_dim), size(Z, z_dim), tpts) = 0;          

    % Open a pallell pool using all available workers
    open_parpool(1)
    
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @interpolate_step;
    interpolation_3d_storage_expression = 'data(:, :, :, jdx)';
    [mfile_interp_obj] = spmd_parfor_with_matfiles(tpts, parfun, mfile_interp_obj, interpolation_3d_storage_expression);
    
    % Make the matfile read-only
    mfile_interp_obj.Properties.Writable = false;

    
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

            temp_data(in_bdy_mask) = data_interpolant(X(in_bdy_mask).', Y(in_bdy_mask).', Z(in_bdy_mask).');
    end

end

