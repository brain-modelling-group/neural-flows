function [xyz_idx] = par_locate_critical_points(mfile_surf_obj, mfile_vel_obj, data_mode, index_mode)
% Locates the critical points at the intersection of the three isosrufaces (one per velocity component) at v = critical_isovalue.
% Returns the location of the singularities as linear indices xyz_lidx, or as 
% subscripts x_idx, y_idx, z_idx 
% data_mode: 'surf' or 'vel' -- data to use to detect the locations of
% critical points
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

if nargin < 4
    % Magnitude of the velocity that is considered almost 0
    index_mode = 'linear';
end

switch data_mode
    case 'surf'
        % Slow with full resolution surfaces (50k faces each) but seems to give precise-ish locations
        xyz_idx = use_isosurfaces(mfile_surf_obj, mfile_vel_obj, index_mode);
    case 'vel'
        % Super fast, but gives lots of points that do not seem to be
        % intersecting
        xyz_idx = use_velocity_fields(mfile_vel_obj, index_mode);   
end
        
end % function par_locate_critical_points()

function xyz_lidx = vertex_coordinate_to_linear_index(points, X, Y, Z)
 % Quick and dirty solution to find indices in the 3d grid
 % points is N x Dimension 
    X = X(:);
    Y = Y(:);
    Z = Z(:);
    
    % Allocate memory
    xyz_lidx(size(points, 1), 1) = 0;

    parfor idx=1:size(points, 1)
        [~, temp_dist(idx)] = min(abs( (X-points(idx, 1)).^2 + ...
                                  (Y-points(idx, 2)).^2 + ...
                                  (Z-points(idx, 3)).^2 ));
        xyz_lidx(idx) = temp_dist(idx);
    end
    
    xyz_lidx = unique(xyz_lidx);

end % vertex_function coordinate_to_linear_index()

% Uses the vector fields to locate singularities
function xyz_idx = locate_null_velocity_coordinates(ux, uy, uz, X, index_mode)
        
        % Find linear indices
        null_ux = find(ux < eps);
        null_uy = find(uy < eps);
        null_uz = find(uz < eps);

        xyz_lidx = intersect(intersect(null_ux, null_uy), null_uz);
        xyz_idx = switch_index_mode(xyz_lidx, index_mode, X);
end

% uses surfaces to locate singularities
function xyz_idx = locate_null_surf_coordinates(temp_surf_struct, X, Y, Z, index_mode)

        xyz_lidx_x = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_x, X, Y, Z);
        xyz_lidx_y = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_y, X, Y, Z);
        xyz_lidx_z = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_z, X, Y, Z);

        xyz_lidx = intersect(intersect(xyz_lidx_x, xyz_lidx_y), xyz_lidx_z);
        xyz_idx  = switch_index_mode(xyz_lidx, index_mode, X);
        
end


function xyz_idx = use_velocity_fields(mfile_vel_obj, index_mode)

tpts = size(mfile_vel_obj, 'isosurfs', 4);
X = mfile_vel_obj.X;
xyz_idx = struct([]); 

    parfor tt=1:tpts
         xyz_idx(tt).xyz_idx = locate_null_velocity_coordinates(mfile_vel_obj.ux(:, :, :, tt), ...
                                                                mfile_vel_obj.uy(:, :, :, tt), ...
                                                                mfile_vel_obj.uz(:, :, :, tt), X, index_mode);       
    end 

end


function xyz_idx = use_isosurfaces(mfile_surf_obj, mfile_vel_obj, index_mode)

% mfile_surf_ob can be a matfile or a struct -- with the same 'structure'
try
    tpts = size(mfile_surf_obj, 'isosurfs', 2);
catch
    disp('This is a struct not a matfile.')
    tpts = length(mfile_surf_obj.isosurfs);
end

X = mfile_vel_obj.X;
Y = mfile_vel_obj.Y;
Z = mfile_vel_obj.Z;
xyz_idx = struct([]); 

    for tt=1:tpts
        xyz_idx(tt).xyz_idx = locate_null_surf_coordinates(mfile_surf_obj.isosurfs(1, tt), X, Y, Z, index_mode);        
    end 

end


function xyz_idx = switch_index_mode(xyz_lidx, index_mode, X)

        switch index_mode
            case 'linear'
                xyz_idx = xyz_lidx;
            case 'subscript' % NOTe: I vaguely remember this part not working properly.
                [x_idx, y_idx, z_idx] = ind2sub(size(X),xyz_lidx); 
                xyz_idx = [x_idx, y_idx, z_idx];
        end
end
