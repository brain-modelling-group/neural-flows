function [params, obj_interp, obj_interp_sentinel] = data3d_interpolate_parallel(data, locs, X, Y, Z, mask, params)
% This is a wrapper function for Matlab's ScatteredInterpolant. We can interpolate
% each frame of a 4D array independtly using parfor and save the interpolated data for 
% later use with optical flow. Then, just delete the interpolated data
% or offer to keep it, because this step is really a time piggy.
% Vq = F(Xq,Yq) and Vq = F(Xq,Yq,Zq) evaluates F at gridded query
% points specified in full grid format as 2-D and 3-D arrays created
% from grid vectors using [Xq,Yq,Zq] = NDGRID(xqg,yqg,zqg).
% NOTE: Only works for iomat files, not structures
% ARGUMENTS:
%           locs: locations of known data
%           data: scatter data known at locs of size tpts x nodes
%           X, Y Z: -- grid points to get interpolation out, must be 3D
%                      arrays generated with 
%           mask -- indices of points within the brain's convex hull boundary. 
%                    Same size as X, Y, or Z.
%    
% OUTPUT:
%       mfile_interp_obj: matfile handle to the file with the interpolated
%                         data.
%       mfile_interp_sentinel: OnCleanUp object. If keep_interp_data is
%                              true, then this variable is an empty array.
%       params -- updated parameter structure
%
% AUTHOR:   
%     Paula Sanz-Leon, QIMR Berghofer Feb 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    % These parameter values are essential
    neighbour_method = params.interpolation.neighbour_method;
    extrapolation_method = params.interpolation.extrapolation_method;

    x_dim_locs = params.data.x_dim_locs;
    y_dim_locs = params.data.y_dim_locs;
    z_dim_locs = params.data.z_dim_locs;
    tpts = params.data.shape.timepoints;

    if tpts < 2
        disp('NOTE to self: This will fail because there is only one data point')
    end
    
    if strcmp(params.interpolation.file.label, '')
        params.interpolation.file.label = 'tmp_interp';
    end

    % If we are slicing the data
    if params.data.slice.enabled
        params = generate_slice_filename(params, 'interpolation'); 
    end

    % Create file for the interpolated data
    [obj_interp, obj_interp_sentinel] = create_iomat_file(params.interpolation.file.label, ...
                                                          params.general.storage.dir, ...
                                                          params.interpolation.file.keep);

    obj_interp_cell = strsplit(obj_interp.Properties.Source, filesep);
    % Save properties of file
    params.interpolation.file.exists = false;
    params.interpolation.file.dir  = params.general.storage.dir;
    params.interpolation.file.name = obj_interp_cell{end};

    % Write dummy data to disk to create matfile
    obj_interp.data(params.interpolation.data.shape.y, ...
                    params.interpolation.data.shape.x, ...
                    params.interpolation.data.shape.z) = 0;

    % Write grids to disk
    obj_interp.X = X;
    obj_interp.Y = Y;
    obj_interp.Z = Z;
    
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started interpolating data.'))              
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @interpolate_step;
    interpolation_3d_storage_expression = 'data(:, :, :, jdx)';
    [obj_interp] = spmd_parfor_with_matfiles(tpts, parfun, obj_interp, interpolation_3d_storage_expression);
    
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished interpolating data.'))
    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = interpolate_step(idx)
            % Create nan array so the output is in the right shape
            temp_data = nan(size(X));
            data_interpolant = scatteredInterpolant(locs(:, x_dim_locs), ...
                                                    locs(:, y_dim_locs), ...
                                                    locs(:, z_dim_locs), ...
                                                    data(idx, :).', ...
                                                    neighbour_method, ...
                                                    extrapolation_method);

            temp_data(mask) = single(data_interpolant(X(mask).', Y(mask).', Z(mask).'));
    end % interpolate_step()

end % function data3d_interpolate_parallel()
