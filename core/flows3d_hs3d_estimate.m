function  [params, obj_flows, obj_flows_sentinel] = flows3d_hs3d_estimate(params)
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

    % Load interpolated data, or regular data
    switch params.data.grid.type
        case 'unstructured'
            % Presumabaly we performed interpolation of unstructured data
            % and it is now stored in a matfile
            obj_data = load_iomat_interp(params);
        case 'structured'
            % Original data is already a strucutured grid
            obj_data = load_iomat_data(params);
    end
%----------------------------- FLOW CALCULATION -------------------------------%
    % Check if we are receiving one slice of the data
    if params.data.slice.enabled
        rng(params.data.slice.id)
        params = generate_slice_filename(params, 'flows'); 
    else
        rng(2020)
    end
    
    if strcmp(params.flows.file.label, '')
        params.flows.file.label = 'tmp_flows';
    end
    
    % Save flow calculation parameters
    [obj_flows, obj_flows_sentinel] = create_iomat_file(params.flows.file.label, ...
                                                        params.general.storage.dir, ...
                                                        params.flows.file.keep);
    obj_flows_cell = strsplit(obj_flows.Properties.Source, filesep);
    % Save properties of file
    params.flows.file.exists = true;
    params.flows.file.dir  = params.general.storage.dir;
    params.flows.file.name = obj_flows_cell{end};

    % Save masks with convex hulls of the brain
    % Note this will fail if there are no masks here
    if strcmp(params.data.grid.type, 'unstructured')
        masks = obj_data.masks;
        obj_flows.masks = masks;
        obj_flows.locs = obj_data.locs;
    end
    
    % Save grid and masks - needed for singularity tracking and visualisation
    % Consider saving min max values and step, saves memory
    obj_flows.X = obj_data.X;
    obj_flows.Y = obj_data.Y;
    obj_flows.Z = obj_data.Z;
   
    % Here is where the magic happens
    params = flows3d_hs3d_loop(obj_data, obj_flows, params);
    % Alternative for using structures
    % [params, varargout(obj_flows)] = ..... 
    if params.flows.method.hs3d.nodal_flows.enabled
        % Here we get the flows on defined on the nodes -- It adds 30% to the current runtime because it uses ScatterInterpolant
        % Also, the file gets large, but having this additional variable help us with visualisations. 
        % Perhaps consider only returning this file and deleting the gridded flow file.
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started extraction of node-based flows.'))
        flows3d_get_unstructured_flows_parallel(obj_flows, obj_data.locs, params);
        % Alternative for working with structures
        % [varargout(obj_flows)] = ...
        % Save original locations, just in case
        obj_flows.locs = obj_data.locs;
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished extraction of node-based flows.'))

    end
    % Disable flows calculation if we already did it
    params.general.flows.enabled = false;
    params.flows.file.exists = true;
end % function flows3d_estimate_hs3d()
