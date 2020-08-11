function  [params, obj_flows, obj_flows_sentinel] = flows3d_cnem_estimate(params)
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
%     Paula Sanz-Leon, QIMR Berghofer, April 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    % Load original unstructured data saved in a matfile
    [obj_data, params] = load_iomat_data(params);

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

    % Save some things in the flow file too
    if ~isprop(obj_data, 'masks')
        get_convex_hull(obj_data, params.data.boundary.alpha_radius, 1:params.data.shape.nodes, []);
    end
    masks = obj_data.masks;
    obj_flows.masks = masks;
    obj_flows.locs = obj_data.locs;
    locs = obj_data.locs;

    % Here is where the magic happens -- assumes data input is always
    % amplitude, we calculate phases internally
    switch params.flows.method.data.mode
        case 'phase'
             params = flows3d_cnem_phase(obj_data, obj_flows, params);
        case 'amplitude'
             params = flows3d_cnem_amplitude(obj_data, obj_flows, params);
        otherwise
             error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown case of grid. Options: {"structured", "unstructured"}'); 
    end
    
    % Get
    xyz_lims{1} = [min(locs(:, 1)) max(locs(:, 1))];
    xyz_lims{2} = [min(locs(:, 2)) max(locs(:, 2))];
    xyz_lims{3} = [min(locs(:, 3)) max(locs(:, 3))];
    obj_flows.xyz_lims = xyz_lims; 
        
    % Alternative for using structures
    % [params, varargout(obj_flows)] = ..... 
    
    % Disable flows calculation if we already did it
    params.flows.enabled = false;
    params.flows.file.exists = true;
end % function flows3d_estimate_hs3d()
