function [Ix, Iy, Iz, It] = calculate_derivatives_hsd3(F1, F2, hx, hy, hz, ht, operator_3d)
% New name: flows3d_calculate_derivatives()
%%This fuction computes 3D+t partial derivatives between two 3D image frames. 
% This function basically does the same as imgradientxyz, but it also
% calculates the temporal derivative and returns correctly normalised
% derivatives.
%
% ARGUMENTS:
%       F1, F2      --    two subsequent 3D arrays or 3D image frames
%       operator_3d --   a function handle with the operator to use. 
%                        Default is @get_sobel_3d_operator
% OUTPUT:
%   Ix, Iy, Iz, It  --  derivatives along X, Y, Z and T axes respectively
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2018
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
    
    if nargin < 7 
        operator_3d = @get_sobel_3d_operator;
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

end % function calculate_derivatives_hsd3()

function [Gx, Gy, Gz] = get_sobel_3d_operator()
 %TODO: move to standalone function
% Returns the 3D Normalized Sobel kernels
% Matlab has a Sobel operator with slightly different weights,  
% but I like these weights better
        
    norm_factor = 44; % sum(abs(G_i(:))); I just happen to know it's 44
    Gx(:,:,1) = [-1  0  1; -3  0  3; -1  0  1];
    Gx(:,:,2) = [-3  0  3; -6  0  6; -3  0  3];
    Gx(:,:,3) = [-1  0  1; -3  0  3; -1  0  1];
    Gx = Gx./norm_factor;

    Gz(:,:,1) = [-1 -3 -1;  0  0  0;  1  3  1];
    Gz(:,:,2) = [-3 -6 -3;  0  0  0;  3  6  3];
    Gz(:,:,3) = [-1 -3 -1;  0  0  0;  1  3  1];
    Gz = Gz./norm_factor;

    Gy(:,:,1) = [-1 -3 -1; -3 -6 -3; -1 -3 -1];
    Gy(:,:,2) = [ 0  0  0;  0  0  0;  0  0  0];
    Gy(:,:,3) = [ 1  3  1;  3  6  3;  1  3  1];
    Gy = Gy./norm_factor;
        
end % function get_sobel_3d_operator()

function [Gx, Gy, Gz] = get_laplacian_3d_operator()
    %TODO: move to standalone function
    Gx = zeros(3,3,3); 
    Gy = Gx; 
    Gz = Gx;
    
    Gx(:,:,1) = [-1 0 1; -2 0 2; -1 0 1]; 
    Gx(:,:,2) = [-1 0 1; -2 0 2; -1 0 1]; 
    Gx(:,:,3) = [-1 0 1; -2 0 2; -1 0 1]; 
    Gx = Gx./sum(abs(Gx(:)));

    Gy(:,:,1) = Gx(:, :, 1)';
    Gy(:,:,2) = Gx(:, :, 2)';
    Gy(:,:,3) = Gx(:, :, 3)';
    
    Gz(:,:,1) = [-1 -2 -1; -1 -2 -1; -1 -2 -1]; 
    Gz(:,:,2) = [ 0  0  0;  0  0  0;  0  0  0]; 
    Gz(:,:,3) = [ 1  2  1;  1  2  1;  1  2  1]; 
    Gz = Gz./sum(abs(Gz(:)));

end % function get_laplacian_3d_operator()
