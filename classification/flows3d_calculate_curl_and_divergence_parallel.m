function  [params, obj_flows] = flows3d_calculate_curl_and_divergence_parallel(params)
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
%     Paula Sanz-Leon, QIMR Berghofer, April 2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

% Load flow data
obj_flows = load_iomat_flows(params);
%----------------------------- CULR AND DIVERGENCE CALCULATION -------------------------------%

% Write dummy data to disk to create matfile
obj_flows.local_flow_class(params.interpolation.data.shape.y, ...
                           params.interpolation.data.shape.x, ...
                           params.interpolation.data.shape.z, ...
                           tpts) = 0;

    % Define local variables
    locs = obj_flows.locs;
    
    fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started classification of local flows.'))              
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @local_flow_step;
    loca_flow_3d_storage_expression = 'local_flow_class(:, :, :, jdx)';
    [obj_flows] = spmd_parfor_with_matfiles(tpts, parfun, obj_flows, loca_flow_3d_storage_expression);
    
    fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished classification of local flows.'))
    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = local_flow_step(idx)
            % Create nan array so the output is in the right shape
            temp_data = nan(size(X));
            % Curl magnitude
            cav  = curl(X, Y, Z, obj.flows.ux(:, :, :, idx), ...
                                 obj.flows.uy(:, :, :, idx), ...
                                 obj.flows.uz(:, :, :, idx));
            % Divergence magnitude
            div_mag = divergence(X, Y, Z, obj.flows.ux(:, :, :, idx),...
                                          obj.flows.uy(:, :, :, idx),...
                                          obj.flows.uz(:, :, :, idx));

            temp_data(mask) = single(data_interpolant(X(mask).', Y(mask).', Z(mask).'));
    end % interpolate_step()

end % function flows3d_calculate_curl_and_divergence_parallel()
