function  [params, varargout] = flows3d_estimate_hs3d(params, masks)
% ARGUMENTS:
%           
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

    % If we are slicing the data
    if params.data.slice.enabled
        rng(params.data.slice.id 
    else
        rng(2020)
    end
 

    
    if isfield(params.interpolation.file, 'name')
        root_fname_interp = [params.interpolation.file.name '-temp_interp-' num2str(params.data.slice.id, '%03d')];
    else       
        root_fname_interp = ['temp_interp-' num2str(params.data.slice.id, '%03d')];
    end
    if ~params.interpolation.file.exists % Or not necesary because it is fmri data
        
        % Parallel interpolation with the parallel toolbox
        [mfile_interp, mfile_interp_sentinel] = data3d_interpolate_parallel(data, ...
                                                                            locs, X, Y, Z, ...
                                                                            interp_mask, ...
                                                                            keep_interp_file, ...
                                                                            root_fname_interp);
         
        % Clean up parallel pool
        % delete(gcp); % commented because it adds 30s-1min of overhead
         params.interpolation.file.exists = true;
        
         % Saves full path to file
         params.interpolation.file.source = mfile_interp.Properties.Source;
    else
        % Load the data if file already exists
        mfile_interp = matfile(params.interpolation.file.source, 'Writable', true);
        mfile_interp_sentinel = [];
    end
        mfile_interp.params = params;
        % Make the file read-only file to avoid corruption
        mfile_interp.Properties.Writable = false;
        
        % Get how many time points we have
        t_dim = 4; % time    
        dtpts = size(mfile_interp.data, t_dim);

%----------------------------- FLOW CALCULATION -------------------------------%
    % Parameters for optical flow-- could be changed, could be parameters
    keep_vel_file    = params.flows.file.keep; % TODO: probably turn into input parameter
    
    % Save flow calculation parameters
    params.flows.dtpts  = dtpts;
    params.flows.grid_size = grid_size;    
    params.interpolation.grid_size = grid_size;

        
    % We open a matfile to store output and avoid huge memory usage
    if isfield(params.flows.file, 'name')
        root_fname_vel = [params.flows.file.name '-temp_flows-' num2str(params.data.slice.id, '%03d')];
    else
        root_fname_vel = ['temp_flows-' num2str(params.data.slice.id, '%03d')];
    end
    [mfile_flow, mfile_flow_sentinel] = create_iomat_file(root_fname_vel, keep_vel_file); 
    params.flows.file.source = mfile_flow.Properties.Source;
    
    % Save masks with convex hulls of the brain
    obj_flows.masks = masks;
    
    
    
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
    
    % Save all params in the flow/velocity file 
    mfile_flow.params = params;
    
    % Here is where the magic happens
    flows3d_estimate_hs3d_flow(mfile_interp, mfile_flow, params)

    % Here we get the flows on defined on the nodes -- It adds 30% to the current runtime because it uses ScatterInterpolant
    % Also, the file get larger, but having this additional variable help us with visualisations. 
    % Perhaps consider only returning this file and deleting the gridded flow file.

    mfile_flow = flows3d_get_scattered_flows_parallel(mfile_flow, locs);
    
    % Save original locations, just in case
    mfile_flow.locs = locs;

    % Delete sentinels. If these variable are OnCleanup objects, theln the 
    % files will be deleted.
    delete(mfile_interp_sentinel)    
    delete(mfile_flow_sentinel)
    
%-------------------------- DETECT NULL FLOWS - CRITICAL POINTS ---------------%    
   if params.singularity.detection.enabled
              
       mfile_sings = singularity3d_detection(mfile_flow, params.singularity.detection.threshold); 
       if params.singularity.classification.enabled
%----------------------------- CLASSIFY SINGULARITIES -------------------------%
           %mfile_sings = singularity3d_classify_singularities_parallel(mfile_sings, mfile_flow);
           mfile_sings = singularity3d_classify_parallel(mfile_sings, mfile_flow);             

       end 
      varargout{3} = mfile_sings;

%------------------------------------------------------------------------------%
   end
      varargout{1} = mfile_interp;
      varargout{2} = mfile_flow; 
   
end % function main_neural_flows_hs3d_scatter()
