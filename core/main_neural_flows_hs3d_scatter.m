function varargout = main_neural_flows_hs3d_scatter(data, locs, options)

 % This function takes as input neural activity recorded from scattered 
 % points in space (aka an unstructured grid)
 % This function: 
 %              1) interpolates the data onto a regular grid (ie, meshgrid).
 %              2) estimates neural flows (ie, velocity fields).
 %              3) detects singularities (ie, detects null flows).
 %              4) classifies singularities.
%
% ARGUMENTS:
%            data: a 2D array of size [timepoints x nodes/points] or 
%
%            locs: 2D array of size [nodes/points x 3] with coordinates of points in 3D Euclidean space for which data values are known. 
%                  These corresponds to the centres of gravity: ie, node locations 
%                  of brain network embedded in 3D dimensional space, or source
%                  locations from MEG.
%               
%            options: a struct with structs inside
%            % Basic options 
%              options.chunk % anumber that could be slice of a long timeseries, or a different trial or recording session, used for filenames
%            
%            % Data options
%             options.data_interpolation.file_exists = false;
%
%            % Flow options  
%            options.flow_calculation.init_conditions = 'random';
%            options.flow_calculation.seed_init_vel = 42;
%            options.flow_calculation.alpha_smooth   = 0.1;
%            options.flow_calculation.max_iterations = 64;
%
%            % Singularity options
%            options.sing_analysis.detection = true;    
%            options.sing_analysis.detection_datamode  = 'vel';
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

    if isfield(options, 'chunk')
      rng(options.chunk) 
    else
       options.chunk = 0;
    end
    
    % Alpha radius has to be adjusted depending on the location data
    % (mostly, granularity of parcellation).
    if isfield(options.data_interpolation, 'bdy_alpha_radius')
        bdy_alpha_radius = options.data_interpolation.bdy_alpha_radius;
    else
        bdy_alpha_radius = 30;
    end

%-------------------------- GRID AND MASK -------------------------------------%    

    ht = options.ht;
    hx = options.hx; 
    hy = options.hy;
    hz = options.hz; 
  
    % Generate a structured grid 
    scaling_factor = 1.05; % inflate locations a little bit, so the grids have enough blank space around the volume
    [X, Y, Z, grid_size] = get_structured_grid(scaling_factor*locs, options.hx, options.hy, options.hz);
    
    % Get a mask with the points that are inside and outside the convex
    % hull
    [in_bdy_mask, ~] = data3d_calculate_boundary(locs, X(:), Y(:), Z(:), bdy_alpha_radius);
    in_bdy_mask = reshape(in_bdy_mask, grid_size);
    % Get a mask that is slightly larger so we can define a shell with a thickness that will be 
    % the boundary of our domain. 
    thickness_mask = 2;
    [interp_mask, diff_mask] = data3d_calculate_interpolation_mask(in_bdy_mask, thickness_mask);
    
%-------------------------- INTERPOLATION OF DATA -----------------------------%    
    % Perform interpolation on the data and save in a temp file -- asumme
    % OS is Linux, cause why would you use anything else?
    % Flag to decide what to do with temp intermediate files
    keep_interp_file = true;
    if isfield(options.data_interpolation, 'filename_string')
        root_fname_interp = [options.data_interpolation.filename_string '-temp_interp-' num2str(options.chunk, '%03d')];
    else       
        root_fname_interp = ['temp_interp-' num2str(options.chunk, '%03d')];
    end
    if ~options.data_interpolation.file_exists % Or not necesary because it is fmri data
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started interpolating data.'))
        
        % Parallel interpolation with the parallel toolbox
        [mfile_interp, mfile_interp_sentinel] = data3d_interpolate_parallel(data, ...
                                                                            locs, X, Y, Z, ...
                                                                            interp_mask, ...
                                                                            keep_interp_file, ...
                                                                            root_fname_interp);
         
        % Clean up parallel pool
        % delete(gcp); % commented because it adds 30s-1min of overhead
         options.data_interpolation.file_exists = true;
        
         % Saves full path to file
         options.data_interpolation.file_name = mfile_interp.Properties.Source;
    else
        % Load the data if file already exists
        mfile_interp = matfile(options.data_interpolation.file_name, 'Writable', true);
        mfile_interp_sentinel = [];
    end
        mfile_interp.options = options;
        % Make the file read-only file to avoid corruption
        mfile_interp.Properties.Writable = false;
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished interpolating data.'))
        
        % Get how many time points we have
        t_dim = 4; % time    
        dtpts = size(mfile_interp.data, t_dim);

%----------------------------- FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    keep_vel_file    = true; % TODO: probably turn into input parameter
    
    % Save flow calculation parameters
    options.flow_calculation.dtpts  = dtpts;
    options.flow_calculation.grid_size = grid_size;
        
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
    msings_obj
    % Save time and space step 
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

    [mfile_flow] = flows3d_get_scattered_flows_parallel(mfile_flow, locs);
    
    % Save original locations, just in case
    mfile_flow.locs = locs;

    % Delete sentinels. If these variable are OnCleanup objects, then the 
    % files will be deleted.
    delete(mfile_interp_sentinel)    
    delete(mfile_flow_sentinel)
    
%-------------------------- DETECT NULL FLOWS - CRITICAL POINTS ---------------%    
   if options.sing_analysis.detection
       
       fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started detection of null flows.'))
       mfile_sings = singularity3d_detection(mfile_flow);
       fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished detection of null flows.'))
       
%----------------------------- CLASSIFY SINGULARITIES -------------------------%
       fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started classification of singularities.'))
       % Calculate jacobian and classify singularities
       singularity_classification = singularity3d_classify_singularities(mfile_sings.null_points_3d, mfile_flow);
       mfile_sings.singularity_classification_list = singularity_classification;
       mfile_sings.options = options;
       fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished classification of singularities.'))
%------------------------------------------------------------------------------%
       % Check if we actually want to get the handles to the matfiles
       minnout = 0;
       maxnout = 3;
       % NOTE: not sure this check is ok
       nargoutchk(minnout, maxnout);
       

   end

   if nargout >= 1
       varargout{1} = mfile_flow;
   end
   if nargout == 2
       varargout{2} = mfile_interp;
   end
   if nargout > 2
      varargout{3} = mfile_sings;
   end
   
end % function main_neural_flows_hs3d_scatter()
