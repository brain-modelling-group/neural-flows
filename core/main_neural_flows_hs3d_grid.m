function varargout = main_neural_flows_hs3d_grid(data, X, Y, Z, time_vec, options) 
 % New function name flows3d_compute_neuralflows_structured_grid() 
 % This function is mainly for testing purposes of flow calculations
 % Compute neural flows from data defined on a structured grid.
 %  [wave3d, X, Y, Z, time] = generate_planewave_3d_structured('x');
 % options.chunk = 42;  
 % options.hx = 1;
 % options.hy = 1;
 % options.hz = 1;
 % options.ht = 1;
 % options.flow_calculation.init_conditions = 'random';
 % flows3d_compute_structured_grid(wave3d, X, Y, Z, time, options);
 % 
 % This function: 
 %              2) calculates velocity fields
 %              
 % data: 
 %          4D array of size [timepoints x xcoord x ycoord x zcoord]
 % X, Y, Z: 3D arrays of size [Nx, Ny, Nz] produced with meshgrid
 % options.chunk to set random initial conditions
   
    if isfield(options, 'chunk')
      rng(options.chunk) % for the cluster environment.
    end
    
    keep_vel_file    = true;

    % Labels for 2D input arrays
    %n_dim = 2; % time
    t_dim = 1; % time
    
    dtpts  = size(data, t_dim);
    ht    = time_vec(2) - time_vec(1); % NOTE: should be input
      
    % Human-readable labels for indexing dimensions of 4D arrays
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    
    grid_size = size(X);
    hx = options.hx; 
    hy = options.hy;
    hz = options.hz;   
        
    % NOTE: this is a kind of hack. For a structured grids we should not
    % need this.
    in_bdy_mask = ones(grid_size);
    
%------------------------ FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    %alpha_smooth   = 0.05;
    max_iterations = 128;
    
    % Save flow calculation parameters parameters 
    %options.flow_calculation.alpha_smooth   = alpha_smooth;
    options.flow_calculation.max_iterations = max_iterations;
    options.flow_calculation.dtpts          = dtpts;
    options.flow_calculation.grid_size      = grid_size;
        
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started estimation of neural flows.'))
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
    
    
    % The following lines will create the file on disk
    mfile_vel.ux(grid_size(x_dim), grid_size(y_dim), grid_size(z_dim), dtpts-1) = 0;    
    mfile_vel.uy(grid_size(x_dim), grid_size(y_dim), grid_size(z_dim), dtpts-1) = 0;
    mfile_vel.uz(grid_size(x_dim), grid_size(y_dim), grid_size(z_dim), dtpts-1) = 0;
    
    
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
    run_neural_flows3d_loop(data, mfile_vel, options)
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished estimation of neural flows.'))

    %flows3d_compute_neural_flows()

    
    mfile_vel.options = options;
    % Delete sentinels. If these varibales are OnCleanup objects, then the 
    % files will be deleted.
    delete(mfile_vel_sentinel)
    

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
             
end % function flows3d_compute_structured_grid()
