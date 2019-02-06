function [mfile_interp_obj, mfile_interp_sentinel] = interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_data)
% This is a wrapper function for scattered interpolant. We can interpolate
% each frame independtly using parfor and save the interpolated data for 
% later use with optical flow and then just delete the interpolated data
% or offer to keep it.

%  locs: locations of known data
%  data: scatter data known at locs of size tpts x nodes
% X, Y Z -- grid points to get interpolation out
% in_bdy_mask -- indices with points of the grid that are inside the
% convex hull of the brain/cortex

% This is the key step for the optical flow method to work
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
    
    temp_data = nan(size(X));
    
    
    %  Here we should put the function that handles multiple 
    

    % NOTE: We could do this with a parfor loop but at the expense of RAM memory
    %       Also, with a parfor we can't use the matfile object
    for this_tpt=1:tpts

        data_interpolant = scatteredInterpolant(locs(:, x_dim), ...
                                                locs(:, y_dim), ...
                                                locs(:, z_dim), ...
                                                data(this_tpt, :).', ...
                                                neighbour_method, ...
                                                extrapolation_method);

        temp_data(in_bdy_mask) = data_interpolant(X(in_bdy_mask).', Y(in_bdy_mask).', Z(in_bdy_mask).');

        % Only get 
        mfile_interp_obj.data(:, :, :, this_tpt) = temp_data;

    end

end
