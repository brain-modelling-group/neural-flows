function [mfile_interp_obj, mfile_interp_sentinel] = par_interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_data)
% This is a wrapper function for Matlab's ScatteredInterpolant. We can interpolate
% each frame of a 4D array independtly using parfor and save the interpolated data for 
% later use with optical flow. Then, just delete the interpolated data
% or offer to keep it, because this step is really a time piggy.
% ARGUMENTS:
%           locs: locations of known data
%           data: scatter data known at locs of size tpts x nodes
%           X, Y Z: -- grid points to get interpolation out
%           in_bdy_mask -- indices of points within the
%                          brain's convex hull boundary. Same size as X,
%                          Y, or Z.
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

    % These parameters are essential
    neighbour_method = 'natural';
    extrapolation_method = 'none';


    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    tpts = size(data, 1);
    
    if tpts < 2
        disp('NOTE to self: This will fail becaus there is only one data point')
    end

    % Create file for the interpolated data
    root_fname = 'temp_interp';
    [mfile_interp_obj, mfile_interp_sentinel] = create_temp_file(root_fname, keep_interp_data);
    
    % Write dummy data to disk
    mfile_interp_obj.data(size(X, x_dim), size(Y, y_dim), size(Z, z_dim), tpts) = 0;          

    % Open a pallell pool using all available workers
    %percentage_of_workers = 1; % 1 --> all workers
    %open_parpool(percentage_of_workers);
    
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
