function [Ix, Iy, Iz, It] = calculate_derivatives_hsd3(F1, F2)
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


    % Sobel 3D Kernel along X, Y and Z direction
    [Gx, Gy, Gz] = get_sobel_3d_operator();

    Gt = ones(3, 3, 3);


    % Spatial derivatives are computed as the average of 
    % the two image/frame gradients along each direction
    Ix = 0.5 * (nanconvn(F1, Gx, 'same') + nanconvn(F2, Gx, 'same'));
    Iy = 0.5 * (nanconvn(F1, Gy, 'same') + nanconvn(F2, Gy, 'same'));
    Iz = 0.5 * (nanconvn(F1, Gz, 'same') + nanconvn(F2, Gz, 'same'));
    It = 0.5 * (nanconvn(F1, Gt, 'same') - nanconvn(F2, Gt, 'same'));

end % function calculate_derivatives_hsd3()

function [Gx, Gy, Gz] = get_sobel_3d_operator()
% Returns the 3D Normalized Sobel kernels
        
    norm_factor = 44; % sum(abs(G_i(:))); I just happen to know it's 44
    Gx(:,:,1) = [-1  0  1; -3  0  3; -1  0  1];
    Gx(:,:,2) = [-3  0  3; -6  0  6; -3  0  3];
    Gx(:,:,3) = [-1  0  1; -3  0  3; -1  0  1];
    Gx = Gx./norm_factor;

    Gy(:,:,1) = [-1 -3 -1;  0  0  0;  1  3  1];
    Gy(:,:,2) = [-3 -6 -3;  0  0  0;  3  6  3];
    Gy(:,:,3) = [-1 -3 -1;  0  0  0;  1  3  1];
    Gy = Gy./norm_factor;

    Gz(:,:,1) = [-1 -3 -1; -3 -6 -3; -1 -3 -1];
    Gz(:,:,2) = [ 0  0  0;  0  0  0;  0  0  0];
    Gz(:,:,3) = [ 1  3  1;  3  6  3;  1  3  1];
    Gz = Gz./norm_factor;
        
end % function get_sobel_3d_operator()

 