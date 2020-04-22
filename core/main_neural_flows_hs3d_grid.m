function varargout = main_neural_flows_hs3d_grid(data, X, Y, Z, params) 
 % This function is mainly for testing purposes of flow calculations
 % Compute neural flows from synthetic data defined on a structured grid.
 % [wave3d, X, Y, Z, time] = generate_travellingwave_3d_structured('x');
 % params.chunk = 42;  
 % params.hx = 1;
 % params.hy = 1;
 % params.hz = 1;
 % params.ht = 1;
 % params.flow_calculation.init_conditions = 'random';
 % flows3d_compute_structured_grid(wave3d, X, Y, Z, time, params);
 % 
 % This function only calculates velocity/flow fields
 %              
 % data: 
 %          4D array of size [timepoints x ycoord x xcoord x zcoord], so as to be consistent with meshgrid size for a 3d slice
 % X, Y, Z: 3D arrays of size [Ny, Nz, Nz] produced with meshgrid
 % params.chunk to set random initial conditions
   
    if isfield(params, 'chunk')
      rng(params.chunk) % for the cluster environment.
    end
    
    t_dim = 1; % time
    dtpts  = size(data, t_dim);
    grid_size = size(X);


    hx = params.interpolation.hx; 
    hy = params.interpolation.hy;
    hz = params.interpolation.hz;   
    ht = params.data.ht;
        
    % NOTE: this is a kind of hack. For a structured grids we should not
    % need this. or maybe we do?
    in_bdy_mask = ones(grid_size);
    
%------------------------ FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    
    % Save flow calculation parameters parameters 
    params.flows.dtpts          = dtpts;
    params.flows.grid_size      = grid_size;
        
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started estimation of neural flows.'))
    
    % We open a matfile to store output and avoid huge memory usage 
    root_fname_vel = 'temp_flows';
    keep_vel_file    = true;
    [mfile_vel, mfile_vel_sentinel] = create_temp_file(root_fname_vel, keep_vel_file); 
    % Save mask with points inside the convex hull of the brain
    mfile_vel.in_bdy_mask = in_bdy_mask;
    
    
    % This function runs the loop over timepoints and saves the velocity
    % fields into a file
    detection_th = 0.1; % [in units of space/time]
    % This parameter should perhaps be saved in the singularity file too
    mfile_vel.detection_threshold = detection_th;
    mfile_vel.X = X;
    mfile_vel.Y = Y;
    mfile_vel.Z = Z;
    
    % Save time and space step deletesizes
    mfile_vel.hx = hx; % mm
    mfile_vel.hy = hy; % mm
    mfile_vel.hz = hz; % mm
    mfile_vel.ht = ht; % ms
   
    % Calculate velocity fields
    % Permute data, it seems we saved the time dimension as the last
    % dimension
    data = permute(data, [2 3 4 1]);
    mfile_vel.interp_mask = ones(grid_size);
    flows3d_estimate_hs3d_flow(data, mfile_vel, params)
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished estimation of neural flows.'))
    
    mfile_vel.params = params;
    % Delete sentinels. If these varibales are OnCleanup objects, then the 
    % files will be deleted.
    delete(mfile_vel_sentinel)

if nargout > 0
    varargout{1} = mfile_vel;
end 
end % function flows3d_compute_structured_grid()
