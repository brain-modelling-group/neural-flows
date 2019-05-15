function [xyz_idx] = par_locate_critical_points(mfile_surf_obj, mfile_vel_obj, data_mode, index_mode)
% Locates the critical points of the velocity fields. 
% Returns the location of the singularities either as: 
% linear indices xyz_lidx, or as 
% subscripts [x_idx, y_idx, z_idx]. 
% 
% ARGUMENTS:
%          mfile_surf_obj -- a MatFile handle pointing to the isosurfaces
%          mfiel_vel_ob   -- a MatFile handle pointing to the velocity
%                            fields
%          data_mode      -- a string to determine whther to use surfaces or
%                            velocity fields to detect the critical points. 
%                            Using velocity fields is fast but very innacurate.
%                            Using surfaces is accurate but painfully slow.
%                            Values: {'surf' | 'vel'}. Default: 'surf'.
%         index_mode      -- a string to determine whther to retunr linear
%                            indices or subscripts.
%                            Values: {'linear' | 'subscript'}. 
%                            Default:'linear'.
%    
% OUTPUT:
%         xyz_idx  --  a struct of size [1 x no. timepoints]
%                  -- .xyz_idx linear indices of subscripts of all critical 
%                              points at k-th timepoint.    
%       
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019
% USAGE:
%{
    
%}

if nargin < 4
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
                                       (Z-points(idx, 3)).^2 )); %#ok<PFBNS,PFOUS>
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

% Uses surfaces to locate singularities
function xyz_idx = locate_null_surf_coordinates(temp_surf_struct, X, Y, Z, index_mode)
        xyz_lidx_ux = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_ux, X, Y, Z);
        xyz_lidx_uy = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_uy, X, Y, Z);
        xyz_lidx_uz = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_uz, X, Y, Z);

        xyz_lidx = intersect(intersect(xyz_lidx_ux, xyz_lidx_uy), xyz_lidx_uz);
        xyz_idx  = switch_index_mode(xyz_lidx, index_mode, X);
        
end


function xyz_idx = use_velocity_fields(mfile_vel_obj, index_mode)

tpts = size(mfile_vel_obj, 'isosurfs', 4); %#ok<GTARG>
X = mfile_vel_obj.X;
xyz_idx = struct([]); 

    parfor tt=1:tpts
         xyz_idx(tt).xyz_idx = locate_null_velocity_coordinates(mfile_vel_obj.ux(:, :, :, tt), ...
                                                                mfile_vel_obj.uy(:, :, :, tt), ...
                                                                mfile_vel_obj.uz(:, :, :, tt), X, index_mode);        %#ok<PFBNS>
    end 

end


function xyz_idx = use_isosurfaces(mfile_surf_obj, mfile_vel_obj, index_mode)
% mfile_surf_obj can be a matfile or a struct -- with the same internal 'structure'
% 
try
    tpts = size(mfile_surf_obj, 'isosurfs', 2); %#ok<GTARG>
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
            case 'subscript' % NOTE: I vaguely remember this part not working properly.
                [x_idx, y_idx, z_idx] = ind2sub(size(X),xyz_lidx); 
                xyz_idx = [x_idx, y_idx, z_idx];
        end
end
