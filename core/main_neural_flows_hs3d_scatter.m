function varargout = main_neural_flows_hs3d_scatter(data, locs, options)
% This function takes as input neural activity recorded from scattered 
% points in 3D space (aka an unstructured grid)
% This function performs all the analysis steps availabe in neural-flows: 
%              1) interpolates the data onto a regular grid (ie, meshgrid).
%              2) estimates neural flows (ie, velocity fields).
%              3) detects singularities (ie, detects null flows).
%              4) classifies singularities.
%
% ARGUMENTS:
%            data -- a 2D array of size [timepoints x nodes/points] or 
%
%            locs -- 2D array of size [nodes/points x 3] with coordinates of points in 3D Euclidean space for which data values are known. 
%                  These corresponds to the centres of gravity: ie, node locations 
%                  of brain network embedded in 3D dimensional space, or source
%                  locations from MEG.
%               
%            options: a struct with structs inside
%            % Basic options 
%              options.chunk % anumber that could be slice of a long timeseries, or a different trial or recording session, used for filenames
%            
%            % Data properties
%     options.data.ht = 1;
% 
%     % Options for the flow computation
%     options.interpolation.file_exists = false;
%     
%     % Resolution
%     options.interpolation.hx = 4;
%     options.interpolation.hy = 4;
%     options.interpolation.hz = 4;
%     
%     % Slice of data
%     options.chunk = idx_chunk;
%     options.chunk_start = idx_start;
%     options.chunk_stop  = idx_stop;
%     
%     % Flow calculation
%     options.flows.init_conditions.mode = 'random';
%     options.flows.init_conditions.seed = 42;
%     options.flows.method.name = 'hs3d';
%     options.flows.method.alpha_smooth   = 0.1;
%     options.flows.method.max_iterations = 64;
% 
%     % Singularity detection and classification
%     options.singularity.detection.enabled = true;    
%     options.singularity.detection.mode  = 'vel';
%     options.singularity.detection.threshold = [0 2^-9];
%%    
% OUTPUT:
%      varargout: handles to the files where results are stored
% 
% USAGE:
%{
    
%}
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer, November 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    if isfield(options.data.slice, 'id')
      rng(options.data.slice.id) 
    else
       options.data.slice.id = 0;
    end
    
    % Alpha radius has to be adjusted depending on the location data
    % (mostly, granularity of parcellation).
    if isfield(options.interpolation.boundary, 'alpha_radius')
        bdy_alpha_radius = options.interpolation.boundary.alpha_radius;
    else
        bdy_alpha_radius = 30;
    end

%-------------------------- GRID AND MASK -------------------------------------%    

    ht = options.data.ht;
    hx = options.interpolation.hx; 
    hy = options.interpolation.hy;
    hz = options.interpolation.hz; 
    %hr = sqrt(hz.^2 + hy.^y + hx.^2);
  
    % Generate a structured grid 
    scaling_factor = 1.05; % inflate locations a little bit, so the grids have enough blank space around the volume
    [X, Y, Z, grid_size] = get_structured_grid(scaling_factor*locs, hx, hy, hz);
    
    % Save the locations
    options.data.locs = locs;
    
    options.interpolation.xyz_lims{1} = [min(X(:)) max(X(:))];
    options.interpolation.xyz_lims{2} = [min(Y(:)) max(Y(:))];
    options.interpolation.xyz_lims{3} = [min(Z(:)) max(Z(:))];

    
    % Get a mask with the gridded-points that are inside and outside the convex hull
    % NOTE: This mask underestimates the volume occupied by the scattered
    % points
    [in_bdy_mask, ~] = data3d_calculate_boundary(locs, X(:), Y(:), Z(:), bdy_alpha_radius);
    %[in_bdy_mask] = data3d_check_boundary_mask(in_bdy_mask, locs, hr);

    in_bdy_mask = reshape(in_bdy_mask, grid_size);
    % Get a mask that is slightly larger so we can define a shell with a thickness that will be 
    % the boundary of our domain. 
    mask_thickness = 3;
    [interp_mask, diff_mask] = data3d_calculate_interpolation_mask(in_bdy_mask, mask_thickness);
    options.interpolation.boundary.mask_thickness = mask_thickness;
    
%-------------------------- INTERPOLATION OF DATA -----------------------------%    
    % Perform interpolation on the data and save in a temp file -- asumme
    % OS is Linux, cause why would you use anything else?
    % Flag to decide what to do with temp intermediate files
    keep_interp_file = true;
    if isfield(options.interpolation, 'filename_string')
        root_fname_interp = [options.interpolation.filename_string '-temp_interp-' num2str(options.chunk, '%03d')];
    else       
        root_fname_interp = ['temp_interp-' num2str(options.chunk, '%03d')];
    end
    if ~options.interpolation.file_exists % Or not necesary because it is fmri data
        
        % Parallel interpolation with the parallel toolbox
        [mfile_interp, mfile_interp_sentinel] = data3d_interpolate_parallel(data, ...
                                                                            locs, X, Y, Z, ...
                                                                            interp_mask, ...
                                                                            keep_interp_file, ...
                                                                            root_fname_interp);
         
        % Clean up parallel pool
        % delete(gcp); % commented because it adds 30s-1min of overhead
         options.interpolation.file_exists = true;
        
         % Saves full path to file
         options.interpolation.file_name = mfile_interp.Properties.Source;
    else
        % Load the data if file already exists
        mfile_interp = matfile(options.interpolation.file_name, 'Writable', true);
        mfile_interp_sentinel = [];
    end
        mfile_interp.options = options;
        % Make the file read-only file to avoid corruption
        mfile_interp.Properties.Writable = false;
        
        % Get how many time points we have
        t_dim = 4; % time    
        dtpts = size(mfile_interp.data, t_dim);

%----------------------------- FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    keep_vel_file    = true; % TODO: probably turn into input parameter
    
    % Save flow calculation parameters
    options.flow_calculation.dtpts  = dtpts;
    options.flow_calculation.grid_size = grid_size;    
    options.interpolation.grid_size = grid_size;

        
    % We open a matfile to store output and avoid huge memory usage
    if isfield(options.flow_calculation, 'filename_string')
        root_fname_vel = [options.flow_calculation.filename_string '-temp_flows-' num2str(options.chunk, '%03d')];
    else
        root_fname_vel = ['temp_flows-' num2str(options.chunk, '%03d')];
    end
    [mfile_flow, mfile_flow_sentinel] = create_temp_file(root_fname_vel, keep_vel_file); 
    
    % Save masks with convex hulls of the brain
    mfile_flow.in_bdy_mask = in_bdy_mask;
    mfile_flow.interp_mask = interp_mask;
    mfile_flow.diff_mask = diff_mask;
    
    % Get some dummy initial conditions
    if isfield(options, 'chunk')
        seed_init_vel = options.chunk; % for cluster environments
    else   
        seed_init_vel = 42;
    end
    options.flow_calculation.seed_init_vel = seed_init_vel;
    
    
    % Save grid - needed for singularity tracking and visualisation
    % Consider saving min max values and step, saves memory
    mfile_flow.X = X;
    mfile_flow.Y = Y;
    mfile_flow.Z = Z;

    % Save time and space step -- this seems redundant
    mfile_flow.hx = hx; % mm
    mfile_flow.hy = hy; % mm
    mfile_flow.hz = hz; % mm
    mfile_flow.ht = ht; % ms
    
    % Save all options in the flow/velocity file 
    mfile_flow.options = options;
    
    % Here is where the magic happens
    flows3d_estimate_hs3d_flow(mfile_interp, mfile_flow, options)

    % Here we get the flows on defined on the nodes -- It adds 30% to the current runtime because it uses ScatterInterpolant
    % Also, the file get larger, but having this additional variable help us with visualisations. 
    % Perhaps consider only returning this file and deleting the gridded flow file.

    mfile_flow = flows3d_get_scattered_flows_parallel(mfile_flow, locs);
    
    % Save original locations, just in case
    mfile_flow.locs = locs;

    % Delete sentinels. If these variable are OnCleanup objects, then the 
    % files will be deleted.
    delete(mfile_interp_sentinel)    
    delete(mfile_flow_sentinel)
    
%-------------------------- DETECT NULL FLOWS - CRITICAL POINTS ---------------%    
   if options.singularity.detection.enabled
              
       mfile_sings = singularity3d_detection(mfile_flow, options.sing_analysis.detection_threshold); 
%----------------------------- CLASSIFY SINGULARITIES -------------------------%
       mfile_sings = singularity3d_classify_singularities_parallel(mfile_sings, mfile_flow);             
       varargout{3} = mfile_sings;

%------------------------------------------------------------------------------%
   end
      varargout{1} = mfile_interp;
      varargout{2} = mfile_flow; 
   
end % function main_neural_flows_hs3d_scatter()
