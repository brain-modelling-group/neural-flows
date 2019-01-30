function [ Ix, Iy, Iz, It ] = calculate_derivatives_hsd3(F1, F2, stencil_size)
%This fuction computes 3D derivatives between two 3D images. 
%
%   Description :
%  
%   There are four derivatives here; three along X, Y, Z axes and one along
%   timeline axis.
%
%   - F1, F2 :   two subsequent images or frames
%   - hx, hy, hz -  assumed to be 1
%   - ht         -  assumed to be 1
%   - Ix, Iy, Iz : derivatives along X, Y and Z axes respectively
%   - It         : derivatives along timeline axis
%   - stencil_size : size of the finite difference operator used in convolution
%                   If stencil_size = 2; backward differences
%                   If stencil_size = 3; central differences
%   AUTHORS : Original - Mohammad Mustafa, The University of Nottingham and Mirada Medical Limited,
%             Modified - Paula Sanz-Leon optimized, handles nans

% Use central differences by default
    if nargin < 3
        stencil_size = 3;
    end

    if stencil_size == 2
        Gx = zeros(2,2,2);
        Gx(:,:,1) = [-1 1; 
                     -1 1 ]; 
        Gx(:,:,2) = [-1 1; 
                     -1 1 ];
        Gx = Gx/4;

        Gy = zeros(2,2,2);
        Gy(:,:,1) = [-1 -1; 
                      1  1]; 
        Gy(:,:,2) = [-1 -1; 
                      1  1 ];
        Gy = Gy/4;

        Gz = zeros(2,2,2);
        Gz(:,:,1) = [-1 -1; 
                     -1 -1 ]; 
        Gz(:,:,2) = [1 1; 
                     1 1 ];
        Gz = Gz/4;

        Gt = ones(2, 2, 2);

        % Spatial derivatives are computed as the average of 
        % the gradients along each direction
        Ix = 0.5 * (nanconvn(F1, Gx) + nanconvn(F2, Gx));
        Iy = 0.5 * (nanconvn(F1, Gy) + nanconvn(F2, Gy));
        Iz = 0.5 * (nanconvn(F1, Gz) + nanconvn(F2, Gz));
        It = 0.5 * (nanconvn(F1, Gt) - nanconvn(F2, Gt));

        % Adjusting sizes
        Ix = Ix(1:size(Ix,1)-1, 1:size(Ix,2)-1, 1:size(Ix,3)-1);
        Iy = Iy(1:size(Iy,1)-1, 1:size(Iy,2)-1, 1:size(Iy,3)-1);
        Iz = Iz(1:size(Iz,1)-1, 1:size(Iz,2)-1, 1:size(Iz,3)-1);
        It = It(1:size(It,1)-1, 1:size(It,2)-1, 1:size(It,3)-1);


    elseif stencil_size==3
        % Sobel gradient operators
        Gx = zeros(3, 3, 3); 
        Gy = Gx; 
        Gz = Gx;
        
        % Gradient operator along X
        Gx(:,:,1) = [-1 0 1; 
                     -2 0 2; 
                     -1 0 1];
                 
        Gx(:,:,2) =  Gx(:,:,1);
        Gx(:,:,3) =  Gx(:,:,1);
        Gx=Gx/4;
        
        % Gradient operator along Y
        Gy(:,:,1) = Gx(:,:,1)';
        Gy(:,:,2) = Gx(:,:,2)';
        Gy(:,:,3) = Gx(:,:,3)';
        
        % Gradient operator along Z
        Gz(:,:,1) = [-1 -2 -1; 
                     -1 -2 -1; 
                     -1 -2 -1]; 
        Gz(:,:,2) = [ 0  0  0; 
                      0  0  0; 
                      0  0  0]; 
        Gz(:,:,3) = [ 1  2  1; 
                      1  2  1; 
                      1  2  1]; 
        Gz = Gz/4;

        Gt = ones(3, 3, 3);
        Gt = Gt/1;

        % Computing derivatives
        Ix = 0.5 * (nanconvn(F1,Gx) + nanconvn(F2,Gx));
        Iy = 0.5 * (nanconvn(F1,Gy) + nanconvn(F2,Gy));
        Iz = 0.5 * (nanconvn(F1,Gz) + nanconvn(F2,Gz));
        It = 0.5 * (nanconvn(F1,Gt) - nanconvn(F2,Gt));

        % Adjusting sizes
        Ix = Ix(2:size(Ix,1)-1, 2:size(Ix,2)-1, 2:size(Ix,3)-1);
        Iy = Iy(2:size(Iy,1)-1, 2:size(Iy,2)-1, 2:size(Iy,3)-1);
        Iz = Iz(2:size(Iz,1)-1, 2:size(Iz,2)-1, 2:size(Iz,3)-1);
        It = It(2:size(It,1)-1, 2:size(It,2)-1, 2:size(It,3)-1);
    end

end % function calculate_derivatives_hsd3()

%   Published under a Creative Commons Attribution-Non-Commercial-Share Alike
%   3.0 Unported Licence http://creativecommons.org/licenses/by-nc-sa/3.0/
 