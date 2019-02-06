function [A, B] = generate_activity_3d_structured(domain_shape, aff_tform)
%% Creates two 3D regularly spaced arrays with a shifted sphere as data. 
%
%  ARGUMENTS:
%        domain_shape -- a [3 x 1] vector with the sizes along each spatial 
%                        dimension. Default is [128, 128, 128] 
%
%        aff_tfomr    -- a [4 x 4] matrix with the shift of the data between 
%                        frame A to frame B: 
%
%  OUTPUT:
%        A --  a 3D array of size `domain_shape` with a blob (solid sphere)
%              as the data of interest
%
%        B --  a 3D array of size `domain_shape` with the cube shifted 
%              according to `aff_tform` 
%
%
%  REQUIRES:
%          Matlab's affine3d, imwarp
%
%
%  AUTHOR:
%    Paula Sanz-Leon, QIMR, 2019
%
%
%  USAGE:
%{
   domain_shape = [128, 128, 128]; 
   [A, B] = generate_activity_3d_structured(domain_shape);
   figure; 
   z_slice = floor(domain_shape(3)/2);
   imshowpair(A(:, :, z_slice), B(:, :, z_slice), 'montage')

%}
% NOTE: Useful documentation about affine transformations in 2D and 3D
%       https://au.mathworks.com/discovery/affine-transformation.html
%       https://au.mathworks.com/help/images/matrix-representation-of-geometric-transformations.html
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Checks
    if nargin < 1
        aff_tform = eye(4);
        domain_shape = [128, 128, 128];
    end
    
    if nargin < 2
        aff_tform = eye(4);
        aff_tform(4, 1:3) = 1; % Move/translate blob along x, y, z
    end
    if length(domain_shape) < 3
        error(['patchflow:' mfilename ':BadInputArgument'...
               'The shape vector must have 3 elements.'])
    end

    % Human readable indexing
    x_dim = 1;
    y_dim = 2;
    z_dim = 3;
    
    % Centre of the sphere
    xo = floor(domain_shape(x_dim)/2);
    yo = floor(domain_shape(y_dim)/2);
    zo = floor(domain_shape(z_dim)/2);
    
    % Radius
    r  = floor(min(domain_shape)/4);
    vx = ((1:domain_shape(x_dim)) - xo) .^ 2;
    vy = ((1:domain_shape(y_dim)) - yo) .^ 2;
    vz = ((1:domain_shape(z_dim)) - zo) .^ 2;
    
    % Blob
    A = double((vx.' + vy + reshape(vz, [1, 1, length(vz)])) < r^2);

    % Create the affine transformation object
    tform = affine3d(aff_tform);
    
    % Create a reference 3D image to world coordinates
    RA = imref3d(domain_shape, 1, 1, 1); % where the ones are voxel size
    
    % Apply the transform and output new image wrt to reference coordinates of A
    B = imwarp(A, tform, 'OutputView', RA); 
 
end %