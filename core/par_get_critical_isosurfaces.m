function [mfile_surf_obj,  mfile_surf_sentinel] = par_get_critical_isosurfaces(mfile_vel)
% This function calculates the isosurfaces at velocity=0 for each of the
% three orthogonal velocity components. This function calculate isosurfaces 
% in parallel -- saves results to disk

% 
% ARGUMENTS:
%       mfile_vel: matfile handle to file with the velocity component data 
%    
% OUTPUT:
%       mfile_interp_obj: matfile handle to the file with the interpolated
%                         data.
%       mfile_interp_sentinel: OnCleanUp object. If keep_interp_data is
%                              true, then this variable is an empty array.
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019
% USAGE:
%{
    
%}

    X  = mfile_vel.X;
    Y  = mfile_vel.Y;
    Z  = mfile_vel.Z;

    critical_isovalue = 0; % this isovalue could be greather than 0

    tpts = size(mfile_vel.ux, 4);


    % Create file for the isosurface data
    root_fname = 'temp_isosurf';
    keep_surf_data = true;
    [mfile_surf_obj, mfile_surf_sentinel] = create_temp_file(root_fname, keep_surf_data);

    % Open a pallell pool using all available workers
    open_parpool(1)

    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @isosurface_step;

    % This expression will create a structure of size (1, tpts) in the file;
    isosurf_storage_expression = 'isosurfs(1, jdx)';

    [mfile_surf_obj] = spmd_parfor_with_matfiles(tpts, parfun, mfile_surf_obj, isosurf_storage_expression);

    % Make the matfile read-only
    mfile_surf_obj.Properties.Writable = false;


    function temp_data = isosurface_step(idx)


    [faces_x, vertices_x] = isosurface(X, Y, Z, mfile_vel.ux(:, :, :, idx), critical_isovalue);
    [faces_y, vertices_y] = isosurface(X, Y, Z, mfile_vel.uy(:, :, :, idx), critical_isovalue);
    [faces_z, vertices_z] = isosurface(X, Y, Z, mfile_vel.uz(:, :, :, idx), critical_isovalue);

    temp_data.vertices_x = vertices_x; 
    temp_data.vertices_y = vertices_y;
    temp_data.vertices_z = vertices_z;
    temp_data.faces_x = faces_x;
    temp_data.faces_y = faces_y;
    temp_data.faces_z = faces_z;

    end


end % function par_get_critical_isosurfaces()
