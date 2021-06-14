function params = flows3d_classify_local_flows(params)
% Classifies local flow based on curl & divergence properties
% ARGUMENTS:
%            params -- structure with input parameters
% OUTPUT:
%            params -- structure with input parameters
% REQUIRES:
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer April 2021
% USAGE:
%{
    
%}
   
    % Load singularity data- writable
    obj_flows = load_iomat_flows(params);

    % Get shape of flow arrays
    tpts = params.flows.data.shape.t;
    grid_size = [params.flows.data.shape.y, params.flows.data.shape.x, params.flows.data.shape.z];

    

    % Allocate output and save to file
    % XXXX = flows3d_classify_fun(nullflow_points3d, params);
    
    % Save classification cells
    obj_flows.classification_str = classification_cell_str;
    obj_singularity.classification_num = classification_cell_num;
    
    if params.singularity.quantification.nodal_occupancy.enabled
        % Here we try to assing a critical point to every node.
        fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started classification of local flows.'))
        params = analyse_nodal_singularity_occupancy(params);
        fprintf('%s \n\n', strcat('neural-flows:: ', mfilename, '::Info:: Finished classification of local flows.'))
    end
    
    % Disable classification
    params.flows.classification.enabled = false;
    
end % function flows3d_classify()
