function [ux, uy, uz] = compute_flow_hs3d(F1, F2, alpha_smooth, max_iterations, uxo, uyo, uzo)
% This function estimates the velocity components between two subsequent 3D 
% images using the Horn-Schunck optical flow method. 
%
%   Description :  
%
%   -F1, F2 :   two subsequent 3D arrays/images or frames
%   -alpha_smooth :    HS smoothness parameter, default value is 1.
%   -max_iterations : max_number of iterations for convergence, default value is 10.
%   -uxInitial, uyInitial, uzInitial : 
%
%   REFRENCES:
%   B. K. Horn and B. G. Schunck, Determining optical flow, Cambridge, MA,
%   USA, Tech. Rep., 1980.
%
%  Paula Sanz-Leon optimized
   

if nargin < 3
    alpha_smooth  = 1; 
    max_iterations = 32;    
elseif nargin < 4
    max_iterations = 32;
    
end

if ~exist('uxo', 'var') % assume the other do not exist either
  rng(42) % TODO: make it an optional parameter
  a   = -0.125;
  b   =  0.125;
  uxo = a + (b-a).*rand(size(F1));
  uyo = a + (b-a).*rand(size(F1));
  uzo = a + (b-a).*rand(size(F1));
  uxo(isnan(F1)) = NaN;
  uyo(isnan(F1)) = NaN;
  uzo(isnan(F1)) = NaN;

end

% Intial conditions; 
ux = uxo; 
uy = uyo; 
uz = uzo;


% Calculate derivatives
[Ix, Iy, Iz, It] = calculate_derivatives_hsd3(F1, F2);


% Neumann neighbourhood in 3D - 6-nearest neighbours for averaging 
avg_filter = zeros(3, 3, 3);

kk=2; % This is where our point of interest is centred along the z-axis

% Averaging filter
avg_filter(:,:,kk-1) = [0 0 0; 
                        0 1 0; 
                        0 0 0]/6;
                 
avg_filter(:,:,kk)   = [0 1 0; 
                       1 0 1; 
                       0 1 0]/6;
                 
avg_filter(:,:,kk+1) = [0 0 0; 
                        0 1 0; 
                        0 0 0]/6;

% Call nanconvn with the parametes we're going to use to get the edge 
% correction image, and avoid further calls in the iterations.
% TODO: Probably a good idea to do this before calling the optical flow
% routine
[~, edge_corrected_image] = nanconvn(F1, avg_filter, 'same');                
                 
% TODO: replace FOR by WHILE after introducing the Charbonnier
% penalty/tolerance as in Neuropatt

    for tt=1:max_iterations
        ux_avg = nanconvn(ux, avg_filter,'same', edge_corrected_image);
        uy_avg = nanconvn(uy, avg_filter,'same', edge_corrected_image);
        uz_avg = nanconvn(uz, avg_filter,'same', edge_corrected_image);

        ux = ux_avg - (Ix.*((Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
            ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uy = uy_avg - ( Iy.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
            ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);

        uz = uz_avg - ( Iz.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
            ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
    end


end

