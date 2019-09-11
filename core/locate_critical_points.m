function [xyz_idx] = locate_critical_points(vx, vy, vz, X, Y, Z, critical_isovalue, index_mode)
% Locates the critical points in a 3D vector field. This function finds 
% the intersection of the three isosrufaces (one per velocity component) at v = critical_isovalue.
% Returns the location of the singularities as linear indices xyz_lidx, or as 
% subscripts x_idx, y_idx, z_idx 
% 
% ARGUMENTS:
%      
%    
% OUTPUT:
%       
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019
% USAGE:
%{
    
%}

if nargin < 6
    % Magnitude of the velocity that is considered almost 0
    critical_isovalue = 0; 
    index_mode = 'subscript';
end



[~, vertices_ux] = isosurface(X, Y, Z, vx, critical_isovalue);
[~, vertices_uy] = isosurface(X, Y, Z, vy, critical_isovalue);
[~, vertices_uz] = isosurface(X, Y, Z, vz, critical_isovalue);


% Get linear indices of each vertex (approximate location of critical points)
% TODO: this function returns a very rough approximation
% The location may not be exact and we may need to interpolate
xyz_lidx_x = coordinate_to_linear_index(vertices_ux, X, Y, Z);
xyz_lidx_y = coordinate_to_linear_index(vertices_uy, X, Y, Z);
xyz_lidx_z = coordinate_to_linear_index(vertices_uz, X, Y, Z);

% Do the same for the different isosurfaces. Works better than using the
% magnitud. 

xyz_lidx = intersect(intersect(xyz_lidx_x, xyz_lidx_y), xyz_lidx_z);

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


