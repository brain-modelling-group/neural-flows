function [ux, uy, uz] = flows3d_cnem_step(F1, F2, alpha_smooth, max_iterations, ux, uy, uz, inner_triangles, cnem_B)
%% NOTE: NOT WORKING ATM --- This function estimates the velocity components between two subsequent 3D 
% images using the Horn-Schunck optical flow method (HS3D), but using CNEM. 
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
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer September 2019
% USAGE:
%{
    
%}
%   REFERENCES:
%   B. K. Horn and B. G. Schunck, Determining optical flow,
%   USA, Tech. Rep., 1980.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           
if nargin < 3
    alpha_smooth  = 1; 
    max_iterations = 32;    
elseif nargin < 4
    max_iterations = 32;
    
end


% Calculate derivatives -- hx, hy, hz not used 
[Ix, Iy, Iz, It] = flows3d_cnem_calculate_partial_derivatives(F1, F2, ht, cnem_B);

% one_ring_neighbours_matrix = nodes x 6 or 5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND A WAY TO CALCULATE AVERAGE OF NEIGHBOURS

    for tt=1:max_iterations
        % NOTE: averaging may be useful if interpolation is not peformed, 
        % or if the data are noisy. For narrowband signals, the
        % averaging introduces artifacts.
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
