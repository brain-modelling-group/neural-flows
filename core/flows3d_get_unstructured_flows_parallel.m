function [obj_flows] = flows3d_hs3d_get_unstructured_flows_parallel(obj_flows, locs)
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
%           new field 'uxyz_sc', which is an array of size [num_nodes x 3 x tpts]
% 
% USAGE:
%{
    
%}
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer, October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    %These parameter values are essential
    neighbour_method = 'linear';
    extrapolation_method = 'linear'; 
    
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    tpts = size(obj_flows, 'ux', 4);
    
    if tpts < 2
        disp('NOTE to self: This will fail because there is only one data point')
    end
    X = obj_flows.X;
    Y = obj_flows.Y;
    Z = obj_flows.Z;
    
    in_bdy_mask_idx = find(obj_flows.in_bdy_mask == true);
    
    
    X = X(in_bdy_mask_idx);
    Y = Y(in_bdy_mask_idx);
    Z = Z(in_bdy_mask_idx);

   
    % Write dummy data to disk
    obj_flows.uxyz_sc  = zeros([size(locs), tpts]);     

    %Open a pallell pool using all available workers
    %percentage_of_workers = 0.5; % 1 --> all workers, too agressive
    %open_parpool(percentage_of_workers);
    
  
    interpolation_3d_storage_expression = 'uxyz_sc(:, :, jdx)';
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @interpolate_step;
    [obj_flows] = spmd_parfor_with_matfiles(tpts, parfun, obj_flows, interpolation_3d_storage_expression);
    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = interpolate_step(idx)
            % Create nan array so the output is in the right shape
            ux = obj_flows.ux(:, :, :, idx);
            uy = obj_flows.uy(:, :, :, idx);
            uz = obj_flows.uz(:, :, :, idx);
            
            data_interpolant_x = scatteredInterpolant(X, Y, Z , ...
                                                    ux(in_bdy_mask_idx), ...
                                                    neighbour_method, ...
                                                    extrapolation_method);
            data_interpolant_y = scatteredInterpolant(X, Y, Z , ...
                                                    uy(in_bdy_mask_idx), ...
                                                    neighbour_method, ...
                                                    extrapolation_method);
                                                
            data_interpolant_z = scatteredInterpolant(X, Y, Z , ...
                                                    uz(in_bdy_mask_idx), ...
                                                    neighbour_method, ...
                                                    extrapolation_method);
                                                

            temp_data = single([data_interpolant_x(locs(:, x_dim), locs(:, y_dim), locs(:, z_dim)), ...
                                data_interpolant_y(locs(:, x_dim), locs(:, y_dim), locs(:, z_dim)), ...
                                data_interpolant_z(locs(:, x_dim), locs(:, y_dim), locs(:, z_dim))]);
    end

end %flows3d_get_scattered_flows_parallel()
