function  [params, varargout] = flows3d_hs3d_estimate(params, masks)
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
        obj_data = matfile(fullfile(params.interpolation.file.dir, ...
                                    params.interpolation.file.name, ...
                                      'Writable', true);
    else
       continue % TODO: Do something for gridded data
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
    
    % Save grid - needed for singularity tracking and visualisation
    % Consider saving min max values and step, saves memory
    obj_flows.X = X;
    obj_flows.Y = Y;
    obj_flows.Z = Z;
   
    % Here is where the magic happens
    flows3d_hs3d_loop(obj_data, obj_flows, params)

    % Here we get the flows on defined on the nodes -- It adds 30% to the current runtime because it uses ScatterInterpolant
    % Also, the file gets large, but having this additional variable help us with visualisations. 
    % Perhaps consider only returning this file and deleting the gridded flow file.

    obj_flows = flows3d_get_unstructured_flows_parallel(obj_flows, params);
    
    % Save original locations, just in case
    mfile_flow.locs = locs;

    % Delete sentinels. If these variable are OnCleanup objects, theln the 
    % files will be deleted.
    delete(mfile_interp_sentinel)    
    delete(mfile_flow_sentinel)
    

    varargout{2} = mfile_flow; 
   
end % function flows3d_estimate_hs3d()
