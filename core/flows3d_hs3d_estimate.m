function  [params, obj_flows, obj_flows_sentinel] = flows3d_hs3d_estimate(params, masks)
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

    % Load interpolated data
    if strcmp(params.data.grid.type, 'unstructured')
        % Load data file
        obj_data = matfile(fullfile(params.interpolation.file.dir, ...
                                    params.interpolation.file.name, ...
                                    'Writable', true);
    else
        obj_data = matfile(fullfile(params.interpolation.file.dir, ...
                                    params.interpolation.file.name, ...
                                    'Writable', true);
    end
%----------------------------- FLOW CALCULATION -------------------------------%
    % Check if we are receiving one slice of the data
    if params.data.slice.enabled
        rng(params.data.slice.id)
        params = generate_slice_filename(params, 'flows') 
    else
        rng(2020)
    end
    
    % Save flow calculation parameters
    [obj_flows, obj_flows_sentinel] = create_iomat_file(params.flows.file.label, ...
                                                        params.general.storage.dir, ...
                                                        params.flows.file.keep); 
    
    % Save masks with convex hulls of the brain
    obj_flows.masks = masks;
    
    % Save grid and masks - needed for singularity tracking and visualisation
    % Consider saving min max values and step, saves memory
    obj_flows.X = obj_data.X;
    obj_flows.Y = obj_data.Y;
    obj_flows.Z = obj_data.Z;
    obj_flows.masks = obj_data.masks;
   
    % Here is where the magic happens
    params = flows3d_hs3d_loop(obj_data, obj_flows, params)
    % Alternative for using structures
    % [params, varargout(obj_flows)] = ..... 

    if params.flows.method.hs3d.nodal_flows.enabled
        % Here we get the flows on defined on the nodes -- It adds 30% to the current runtime because it uses ScatterInterpolant
        % Also, the file gets large, but having this additional variable help us with visualisations. 
        % Perhaps consider only returning this file and deleting the gridded flow file.
        flows3d_get_unstructured_flows_parallel(obj_flows, obj_data.locs, params);
        % Alternative for working with structures
        % [varargout(obj_flows)] = ...
        % Save original locations, just in case
        obj_flows.locs = obj_data.locs;
    end
end % function flows3d_estimate_hs3d()
