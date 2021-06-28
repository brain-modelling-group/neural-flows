function params = flows3d_perform_local_flow_classification(params)
% Classifies local flow based on:
% + flow curl & divergence properties
% + curvature of streamlines (to be implemented)
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
   
    % Load flow data-writable
    obj_flows = load_iomat_flows(params);
    
    
    if params.general.parallel.enabled
        flows3d_classify_fun = @flows3d_classify_parallel; 
    else
        flows3d_classify_fun = @flows3d_classify_sequential; %NOTE:not implemented yet
        fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Warning:: Sequential classification of local flows has not been implemented!.'))
    end

    % Allocate output and save to file
    [classification_cell_str, classification_cell_num] = flows3d_classify_fun(obj_flows);
    
    % Save classification cells
    obj_flows.flow_classification_str = classification_cell_str;
    obj_flows.flow_classification_num = classification_cell_num;
    obj_flows.flow_classification_count = counts;
    
    if params.flows.quantification.nodal_classification.enabled
        % Here we try to assing a critical point to every node.
        fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started assignment of node-based local flow labels.'))
        params = assign_nodal_local_flow_labels(params);
        fprintf('%s \n\n', strcat('neural-flows:: ', mfilename, '::Info:: Finished assignment of node-based local flow labels.'))
    end
    
    % Disable classification
    params.flows.classification.enabled = false;
     
end % function flows3d_perform_local_flow_classification()
