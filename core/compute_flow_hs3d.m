function [ux, uy, uz] = compute_flow_hs3d(F1, F2, alpha_smooth, max_iterations, uxo, uyo, uzo)
% This function estimates the velocity components between two subsequent 3D 
% images using the Horn-Schunck optical flow method. 
%
%   Description :  
%
%   -F1, F2 :   two subsequent 3D arrays/images or frames
%   -alpha_smooth :    HS smoothness parameter, default value is 1.
%   -max_iterations : max_number of iterations for convergence, default value is 10.
%   -uxInitial, uyInitial, uzInitial : initial flow vectors, default value
%                                     is 0;
%
%   Reference :
%   B. K. Horn and B. G. Schunck, Determining optical ow, Cambridge, MA,
%   USA, Tech. Rep., 1980.
%
%   Author : Mohammad Mustafa, The University of Nottingham and Mirada Medical Limited,
%            Paula Sanz-Leon optimized
%   Published under a Creative Commons Attribution-Non-Commercial-Share Alike
%   3.0 Unported Licence http://creativecommons.org/licenses/by-nc-sa/3.0/
%   
%   June 2012

if nargin < 3
    alpha_smooth  = 1; 
    max_iterations= 16;    
elseif nargin < 4
    max_iterations = 16;
    
end

if ~exist('uxo', 'var') % assume the other do not exist either
  rng(42) % TODO: make it an optional parameter
  a   = -0.125;
  b   =  0.125;
  uxo = a + (b-a).*rand(size(F1));
  uyo = a + (b-a).*rand(size(F1));
  uzo = a + (b-a).*rand(size(F1));
end

% Intial conditions; 
ux = uxo; 
uy = uyo; 
uz = uzo;

% Calculate derivatives
[Ix, Iy, Iz, It] = calculate_derivatives_hsd3(F1, F2);


% Neumann  neighbourhood in 3D - nearest neighbours for averaging 
stencil = zeros(3, 3, 3);

kk=2; % This is where our point of interest is centred along the z-axis

% Averaging filter
stencil(:,:,kk-1) = [0 0 0; 
                     0 1 0; 
                     0 0 0]/6;
                 
stencil(:,:,kk)   = [0 1 0; 
                     1 0 1; 
                     0 1 0]/6;
                 
stencil(:,:,kk+1) = [0 0 0; 
                     0 1 0; 
                     0 0 0]/6;

for i=1:max_iterations
    ux_avg = nanconvn(ux, stencil,'same');
    uy_avg = nanconvn(uy, stencil,'same');
    uz_avg = nanconvn(uz, stencil,'same');
    
    ux = ux_avg - (Ix.*((Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
        ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
    
    uy = uy_avg - ( Iy.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
        ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
    
    uz = uz_avg - ( Iz.*( (Ix.*ux_avg) + (Iy.*uy_avg) + (Iz.*uz_avg) + It))...
        ./ ( alpha_smooth.^2 + Ix.^2 + Iy.^ 2 + Iz.^ 2);
end

end

