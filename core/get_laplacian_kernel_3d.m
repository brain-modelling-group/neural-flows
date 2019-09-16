function [Gx, Gy, Gz] = get_laplacian_kernel_3d()
% Returns the 3D normalized Laplacian kernel of size [3, 3, 3]
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

end % function get_laplacian_kernel_3d()
