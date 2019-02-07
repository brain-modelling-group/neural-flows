function [xyz_idx] = locate_critical_points(vx, vy, vz, X, Y, Z, critical_isovalue, index_mode)
% Locates the critical points in a 3D vector field
% returns the location in indices x_idx, y_idx, z_idx 
% Find volumes enclosed by isosurfaces of 0 magnitude in the the 
% vector field

% Magnitude of the vector field
vmag = sqrt(vx.^2 + vy.^2 + vz.^2);

if nargin < 6
    % Magnitude of the velocity that is considered almost 0
    critical_isovalue = 2^-8; 
    index_mode = 'subscript';
end


X_ndgrid = permute(X,[2,1,3]);

Y_ndgrid = permute(Y,[2,1,3]);

Z_ndgrid = permute(Z,[2,1,3]);


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
    

    % Allocate memory
    xyz_lidx(size(points, 1), 1) = 0;

    parfor idx=1:size(points, 1)
        [~, temp_dist] = min(abs( (X-points(idx, 1)).^2 + ...
                                  (Y-points(idx, 2)).^2 + ...
                                  (Z-points(idx, 3)).^2 ));
        xyz_lidx(idx) = temp_dist;
    end
    
    xyz_lidx = unique(xyz_lidx);

end % function coordinate_to_linear_index()


