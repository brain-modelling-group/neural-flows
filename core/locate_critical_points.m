function [xyz_idx] = locate_critical_points(vx, vy, vz, X, Y, Z, critical_isovalue, index_mode)
% Locates the critical points in a 3D vector field
% returns the location in indices x_idx, y_idx, z_idx 
% Find volumes enclosed by isosurfaces of 0 magnitude in the the 
% vector field

% Magnitude of the vector field
vmag = sqrt(vx.^2 + vy.^2 + vz.^2);

if nargin < 6
    % Magnitude of the vecloity that is considered almost 0
    critical_isovalue = 2^-8; 
    index_mode = 'subscript';
end
[~, vertices] = isosurface(X, Y, Z, vmag, critical_isovalue);


% Get linear indices of each vertex (approximate location of critical points)
% TODO: this function returns a very rough approximation
% The location may not be exact and we may need to interpolate
xyz_lidx = coordinate_to_linear_index(vertices, X, Y, Z);


switch index_mode
    case 'linear'
        xyz_idx = xyz_lidx;
    case 'subscript'
        [x_idx, y_idx, z_idx] = ind2sub(size(X),xyz_lidx);
        xyz_idx = [x_idx, y_idx, z_idx];
end
        

end % function locate_critical_points()

function xyz_lidx = coordinate_to_linear_index(points, X, Y, Z)
 % Quick and dirty solution to find indices in the 3d grid
 % points is N x Dimension 
    X = X(:);
    Y = Y(:);
    Z = Z(:);
    
    R = sqrt(X.^2+Y.^2+Z.^2);
    r_points = sqrt(sum(points.^2, size(points, 2)));

    % Allocate memory
    xyz_lidx(size(points, 1), 1) = 0;

    parfor idx=1:size(points, 1)
        [~, temp_r] = min(abs(R-r_points(idx)));
        xyz_lidx(idx) = temp_r;
    end

end % function coordinate_to_linear_index()


