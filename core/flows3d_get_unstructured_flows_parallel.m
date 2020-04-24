function [obj_flows] = flows3d_get_unstructured_flows_parallel(obj_flows, locs, params)
% This is a wrapper function for Matlab's ScatteredInterpolant, to obtain the 
% flows values at exactly the centres of gravity of the original brain regions, so as to 
% minimise the errors introduce by different grid resolutions.
%
% ARGUMENTS:
%           obj_flows -- a MatFile handle to the file with the flows
%           locs --  a [num_nodes x 3 ] array with the original locations of known (scattered) data
%    
% OUTPUT:
%           obj_flows : the same MatFile handle, but the file will have a
%           new field 'uxyz', which is an array of size [num_nodes x 3 x tpts]
% 
% USAGE:
%{
    
%}
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer, October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

if nargin < 3
    x_dim_locs = 1;
    y_dim_locs = 2;
    z_dim_locs = 3;
else
    x_dim_locs = params.data.x_dim_locs;
    y_dim_locs = params.data.y_dim_locs;
    z_dim_locs = params.data.z_dim_locs;
end

    %These parameter values are essential
    neighbour_method = 'linear';
    extrapolation_method = 'linear'; 
    
    tpts = params.flows.data.shape.t;
    
    if tpts < 2
        disp('NOTE to self: This will fail because there is only one data timepoint')
    end
    X = obj_flows.X;
    Y = obj_flows.Y;
    Z = obj_flows.Z;
    
    masks = obj_flows.masks; 
    innies_idx = find(masks.innies == true);
    
    X = X(innies_idx);
    Y = Y(innies_idx);
    Z = Z(innies_idx);

   
    % Write dummy data to disk
    obj_flows.uxyz  = zeros([size(locs), tpts]);     
  
    interpolation_3d_storage_expression = 'uxyz(:, :, jdx)';
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @interpolate_flow_step;
    [obj_flows] = spmd_parfor_with_matfiles(tpts, parfun, obj_flows, interpolation_3d_storage_expression);
    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = interpolate_flow_step(idx)
            % Create nan array so the output is in the right shape
            ux = obj_flows.ux(:, :, :, idx);
            uy = obj_flows.uy(:, :, :, idx);
            uz = obj_flows.uz(:, :, :, idx);
            
            data_interpolant_x = scatteredInterpolant(X, Y, Z , ...
                                                      ux(innies_idx), ...
                                                      neighbour_method, ...
                                                      extrapolation_method);
            data_interpolant_y = scatteredInterpolant(X, Y, Z , ...
                                                      uy(innies_idx), ...
                                                      neighbour_method, ...
                                                      extrapolation_method);
                                                
            data_interpolant_z = scatteredInterpolant(X, Y, Z , ...
                                                      uz(innies_idx), ...
                                                      neighbour_method, ...
                                                      extrapolation_method);
                                                

            temp_data = single([data_interpolant_x(locs(:, x_dim_locs), locs(:, y_dim_locs), locs(:, z_dim_locs)), ...
                                data_interpolant_y(locs(:, x_dim_locs), locs(:, y_dim_locs), locs(:, z_dim_locs)), ...
                                data_interpolant_z(locs(:, x_dim_locs), locs(:, y_dim_locs), locs(:, z_dim_locs))]);
    end % function interpolate_flow_step()

end %function flows3d_get_unstructured_flows_parallel()
