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


function [xyz_lidx_ux, xyz_lidx_uy, xyz_lidx_uz] = vertex_to_linear_index(vertices_ux, ...
                                                                          vertices_uy, ...
                                                                          vertices_uz, ...
                                                                          X, Y, Z, in_bdy_mask)
 % Quick and dirty solution to find indices in the 3d grid, take 2
 % points is N x Dimension 
    X = X(in_bdy_mask);
    Y = Y(in_bdy_mask);
    Z = Z(in_bdy_mask);
    xdim = 1;
    ydim = 2;
    zdim = 3;
    
    % Allocate memory
    xyz_lidx_ux(size(vertices_ux, 1), 1) = 0;
    xyz_lidx_uy(size(vertices_uy, 1), 1) = 0;
    xyz_lidx_uz(size(vertices_uz, 1), 1) = 0;

    % Note: this should be a parameter
    distance_threshold = 0.1;
    
    parfor idx=1:length(X) % 500,000 points
        min_temp_ux(idx) =   min(sqrt((X(idx)-vertices_ux(:, xdim)).^2 + ...
                                      (Y(idx)-vertices_ux(:, ydim)).^2 + ...
                                      (Z(idx)-vertices_ux(:, zdim)).^2 )); %#ok<PFOUS,PFBNS>
       
        min_temp_uy(idx) =   min(sqrt ((X(idx)-vertices_uy(:, xdim)).^2 + ...
                                      (Y(idx)-vertices_uy(:, ydim)).^2 + ...
                                      (Z(idx)-vertices_uy(:, zdim)).^2 )); %#ok<PFOUS,PFBNS>
                                    
        min_temp_uz(idx) =   min(sqrt((X(idx)-vertices_uz(:, xdim)).^2 + ...
                                      (Y(idx)-vertices_uz(:, ydim)).^2 + ...
                                      (Z(idx)-vertices_uz(:, zdim)).^2 )); %#ok<PFOUS,PFBNS>
        
        % Asssing 1 means the surface goes through that point                        
        xyz_lidx_ux(idx)    = min_temp_ux(idx) < distance_threshold;                                                
        xyz_lidx_uy(idx)    = min_temp_uy(idx) < distance_threshold;
        xyz_lidx_uz(idx)    = min_temp_uz(idx) < distance_threshold;
        
    end
                                                                                                                                              
end


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
function xyz_idx = locate_null_surf_coordinates(temp_surf_struct, X, Y, Z, index_mode, in_bdy_mask)
        %xyz_lidx_ux = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_ux, X, Y, Z);
        %xyz_lidx_uy = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_uy, X, Y, Z);
        %xyz_lidx_uz = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_uz, X, Y, Z);
        
        [xyz_lidx_ux, xyz_lidx_uy, xyz_lidx_uz] = vertex_to_linear_index(temp_surf_struct.vertices_ux, ...
                                                                         temp_surf_struct.vertices_uy, ...
                                                                         temp_surf_struct.vertices_uy, ...
                                                                         X, Y, Z, in_bdy_mask);
        xyz_lidx = find(xyz_lidx_ux.*xyz_lidx_uy.*xyz_lidx_uz);
        %xyz_lidx = intersect(intersect(xyz_lidx_ux, xyz_lidx_uy), xyz_lidx_uz);
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
in_bdy_mask = mfile_vel_obj.in_bdy_mask;

    for tt=1:tpts
        xyz_idx(tt).xyz_idx = locate_null_surf_coordinates(mfile_surf_obj.isosurfs(1, tt), X, Y, Z, index_mode, in_bdy_mask);        
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

% function xyz_lidx = vertex_coordinate_to_linear_index(points, X, Y, Z)
%  % Quick and dirty solution to find indices in the 3d grid
%  % points is N x Dimension 
%     X = X(:);
%     Y = Y(:);
%     Z = Z(:);
%     xdim = 1;
%     ydim = 2;
%     zdim = 3;
%     
%     % Allocate memory
%     xyz_lidx(size(points, 1), 1) = 0;
% 
%     parfor idx=1:size(points, 1)
%         [~, temp_dist(idx)] = min(abs( (X-points(idx, xdim)).^2 + ...
%                                        (Y-points(idx, ydim)).^2 + ...
%                                        (Z-points(idx, zdim)).^2 )); %#ok<PFBNS,PFOUS>
%         xyz_lidx(idx) = temp_dist(idx);
%     end
%     
%     xyz_lidx = unique(xyz_lidx);
% 
% end % vertex_function coordinate_to_linear_index()
