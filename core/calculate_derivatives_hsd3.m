function [Ix, Iy, Iz, It] = calculate_derivatives_hsd3(F1, F2, operator_3d)
%This fuction computes 3D derivatives between two 3D images. 
%There are four derivatives here; three along X, Y, Z axes and one along
%timeline axis.
%
%   - F1, F2 :   two subsequent images or frames
%   - hx, hy, hz -  assumed to be 1
%   - ht         -  assumed to be 1
%   - Ix, Iy, Iz : derivatives along X, Y and Z axes respectively
%   - It         : derivatives along timeline axis
%             Modified - Paula Sanz-Leon optimized, handles nans
    
    if nargin < 3 
        operator_3d = @get_sobel_3d_operator;
    end

    % Sobel 3D Kernel along X, Y and Z direction
    [Gx, Gy, Gz] = operator_3d();

    Gt = ones(3, 3, 3);
    % Make these parameters
    hx = 1; % 1 mm
    hy = 1; % 1 mm
    hz = 1; % 1 mm
    ht = 1; % 1 ms

    % Spatial derivatives are computed as the average of 
    % the two image/frame gradients along each direction
    

    Ix = 0.5 * (convn(F1, Gx, 'same') + convn(F2, Gx, 'same'));
    Iy = 0.5 * (convn(F1, Gy, 'same') + convn(F2, Gy, 'same'));
    Iz = 0.5 * (convn(F1, Gz, 'same') + convn(F2, Gz, 'same'));
    It = 0.5 * (convn(F1, Gt, 'same') - convn(F2, Gt, 'same'));

end % function calculate_derivatives_hsd3()

function [Gx, Gy, Gz] = get_sobel_3d_operator()
% Returns the 3D Normalized Sobel kernels
        
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
    Gx = zeros(3,3,3); 
    Gy = Gx; 
    Gz = Gx;
    
    Gx(:,:,1) = [-1 0 1; -2 0 2; -1 0 1]; 
    Gx(:,:,2) = [-1 0 1; -2 0 2; -1 0 1]; 
    Gx(:,:,3) = [-1 0 1; -2 0 2; -1 0 1]; 
    Gx = Gx./sum(abs(Gx(:)));

    Gy(:,:,1) = Gx(:,:,1)';
    Gy(:,:,2) = Gx(:,:,2)';
    Gy(:,:,3) = Gx(:,:,3)';
    
    Gz(:,:,1) = [-1 -2 -1; -1 -2 -1; -1 -2 -1]; 
    Gz(:,:,2) = [ 0  0  0;  0  0  0;  0  0  0]; 
    Gz(:,:,3) = [ 1  2  1;  1  2  1;  1  2  1]; 
    Gz = Gz./sum(abs(Gz(:)));

end

 