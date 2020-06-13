function  [params, obj_streams, obj_streams_sentinel] = streams3d_trace(params)
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
%     Paula Sanz-Leon, QIMR Berghofer, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    % Load flow data
    obj_flows = load_iomat_flows(params);
%----------------------------- STREAMLINES CALCULATION -------------------------%
    % Check if we are receiving one slice of the data
    if params.data.slice.enabled
        rng(params.data.slice.id)
        params = generate_slice_filename(params, 'streams'); 
    else
        rng(2020)
    end
    
    if strcmp(params.streamlines.file.label, '')
        params.streamlines.file.label = 'tmp_streams';
    end
    
    % Save flow calculation parameters
    [obj_streams, obj_streams_sentinel] = create_iomat_file(params.streamlines.file.label, ...
                                                            params.general.storage.dir, ...
                                                            params.streamlines.file.keep);
    obj_streams_cell = strsplit(obj_streams.Properties.Source, filesep);
    % Save properties of file
    params.streamlines.file.exists = true;
    params.streamlines.file.dir  = params.general.storage.dir;
    params.streamlines.file.name = obj_streams_cell{end};

    % Save masks with convex hulls of the brain
    % Note this will fail if there are no masks here
    if strcmp(params.data.grid.type, 'unstructured')
        masks = obj_flows.masks;
        obj_streams.masks = masks;
        obj_streams.locs = obj_flows.locs;
    end
       
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started tracing of streamlines.'))
    % Check if it's phase-based streams, or amplitude based
    % If it's amplitude-based it can be nodal or gridded
    switch params.streamlines.grid.type
        case 'unstructured'
            streams3d_tracing_cnem(obj_streams, obj_flows, params)
        case 'structured'
            streams3d_tracing_mlab(obj_streams, obj_flows, params)
    end
    obj_streams.xyz_lims = obj_flows.xyz_lims; 
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished tracing of streamlines.'))

    % Disable streams calculation if we already did it
    params.general.streamlines.enabled = false;
end % function streams3d_trace()
