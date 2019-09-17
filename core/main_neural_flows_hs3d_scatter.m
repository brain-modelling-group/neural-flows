function varargout = main_neural_flows_hs3d_scatter(data, locs, options) 
    % This function takes as input neural activity recorded from scattered 
    % points in space (aka an unstructured grid)
    % This function: 
    %              1) interpolates the data onto a regular grid (ie, meshgrid).
    %              2) estimates neural flows (ie, velocity fields).
    %              3) detects singularities (ie, detects null flows).
    %              4) classifies singularities.
    % data: a 2D array of size [timepoints x nodes/points] or 
    %         4D array of size [timepoints x xcoord x ycoord x zcoord]
    % locs: coordinates points in 3D Euclidean space for which data values are known. 
    %       These corresponds to the centres of gravity: ie, node locations 
    %       of brain network embedded in 3D dimensional space, or source
    %       locations from MEG.
    % options
    %        .data_interpolation: a structure
    %                           .file_exists  -- a boolean flag to determine if the 
    %                                            interpolated data had been precalculated or not
    %                                            and skip that step. 
    %        .data_interpolation:
    %                           .file_name -- a string with the name of the
    %                                         matfile where the interpolated data are stored
    %        .sing_detection: a structure 
    %                        .datamode = 'vel' % use velocity fields or surfaces to detect singularities
    %                        .indexmode = 'linear'; Use linear indices
    %                                                or subscript to find singularities
    
    % basic options structure
    %options.data_interpolation.file_exists = false;
    %options.sing_detection.datamode = 'vel''
    %options.sing_detection.inexmode = 'linear';
    %options.flow_calculation.alpha_smooth = 0.125; 
    %options.flow_calculation.max_iterations = 32;
    %options.flow_calculation.init_conditions = 'random';
    %options.hz = 1;
    %options.hy = 1;
    %options.hx = 1;
    %options.ht = 1;
    
  
    % NOTES TO CLEAN UP
    % TODO:FUTURE: explore around timepoints of interest using the second order temporal
    % derivative
    % NOTES: on performance on interpolation sequential for loop with 201 tpts - 8.5 
    % mins. That means that for the full simulation of 400,000 tpts
    % We would require 5h per dataset, just to interpolate data with a
    % resolution of 2mm.
    % Same dataset with a resolution of 1 mm -- matching fmri resolution
    % takes 430 s -- 
     % NOTE: full resolution (eg, approx hx*hy*hz=1mm^3), each interpolation
    % step takes about 24 seconds. Downsampling to 8mm^3 - side 2mm it takes 3s.
    
    
    
    % NOTEs on performance optical flow: 
    % max_iterations=16 
    % tpts ~ 200
    % hs = 2mmmain_neural_flows_hs3d_scatter
    % takes about 35s to calculate vector fields.
    % hs = 1mm
    % takes 214 s - 240

    if isfield(options, 'chunk')
      rng(options.chunk) % for the cluster environment.
    end
    
    % Labels for 2D input arrays
    t_dim = 1; % time    
    dtpts = size(data, t_dim);
  
    ht = options.ht;
    hx = options.hx; 
    hy = options.hy;
    hz = options.hz; 
  
    % Generate a structured grid    
    [X, Y, Z, grid_size] = get_structured_grid(locs, options.hx, options.hy, options.hz);
    
   
    % Get a mask with the points that are inside and outside the convex
    % hull
    [in_bdy_mask, ~] = data3d_calculate_boundary(locs, X(:), Y(:), Z(:));
    in_bdy_mask = reshape(in_bdy_mask, grid_size);
    
%--------------------- INTERPOLATION OF DATA -----------------------------%    
    % Perform interpolation on the data and save in a temp file -- asumme
    % OS is Linux
     % flags to decide what to do with temp intermediate files
    keep_interp_file = true;
    if ~options.data_interpolation.file_exists % Or not necesary because it is fmri data
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started interpolating data.'))
        
        % Parallel interpolation with the parallel toolbox
        [mfile_interp, mfile_interp_sentinel] = par_interpolate_3d_data(data, ...
                                                                        locs, X, Y, Z, ...
                                                                        in_bdy_mask, ...
                                                                        keep_interp_file);
         
        % Clean up parallel pool
        % delete(gcp); % commented because it adds 30s-1min of overhead
         options.data_interpolation.file_exists = true;
        
         % Saves full path to file
         options.data_interpolation.file_name = mfile_interp.Properties.Source;
    else
        % Load the data if file already exists
        mfile_interp = matfile(options.data_interpolation.file_name);
        mfile_interp_sentinel = [];
    end
        mfile_interp.options = options;
        % Make the file read-only file to avoid corruption
        mfile_interp.Properties.Writable = false;
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished interpolating data.'))

%------------------------ FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    keep_vel_file    = true;
    
    % Save flow calculation parameters
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
    
    flows3d_estimate_hs3d_flow(mfile_interp, mfile_vel, options)
    
    % Save grid - needed for singularity tracking and visualisation
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
    
%---------------------- DETECT NULL FLOWS ---------------------------------%    
   
   % NOTE: TODO: which criterion to use for the detection therhesold should  be a
   % parameter it can be rerun with different types
   % Close the file to avoid corruption
   detection_threshold = flows3d_hs3d_detect_nullflows_guesstimate_threshold(mfile_vel.min_nu);
   mfile_vel.detection_threshold = detection_threshold;
   mfile_vel.Properties.Writable = false;
   
   switch options.sing_detection.datamode
       case 'surf'
          error(['neural-flows:: ', mfilename, '::FutureOption. This singularity detection datamode is not fully implemented yet.'])
           %fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started extraction of critical isosurfaces'))
           %Calculate critical isosurfaces
           %[mfile_surf, mfile_surf_sentinel] = xperimental_extract_null_isosurfaces_parallel(mfile_vel);
           %fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished extraction of critical isosurfaces'))
       case 'vel'
           mfile_surf = [];
           mfile_surf_sentinel = [];
           % Use velocity vector fields
       otherwise
          error(['neural-flows:: ', mfilename, '::UnknownOption. Invalid datamode for detecting singularities.'])
   end
   
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started detection of null flows.'))
   % Detect intersection of critical isosurfaces
   [xyz_idx]  = flows3d_hs3d_detect_nullflows_parallel(mfile_surf, mfile_vel, options.sing_detection.datamode, options.sing_detection.indexmode);
   delete(mfile_surf_sentinel)

   % Save what we just found    
   root_fname_sings = 'temp_snglrty';
   keep_sings_file = true; 
   [mfile_sings, mfile_sings_sentinel] = create_temp_file(root_fname_sings, keep_sings_file);
   mfile_sings.xyz_idx = xyz_idx;
   delete(mfile_sings_sentinel)
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished detection of null flows.'))
   
%------------------------ CLASSIFY SINGULARITIES -------------------------%    
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started classification of singularities.'))
   % Calculate jacobian and classify singularities
   singularity_classification = singularity3d_classify_singularities(xyz_idx, mfile_vel);
   mfile_sings.singularity_classification = singularity_classification;
   mfile_sings.options = options;
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished classification of singularities.'))

%-------------------------------------------------------------------------%
% Check if we actually want to get the handles to the matfiles 
minnout = 0;
maxnout = 3;
% NOTE: not sure this check is ok
nargoutchk(minnout, maxnout);

if nargout > 1
    varargout{1} = mfile_vel;
    varargout{2} = mfile_interp;
    varargout{3} = mfile_sings;
end
              
end % function main_neural_flows_hs3d_scatter()
