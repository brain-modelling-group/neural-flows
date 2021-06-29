function obj_streams = streams3d_tracing_mlab_parallel(obj_flows, obj_streams, params)
% This is a wrapper function for Matlab's streams3 using a parfor along the temporal dimension. 
% NOTE: Only works for iomat files, not structures
% ARGUMENTS:
%
% AUTHOR:   
%     Paula Sanz-Leon, QIMR Berghofer June 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    tpts = params.flows.data.shape.t;
    %obj_streams.streamlines(1, tpts) = [];


    % Get some useful information for what we're about to do
    masks = obj_flows.masks;
    innies_idx = find(masks.innies == true);
    outties_idx = find(masks.innies == false);
    time_step = params.streamlines.tracing.step_size; % fake time step for streamline tracing
    max_stream_length = params.streamlines.tracing.max_stream_length;
    tpts = params.flows.data.shape.t;

    % Get seeding locations
    X0 = obj_flows.X;
    Y0 = obj_flows.Y;
    Z0 = obj_flows.Z;

    seeding_locs = get_seeding_locations_3d_slice(X0(innies_idx), Y0(innies_idx), Z0(innies_idx), ...
                                                  params.streamlines.tracing.seeding_points.modality, ...
                                                  params.streamlines.tracing.seeding_points.seed);
    % Save seeding locations & grid
    obj_streams.seeding_locs = seeding_locs;
    obj_streams.X = obj_flows.X;
    obj_streams.Y = obj_flows.Y;
    obj_streams.Z = obj_flows.Z;


    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started parallel tracing of streamlines.'))              
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @tracing_mlab_step;
    streamtracing_3d_storage_expression = 'streamlines(1, jdx)';
    [obj_streams] = spmd_parfor_with_matfiles(tpts, parfun, obj_streams, streamtracing_3d_storage_expression);
    
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished parallel tracing of streamlines.'))
    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = tracing_mlab_step(idx)
    % Load frame -- NOTE: maybe unnecessary step
    ux = obj_flows.ux(:, :, :, idx);
    uy = obj_flows.uy(:, :, :, idx); 
    uz = obj_flows.uz(:, :, :, idx); 

    % Set NaNs to zero -- NOTE: maybe unnecessary step
    ux(outties_idx) = 0;
    uy(outties_idx) = 0;
    uz(outties_idx) = 0;

    verts = stream3(obj_flows.X, obj_flows.Y, obj_flows.Z, ...
                    ux, uy, uz, ...
                    seeding_locs.X, ...
                    seeding_locs.Y, ...
                    seeding_locs.Z, [time_step, max_stream_length]);
    temp_data.paths = verts;             
    end % function tracing_mlab_step())

end % function streams3d_tracing_mlab
