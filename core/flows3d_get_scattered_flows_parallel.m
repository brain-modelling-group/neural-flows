function [mfile_vel] = flows3d_get_scattered_flows_parallel(mfile_vel, locs)
% This is a wrapper function for Matlab's ScatteredInterpolant, to obtain the 
% flows values at exactly the centres of gravity of the original brain regions, so as to 
% minimise the errors introduce by different grid resolutions.
%
% ARGUMENTS:
%           mfile_vel -- a MatFile handle to the file with the flows, inlcuding the norm of
%                        the flows un which we will use here
%           locs: original locations of known (scattered) data
%    
% OUTPUT:
%       mfile_vel : the same MatFile handle, but the file will have a new field uxyz_sc
% 
% USAGE:
%{
    
%}
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer, October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

    % These parameter values are essential
    neighbour_method = 'natural';
    extrapolation_method = 'none';


    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    tpts = size(mfile_vel, 'ux', 4);
    
    if tpts < 2
        disp('NOTE to self: This will fail because there is only one data point')
    end
    
    in_bdy_mask_idx = find(double(mfile_vel.interp_mask));
    X = mfile_vel.X;
    X = X(in_bdy_mask_idx);
    Y = mfile_vel.Y;
    Y = Y(in_bdy_mask_idx);
    Z = mfile_vel.Z;
    Z = Z(in_bdy_mask_idx);

   
    % Write dummy data to disk
    mfile_vel.uxyz_sc  = zeros([size(locs), tpts]);     

    % Open a pallell pool using all available workers
    %percentage_of_workers = 0.8; % 1 --> all workers, too agressive
    %open_parpool(percentage_of_workers);
    
  
    interpolation_3d_storage_expression = 'uxyz_sc(:, :, jdx)';
    %spmd_parfor_with_matfiles(number_of_things, parfun, temp_fname_obj, storage_expression)
    parfun = @interpolate_step;
    [mfile_vel] = spmd_parfor_with_matfiles(tpts, parfun, mfile_vel, interpolation_3d_storage_expression);
    
    % Child function with access to local scope variables from parent
    % function
    function temp_data = interpolate_step(idx)
            % Create nan array so the output is in the right shape
            ux = mfile_vel.ux(:, :, :, idx);
            uy = mfile_vel.uy(:, :, :, idx);
            uz = mfile_vel.uz(:, :, :, idx);
            
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
