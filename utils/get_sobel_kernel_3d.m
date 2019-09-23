function [Gx, Gy, Gz] = get_sobel_kernel_3d()
% Returns the 3D normalized Sobel kernel of size [3, 3, 3]
% Matlab has a Sobel operator with slightly different weights,  
% but I like these weights better
        
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
