function [ux, uy, uz] = flows3d_hs3d_step(F1, F2, alpha_smooth, max_iterations, ux, uy, uz, hx, hy, hz, ht, boundary_mask)
%% This function estimates the velocity components between two subsequent 3D 
% images using the Horn-Schunck optical flow method (HS3D). 
%
% ARGUMENTS:
%      - F1, F2      --    two subsequent 3D arrays or 3D image frames
%      - alpha_smooth :    HS smoothness parameter, default value is 1.
%      - max_iterations : max_number of iterations for convergence, default value is 10.
%      - uxo, uyo, uzo: initial estimates of velocity components
%      - hx, hy, hz, ht - space step size and time step size.
%      - boundary_mask  -- a logic 3D array defining the mask so  that we set 
%                          the derivatives to zero where the mask is true
% OUTPUT:
%   ux, uy, ux -- 3D arrays with the velocity components along each of the
%                 3 orthogonal axes. 
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer December 2018
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

% Calculate derivatives
[Ix, Iy, Iz, It] = flows3d_hs3d_calculate_partial_derivatives(F1, F2, hx, hy, hz, ht);

% von Neumann boundary conditions -- set derivatives to zero
Ix(boundary_mask) = 0;
Iy(boundary_mask) = 0;
Iz(boundary_mask) = 0;
It(boundary_mask) = 0;


avg_filter = vonneumann_neighbourhood_3d();
% The average should not include the central point
%avg_filter = fspecial3('average', 3);
%avg_filter(2, 2, 2) = 0;


% Call nanconvn with the parametes we're going to use to get the edge 
% correction image, and avoid further calls in the iterations.
% TODO: Probably a good idea to do this before calling the optical flow
% routine
[~, edge_corrected_image] = nanconvn(F1, avg_filter, 'same');
%edge_corrected_image = ones(size(F1));
                 
% TODO: replace FOR by WHILE after introducing the Charbonnier
% penalty/tolerance as in Neuropatt

    for tt=1:max_iterations
       [ux, uy, uz] = horn_schunk_step(ux, uy, uz);         
    end
     
    
function [ux, uy, uz] = horn_schunk_step(ux, uy, uz)
        % NOTE: averaging may be useful if interpolation is not peformed, 
        % or if the data are noisy. For narrowband signals, the
        % averaging introduces artifacts.
        ux_avg = nanconvn(ux, avg_filter,'same', edge_corrected_image);
        uy_avg = nanconvn(uy, avg_filter,'same', edge_corrected_image);
        uz_avg = nanconvn(uz, avg_filter,'same', edge_corrected_image);
        % NOTE: the lines below do the job for a full grid, but they do not
        % work for the case of an odd object embedde din the grid, cause imfilter
        % does not seem to handle NaNs.
        %ux_avg = imfilter(ux, avg_filter, 'replicate', 'same', 'conv');
        %uy_avg = imfilter(uy, avg_filter, 'replicate', 'same', 'conv');
        %uz_avg = imfilter(uz, avg_filter, 'replicate', 'same', 'conv');


        ux = ux_avg - ( Ix.*((Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uy = uy_avg - ( Iy.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uz = uz_avg - ( Iz.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
                       ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
        
end % function horn_schunk_step
  

end % function flows3d_hs3d_step()

function avg_filter = vonneumann_neighbourhood_3d()
    % Neumann neighbourhood in 3D - 6-nearest neighbours for averaging 
    avg_filter = zeros(3, 3, 3);

    % This is where our point of interest is centred along the z-axis in a vonNeumann neighbourhood 
    kk=2; 

    % Averaging filter over space
    avg_filter(:, :, kk-1) = [0  0  0; 
                              0  1  0; 
                              0  0  0];

    avg_filter(:, :, kk)   = [0  1  0; 
                              1  0  1; 
                              0  1  0];

    avg_filter(:, :, kk+1) = [0  0  0; 
                              0  1  0; 
                              0  0  0];
    avg_filter = avg_filter./sum(abs(avg_filter(:)));

end % function vonneuman_neighbourhood_3d()
