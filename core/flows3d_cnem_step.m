function [ux, uy, uz] = flows3d_cnem_step(F1, F2, alpha_smooth, max_iterations, ux, uy, uz, ht, neighbours_matrix, cnem_B)
%% NOTE: NOT WORKING ATM --- This function estimates the velocity components between two subsequent 3D 
% images using the Horn-Schunck optical flow method (HS), but using CNEM for 
% gradients.
%
% ARGUMENTS:
%      - F1, F2      --    two subsequent 3D arrays or 3D image frames
%      - alpha_smooth :    HS smoothness parameter, default value is 1.
%      - max_iterations : max_number of iterations for convergence, default value is 10.
%      - uxo, uyo, uzo: initial estimates of velocity components
%      - inner_triangles: list
% OUTPUT:
%   ux, uy, ux -- 3D arrays with the velocity components along each of the
%                 3 orthogonal axes. 
%neighbours_matrix
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer April 2020
% USAGE:
%{
    
%}
%   REFERENCES:
%   B. K. Horn and B. G. Schunck, Determining optical flow,
%   USA, Tech. Rep., 1980.
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           

% Calculate derivatives -- hx, hy, hz not used 
[Ix, Iy, Iz, It] = flows3d_cnem_calculate_partial_derivatives(F1, F2, ht, cnem_B);

% one_ring_neighbours_matrix = nodes x 6 or 5
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for tt=1:max_iterations
        ux_avg = calculate_local_average(ux, neighbours_matrix);
        uy_avg = calculate_local_average(uy, neighbours_matrix);
        uz_avg = calculate_local_average(uz, neighbours_matrix);



        ux = ux_avg - ( Ix.*((Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uy = uy_avg - ( Iy.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uz = uz_avg - ( Iz.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
    end
  

end % function compute_flow_cnem()

function u_avg = calculate_local_average(u, neighbours_matrix)
 
    u_avg = neighbours_matrix * u;

end  %function calculate_local_average
