function varargout = main_neural_flows_hs3d_scatter(data, locs, options) 
    % Compute neural flows from (u)nstructured (g)rids/scattered datapoints
    % This function: 
    %              1) interpolates the data onto a regular grid.
    %              2) calculates velocity fields
    %              3) detects singularities
    %              4) classifies singularities
    % data: a 2D array of size [timepoints x nodes/points] or 
    %         4D array of size [timepoints x xcoord x ycoord x zcoord]
    % locs: coordinates points in 3D Euclidean space for which data values are known. 
    %       these corresponds to the centres of gravity: ie, node locations 
    %       of brain network embedded in 3D dimensional space
    % options
    %        .interp_data: a structure
    %                    --  .file_exists  a boolean flag to determine if the 
    %                               interpolated data had been precalculated or not
    %                               and skip that step. 
    %        .interp_data: -- .file_name a string with the name of the
    %                        matfile where the interpolated data are stored
    %        .sing_detection -- .datamode = 'vel' % use velocity fields or
    %        surfaces to detect singularities
    %                           .indexmode = 'linear'; Use linear indices
    %                           or subscript to find singularities
    
    % basic options
    %options.interp_data.file_exists = false;
    %options.sing_detection.datamode = 'vel''
    %options.sing_detection.inexmode = 'linear';
    
  
    % NOTES TO CLEAN UP
    % we need to include: dt
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

    if isfield(options, 'chunk')
      rng(options.chunk) % for the cluster environment.
    end
    
    % flags to decide what to do with temp intermediate files
    keep_interp_file = true;
    keep_vel_file    = true;

    % Labels for 2D input arrays
    %n_dim = 2; % time
    t_dim = 1; % time
    
    tpts      = size(data, t_dim);
    %num_nodes = size(data, n_dim);
    
    down_factor_t = 1; % NOTE: should be input. Downsampling factor for t-axis
    time_vec      = 1:down_factor_t:tpts; % in milliseconds
    ht            = time_vec(2) - time_vec(1); % NOTE: should be input
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
    grid_size = size(X);
   
    hx = xx(2)-xx(1);
    hy = yy(2)-yy(1);
    hz = zz(2)-zz(1);   
    
    % Clean up unused vectors
    clear xx yy zz
    
    % Get a mask with the points that are inside and outside the convex
    % hull
    [in_bdy_mask, ~] = get_boundary_info(locs, X(:), Y(:), Z(:));
    in_bdy_mask = reshape(in_bdy_mask, grid_size);
    
%--------------------- INTERPOLATION OF DATA -----------------------------%    
    % Perform interpolation on the data and save in a temp file -- asumme
    % OS is Linux
    if ~options.interp_data.file_exists % Or not necesary because it is fmri data
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started interpolating data.'))
        
        % Sequential interpolation
        %[mfile_interp, mfile_interp_sentinel] = interpolate_3d_data(data, locs, X, Y, Z, in_bdy_mask, keep_interp_file); 
        
        % Parallel interpolation with the parallel toolbox
        [mfile_interp, mfile_interp_sentinel] = par_interpolate_3d_data(data, ...
                                                                        locs, X, Y, Z, ...
                                                                        in_bdy_mask, ...
                                                                        keep_interp_file);
         
        % Clean up parallel pool
        % delete(gcp); % commented because it adds 30s-1min of overhead
         options.interp_data.file_exists = true;
        
         % Saves full path to file
         options.interp_data.file_name = mfile_interp.Properties.Source;
    else
        % Load the data if file already exists
        mfile_interp = matfile(options.interp_data.file_name);
        mfile_interp_sentinel = [];
    end
        mfile_interp.options = options;
        % Make the file read-only file to avoid corruption
        mfile_interp.Properties.Writable = false;
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished interpolating data.'))

%------------------------ FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    alpha_smooth   = 1;
    max_iterations = 16;
    
    % Save flow calculation parameters parameters 
    options.flow_calculation.alpha_smooth = alpha_smooth;
    options.flow_calculation.max_iterations = max_iterations;
    options.flow_calculation.dtpts  = dtpts;
    options.flow_calculation.grid_size = grid_size;
        
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started calculating velocity fields.'))
    % We open a matfile to store output and avoid huge memory usage 
    root_fname_vel = 'temp_flows';
    
    [mfile_vel, mfile_vel_sentinel] = create_temp_file(root_fname_vel, keep_vel_file); 
    % Save mask with points inside the convex hull of the brain
    mfile_vel.in_bdy_mask = in_bdy_mask;
    
    % Get some dummy initial conditions
    if isfield(options, 'chunk')
        seed_init_vel = options.chunk; % for cluster environments
    else   
        seed_init_vel = 42;
    end
    options.flow_calculation.seed_init_vel = seed_init_vel;
    
    [uxo, uyo, uzo] = get_initial_velocity_distribution(grid_size, ~in_bdy_mask, seed_init_vel);
    
    % The following lines will create the file on disk
    mfile_vel.ux(size(uxo, x_dim), size(uxo, y_dim), size(uxo, z_dim), dtpts-1) = 0;    
    mfile_vel.uy(size(uyo, x_dim), size(uyo, y_dim), size(uyo, z_dim), dtpts-1) = 0;
    mfile_vel.uz(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), dtpts-1) = 0;
    
    %
    % This function runs the loop over timeace/time]
    % This parameter should perhaps be sapoints and saves the velocity
    % fields into a file
    detection_th = 0.1; % [in units of space/time]
    mfile_vel.detection_threshold = detection_th;
   
    % Calculate velocity fields
    compute_flows_3d()
    
    % Save grid - needed for singularity tracking and visualisation
    % TODO: save time;  
    % Consider saving min max values and step, saves memory
    mfile_vel.X = X;
    mfile_vel.Y = Y;
    mfile_vel.Z = Z;
    
    % Save time and space step deletesizes
    mfile_vel.hx = hx; % mm
    mfile_vel.hy = hy; % mm
    mfile_vel.hz = hz; % mm
    mfile_vel.ht = ht; % ms
    
    mfile_vel.options = options;
    % Delete sentinels. If these varibales are OnCleanup objects, then the 
    % files will be deleted.
    delete(mfile_interp_sentinel)    
    delete(mfile_vel_sentinel)
    
%------------------------ DETECT SINGULARITIES ---------------------------%    
   
   % NOTE: TODO: which criterion to use for the detection therhesold should  be a
   % parameter it can be rerun with different types
   % Close the file to avoid corruption
   detection_threshold = guesstimate_detection_threshold(mfile_vel.min_nu);
   mfile_vel.detection_threshold = detection_threshold;
   mfile_vel.Properties.Writable = false;
   
   switch options.sing_detection.datamode
       case 'surf'
           % Use null-isosurface intersection
           % First calculate them
           % NOTE: at the moment this partace/time]
    % This parameter should perhaps be sa is kind-of-deprecated
           fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started extraction of critical isosurfaces'))
           Calculate critical isosurfaces
           [mfile_surf, mfile_surf_sentinel] = par_get_critical_isosurfaces(mfile_vel);
           fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished extraction of critical isosurfaces'))
       case 'vel'
           mfile_surf = [];
           mfile_surf_sentinel = [];
           % Use velocity vector fields
           
       otherwise
          error(['neural-flows:: ', mfilename, '::UnknownOption. Invalid datamode for detecting singularities.'])
   end
   
   
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started detection of critical points.'))
   % Detect intersection of critical isosurfaces
   [xyz_idx]  = par_locate_critical_points(mfile_surf, mfile_vel, options.sing_detection.datamode, options.sing_detection.indexmode);
   delete(mfile_surf_sentinel)

   % Save what we just found    
   root_fname_sings = 'temp_snglrty';
   keep_sings_file = true; 
   [mfile_sings, mfile_sings_sentinel] = create_temp_file(root_fname_sings, keep_sings_file);
   mfile_sings.xyz_idx = xyz_idx;
   delete(mfile_sings_sentinel)
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started detection of critical points.'))
   
%------------------------ CLASSIFY SINGULARITIES -------------------------%    
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished classification of singularities.'))
   % Calculate jacobian and classify singularities
   singularity_classification = classify_singularities(xyz_idx, mfile_vel);
   mfile_sings.singularity_classification = singularity_classification;
   mfile_sings.options = options;
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished classification of singularities.'))

%-------------------------------------------------------------------------%
% Check if we actually want to get the handles to the matfiles 
minnout = 0;
maxnout = 3;
nargoutchk(minnout, maxnout);

if nargout > 1
    varargout{1} = mfile_vel;
    varargout{2} = mfile_interp;
    varargout{3} = mfile_sings;
end
             
% ---------------------- CHILD FUNCTION ----------------------------------%
% This child function is now a standalone function called 
% run_neural_flows_3d_ug.m
% 
    % No way around a sequential for loop for optical flows
    function compute_flows_3d()
        % Do a burn-in period for the first frame (eg, two time points of data)
        % Random initial conditions are horrible.
        
        this_tpt = 1;
        FA = mfile_interp.data(:, :, :, this_tpt);
        FB = mfile_interp.data(:, :, :, this_tpt+1);
        
        burnin_len = 4; % for iterations, not much but better than one
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started burn-in period for estimated initial velocity conditions.'))
        for bb=1:burnin_len
            % Calculate the velocity components
            [uxo, uyo, uzo] = compute_flow_hs3d(FA, FB, alpha_smooth, ...
                                                        max_iterations, ...
                                                        uxo, uyo, uzo, ...
                                                        hx, hy, hz, ht);       
        end
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished burn-in period for estimated initial velocity conditions.'))
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started estimation of flows.'))

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
               mfile_vel.ux(:, :, :, this_tpt) = single(uxo);
               mfile_vel.uy(:, :, :, this_tpt) = single(uyo);
               mfile_vel.uz(:, :, :, this_tpt) = single(uzo);
               
               % Save some other useful information
               mfile_vel = get_vfield_info(mfile_vel, uxo(:), uyo(:), uzo(:), this_tpt);
                              
        end
    
    end % function compute_flows_3d()
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished estimation of flows.'))
 

end % function compute_neural_flows_3d_ug()
