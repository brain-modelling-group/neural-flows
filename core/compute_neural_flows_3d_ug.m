function compute_neural_flows_3d_ug(data, locs, interpolated_data_options) 
    % Compute neural flows from (u)nstructured (g)rids/scattered datapoints
    % data: a 2D array of size [timepoints x nodes/points] or 
    %         4D array of size [timepoints x xcoord x ycoord x zcoord]
    % locs: coordinates points in 3D Euclidean space for which data values are known. 
    %       these corresponds to the centres of gravity: ie, node locations 
    %       of brain network embedded in 3D dimensional space
    % interpolated_data: a structure
    %                    --  .exists  a boolean flag to determine if the 
    %                               interpolated data had been precalculated or not
    %                               and skip that step. 
    % interpolated_data: -- .interp_filename a string with the name of the
    %                        matfile where the interpolated data are stored
    % we need: dt
    % limits of XYZ space, presumably coming from fmri data
    % TODO: estimate timepoints of interest using the second order temporal
    % derivative
    % NOTES: on performance on interpolation sequential for loop with 201 tpts - 8.5 
    % mins. That means that for the full simulation of 400,000 tpts
    % We would require 5h per dataset, just to interpolate data with a
    % resolution of 2mm.
    % Same dataset with a resolution of 1 mm -- matching fmri resolution
    % takes 430 s -- 
    
    
    % With the parallel interpolation this task takes under one 1h;
    
    % NOTEs on performance optical flow: 
    % max_iterations=16 
    % tpts ~ 200
    % hs = 2mm
    % takes about 35s to calculate vector fields.
    % hs = 1mm
    % takes 214 s - 240
    
    
    % flags to decide what to do with temp intermediate files
    keep_interp_file = true;
    keep_vel_file    = true;

    % Labels for 2D input arrays
    %n_dim = 2; % time
    t_dim = 1; % time
    
    tpts      = size(data, t_dim);
    %num_nodes = size(data, n_dim);
    
    down_factor_t = 10; % Downsampling factor for t-axis
    time_vec      = 1:down_factor_t:tpts; % in milliseconds
    ht            = time_vec(2) - time_vec(1);
    data          = data(time_vec, :);
    
    % Recalculate timepoints
    dtpts = size(data, t_dim);
  
    
    % NOTE: full resolution (eg, approx dxyz=1mm^3), each interpolation
    % step takes about 24 seconds.
    % downsampling to 8mm^3 - side 2mm it takes 3s.
    
    int_locs = ceil(abs(locs)).*sign(locs);
    
    % Human-readable labels for indexing dimensions of 4D arrays
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    %t_dim = 4;
    down_factor_xyz = 1; % Not allowed to get different downsampling for space
    
    % Get limits for the structured grid if people did not give those
    min_x = min(int_locs(:, x_dim));
    min_y = min(int_locs(:, y_dim));
    min_z = min(int_locs(:, z_dim));

    max_x = max(int_locs(:, x_dim));
    max_y = max(int_locs(:, y_dim));
    max_z = max(int_locs(:, z_dim));
    
    % Create the grid -- THIS IS THE PROBLEM WITH SPACING
    xx = min_x:down_factor_xyz:max_x;
    yy = min_y:down_factor_xyz:max_y;
    zz = min_z:down_factor_xyz:max_z;
    [X, Y, Z] = meshgrid(xx, yy, zz);
   
    hx = xx(2)-xx(1);
    hy = yy(2)-yy(1);
    hz = zz(2)-zz(1);
    
    
    [in_bdy_mask, ~] = get_boundary_info(locs, X(:), Y(:), Z(:));
    in_bdy_mask = reshape(in_bdy_mask, size(X));
    
    
    % Perform interpolation on the data and save in temp file
    
    if ~interpolated_data_options.exists % Or not necesary because it is fmri data
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Interpolating data'))
        
        % Sequential interpolation
        %[mfile_interp, mfile_interp_sentinel] = interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_file); 
        
        % Parallel interpolation with the parallel toolbox
        [mfile_interp, mfile_interp_sentinel] = par_interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_file);
         
        % Clean up parallel pool
        % delete(gcp);
         interpolated_data_options.exists = true;
        
         % Saves full path to file
         interpolated_data_options.interp_filename = mfile_interp.Properties.Source;
    else
        % Load the data if file already exists
        mfile_interp = matfile(interpolated_data_options.interp_filename);
        mfile_interp_sentinel = [];
    end

    % Parameters for optical flow-- could be changed, could be parameters
    alpha_smooth   = 1;
    max_iterations = 16;
        
    
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Calculating velocity fields'))
    % We open a matfile to store output and avoid huge memory usage 
    root_fname_vel = 'temp_flows';
    
    [mfile_vel, mfile_vel_sentinel] = create_temp_file(root_fname_vel, keep_vel_file); 
    % Save mask with points inside the convex hull of the brain
    mfile_vel.in_bdy_mask = in_bdy_mask;
    
    % Get some dummy initial conditions
    seed_init_vel = 42;
    [uxo, uyo, uzo] = get_initial_velocity_distribution(X, ~in_bdy_mask, seed_init_vel);
    
    % The following lines will create the file on disk
    
    mfile_vel.ux(size(uxo, x_dim), size(uxo, y_dim), size(uxo, z_dim), dtpts-1) = 0;    
    mfile_vel.uy(size(uyo, x_dim), size(uyo, y_dim), size(uyo, z_dim), dtpts-1) = 0;
    mfile_vel.uz(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), dtpts-1) = 0;
    
   %
    % This function runs the loop over timepoints and saves the velocity
    % fields into a file
    compute_flows_3d()
    
    % Save grid - needed for singularity tracking and visualisation
    % TODO: save time; 
    % Considet saving min max values and step, saves memory
    mfile_vel.X = X;
    mfile_vel.Y = Y;
    mfile_vel.Z = Z;
    
    % Save time and space step sizes
    mfile_vel.hx = hx; % mm
    mfile_vel.hy = hy; % mm
    mfile_vel.hz = hz; % mm
    mfile_vel.ht = ht; % ms
    
   % Close the file to avoid corruption
    mfile_vel.Properties.Writable = false;

    % Delete sentinels. If these varibales are OnCleanup objects, then the 
    % files will be deleted.
    
    delete(mfile_interp_sentinel) 
    delete(mfile_vel_sentinel)
    
    % No way around a sequential for loop for optical flows
    function compute_flows_3d()
        
        for this_tpt = 1:dtpts-1

                % Read data
                % Save grid - needed for singularity tracking
               FA = mfile_interp.data(:, :, :, this_tpt);
               FB = mfile_interp.data(:, :, :, this_tpt+1);

               % Calculate the velocity components
               [uxo, uyo, uzo] = compute_flow_hs3d(FA, FB, alpha_smooth, ...
                                                           max_iterations, ...
                                                           uxo, uyo, uzo, ...
                                                           hx, hy, hz, ht);                                

               % Save the velocity components
               % TODO: do it every 5-10 samples perhaps - spinning disks may be a
               % problem for execution times
               mfile_vel.ux(:, :, :, this_tpt) = uxo;
               mfile_vel.uy(:, :, :, this_tpt) = uyo;
               mfile_vel.uz(:, :, :, this_tpt) = uzo;
               
               % Save some other useful information


        end
    
    end



   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Extracting isosurfaces'))
   % Calculate critical isosurfaces
   [mfile_surf, mfile_surf_sentinel] = par_get_critical_isosurfaces(mfile_vel);
   
   %fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Locating critical points'))
   % Detect intersection of critical isosurfaces
   %data_mode  = 'surf';
   %index_mode = 'linear';
   %[xyz_idx]  = par_locate_critical_points(mfile_surf, mfile_vel, data_mode, index_mode);
   
   %root_fname_sings = 'temp_snglrty';
   %keep_sings_file = true; 
   %[mfile_sings, mfile_sings_sentinel] = create_temp_file(root_fname_sings, keep_sings_file);
   %mfile_sings.xyz_idx = xyz_idx;
   %delete(mfile_sings_sentinel)
   
   % Delete isosurface sentinel, if it's oncleanup ibject, the file will be
   % deleted
   %delete(mfile_surf_sentinel)
   %fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Classifying singularities'))
   % Calculate jacobian and classify singularities
   %singularity_classification = classify_singularities(xyz_idx, mfile_vel);
   %mfile_sings.singularity_classification = singularity_classification;


end % function compute_neural_flows_3d_ug()
