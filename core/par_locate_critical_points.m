function [xyz_idx] = par_locate_critical_points(mfile_isosurf_obj, mfile_vel_obj, index_mode)
% Locates the critical points at the intersection of the three isosrufaces (one per velocity component) at v = critical_isovalue.
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


if nargin < 5
    % Magnitude of the velocity that is considered almost 0
    index_mode = 'subscript';
end


tpts = size(mfile_isosurf_obj, 'isosurfs', 2);
X = mfile_vel_obj.X;
Y = mfile_vel_obj.Y;
Z = mfile_vel_obj.Z;

xyz_idx = struct([]); %(tpts, 1); %TODO: change to struct
    for tt=1:tpts
    
    % Get linear indices of each vertex (approximate location of critical points)
        % TODO: this function returns a very rough approximation
        % The location may not be exact and we may need to interpolate

        xyz_idx(tt).xyz_idx = locate_coordinates(mfile_isosurf_obj.isosurfs(1, tt), X, Y, Z);
        
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

% function xyz_lidx = coordinate_to_linear_index(points, X, Y, Z)
%  % Quick and dirty solution to find indices in the 3d grid
%  % points is N x Dimension 
%     X = X(:); % Fix this -- no  need to recast into vectot every time
%     Y = Y(:);
%     Z = Z(:);
%     
%     % Allocate memory
%     %xyz_lidx(size(points, 1), 1) = 0;
%     px  = points(:, 1).';
%     py  = points(:, 2).';
%     pz  = points(:, 3).';
%     
%     [~, temp_dist_idx] = min(abs((X-px).^2 + (Y-py).^2 + (Z-pz).^2), [], 1);
%     
%     xyz_lidx = unique(temp_dist_idx);
% 
% end % function coordinate_to_linear_index()

function xyz_idx = locate_coordinates(temp_surf_struct, X, Y, Z, index_mode)

        xyz_lidx_x = coordinate_to_linear_index(temp_surf_struct.vertices_x, X, Y, Z);
        xyz_lidx_y = coordinate_to_linear_index(temp_surf_struct.vertices_y, X, Y, Z);
        xyz_lidx_z = coordinate_to_linear_index(temp_surf_struct.vertices_z, X, Y, Z);

        xyz_lidx = intersect(intersect(xyz_lidx_x, xyz_lidx_y), xyz_lidx_z);

        switch index_mode
            case 'linear'
                xyz_idx = xyz_lidx;
            case 'subscript'
                [x_idx, y_idx, z_idx] = ind2sub(size(X),xyz_lidx);
                xyz_idx = [x_idx, y_idx, z_idx];
        end

end

