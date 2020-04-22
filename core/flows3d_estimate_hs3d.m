function  [params, varargout] = flows3d_estimate_hs3d(params, masks)
% ARGUMENTS:
%           
%%    
% OUTPUT:
%      params:
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
        rng(params.data.slice.id)
        params = generate_slice_filename(params, 'flows') 
    else
        rng(2020)
    end


    % Load interpolated data
    if strcmp(params.data.grid.type, 'unstructured')
        obj_interp = matfile(fullfile(params.interpolation.file.dir, ...
                                      params.interpolation.file.name, ...
                                      'Writable', true);
    else
       continue % TODO: Do something for gridded data
    end

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
    % Also, the file gets large, but having this additional variable help us with visualisations. 
    % Perhaps consider only returning this file and deleting the gridded flow file.

    mfile_flow = flows3d_get_scattered_flows_parallel(mfile_flow, locs);
    
    % Save original locations, just in case
    mfile_flow.locs = locs;

    % Delete sentinels. If these variable are OnCleanup objects, theln the 
    % files will be deleted.
    delete(mfile_interp_sentinel)    
    delete(mfile_flow_sentinel)
    

    varargout{2} = mfile_flow; 
   
end % function flows3d_estimate_hs3d()
