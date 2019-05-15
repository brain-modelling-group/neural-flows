function [mfile_surf_obj,  mfile_surf_sentinel] = par_get_critical_isosurfaces(mfile_vel)
% This function calculates the isosurfaces at velocity=0 for each of the
% three orthogonal velocity components. This function calculate isosurfaces 
% in parallel -- saves results to disk

% 
% ARGUMENTS:
%       mfile_vel: matfile handle to file with the velocity components data 
%    
% OUTPUT:
%       mfile_surf_obj: matfile handle to the file with the interpolated
%                         data.
%       mfile_surf_sentinel: OnCleanUp object. If keep_interp_data is
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


        [faces_x, vertices_ux] = isosurface(X, Y, Z, mfile_vel.ux(:, :, :, idx), critical_isovalue);
        [faces_y, vertices_uy] = isosurface(X, Y, Z, mfile_vel.uy(:, :, :, idx), critical_isovalue);
        [faces_z, vertices_uz] = isosurface(X, Y, Z, mfile_vel.uz(:, :, :, idx), critical_isovalue);

        %HACK: should be removed from here or parameter 'fraction ot keep'
        %should  be available.

        fraction_to_keep = 0.1; 
        % Ux surface
        [Fx, Vx] = reducepatch(faces_x, vertices_ux, fraction_to_keep);    
        temp_data.vertices_ux = Vx;
        temp_data.faces_x = Fx;
        % Uy surface
        [Fy, Vy] = reducepatch(faces_y, vertices_uy, fraction_to_keep);    
        temp_data.vertices_uy = Vy;
        temp_data.faces_y = Fy;

        % Uz surface
        [Fz, Vz] = reducepatch(faces_z, vertices_uz, fraction_to_keep);    
        temp_data.vertices_uz = Vz;
        temp_data.faces_z = Fz;

    end


end % function par_get_critical_isosurfaces()
