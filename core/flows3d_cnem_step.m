function [ux, uy, uz] = flows3d_cnem_step(F1, F2, alpha_smooth, max_iterations, uxo, uyo, uzo, inner_tiangles)
%% NOTE: NOT WORKING ATM --- This function estimates the velocity components between two subsequent 3D 
% images using the Horn-Schunck optical flow method (HS3D), but using CNEM. 
%
% ARGUMENTS:
%      - F1, F2      --    two subsequent 3D arrays or 3D image frames
%      - alpha_smooth :    HS smoothness parameter, default value is 1.
%      - max_iterations : max_number of iterations for convergence, default value is 10.
%      - uxo, uyo, uzo: initial estimates of velocity components
%      - hx, hy, hz, ht - space step size and time step size.
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

if ~exist('uxo', 'var') % assume the other do not exist either
  [uxo, uyo, uzo] = flows3d_hs3d_get_initial_flows(F1, isnan(F1));
end

% Intial conditions; 
ux = uxo; 
uy = uyo; 
uz = uzo;


%%%%%%%%%%%%%%%%%%% Create alpha shapes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TODO: pass as parameters because they only need to be calulated once
shpalpha = opts.alpha_radius; % alpha radius; may need tweaking depending on geometry and number of scattered points. 
shp      = alphaShape(locs, shpalpha);

% The boundary of the centroids is an approximation of the cortex
bdy = shp.boundaryFacets;

% Calculate matrix B of cnem
B = flows3d_cnem_get_B_mat(locs, bdy);

% Calculate derivatives -- hx, hy, hz not used 
[Ix, Iy, Iz, It] = flows3d_cnem_calculate_partial_derivatives(F1, F2, hx, hy, hz, ht, B);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND A WAY TO CALCULATE AVERAGE OF NEIGHBOURS

    for tt=1:max_iterations
        % NOTE: averaging may be useful if interpolation is not peformed, 
        % or if the data are noisy. For narrowband signals, the
        % averaging introduces artifacts.
        %ux_avg = nanconvn(ux, avg_filter,'same', edge_corrected_image);
        %uy_avg = nanconvn(uy, avg_filter,'same', edge_corrected_image);
        %uz_avg = nanconvn(uz, avg_filter,'same', edge_corrected_image);



        ux = ux_avg - ( Ix.*((Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uy = uy_avg - ( Iy.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uz = uz_avg - ( Iz.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
    end
  

end % function compute_flow_cnem()
