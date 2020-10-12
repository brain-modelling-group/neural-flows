function [Ix, Iy, Iz, It] = flows3d_hs3d_calculate_partial_derivatives(F1, F2, hx, hy, hz, ht, operator_3d)
% New name: flows3d_calculate_derivatives_hs3d()
% This fuction computes 3D+t partial derivatives between two 3D image frames,
% and is meant to be used by the Horn-Schunck algotithm
% This function basically does the same as imgradientxyz, but it also
% calculates the temporal derivative and returns correctly normalised
% derivatives.
%
% ARGUMENTS:
%       F1, F2      --    two subsequent 3D arrays or 3D image frames
%       operator_3d --   a function handle with the operator to use. 
%                        Default is @get_sobel_kernel_3d, but could be 
%                          @get_laplacian_kernel_3d or any other
%                          differential kernel obtained via matlab's fspecial3
% OUTPUT:
%   Ix, Iy, Iz, It  --  partial derivatives along X, Y, Z and T axes respectively
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer, December 2018
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
    
    if nargin < 7 
        operator_3d = @get_sobel_kernel_3d;
    end

    % Sobel 3D Kernel along X, Y and Z direction
    [Gx, Gy, Gz] = operator_3d();
    
    % Temporal kernel size
    kt_size = 3;
    Gt = ones(kt_size, kt_size, kt_size);
    Gt = Gt./sum(abs(Gt(:)));
   
    % Spatial derivatives are computed as the average of 
    % the two image/frame gradients along each direction,
    % thus the magic number 0.5 in front of Ix, Iy, Iz
    Ix = (0.5*(convn(F1, Gx, 'same') + convn(F2,  Gx, 'same')))/hx;
    Iy = (0.5*(convn(F1, Gy, 'same') + convn(F2,  Gy, 'same')))/hy;
    Iz = (0.5*(convn(F1, Gz, 'same') + convn(F2,  Gz, 'same')))/hz;
    It = ((convn(F1, Gt, 'same') - convn(F2,  Gt, 'same')))/ht;

end % function flows3d_calculate_partialderivatives_hsd3()
