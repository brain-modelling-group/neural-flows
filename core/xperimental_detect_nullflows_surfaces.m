function null_points_3d = use_isosurfaces(mfile_surf_obj, X, Y, Z, index_mode, in_bdy_mask)
%NOTE: Under development -- not tested.
% mfile_surf_obj can be a matfile or a struct -- with the same internal 'structure'
% as the file
% Author Paula sanz-Leon, QIMR february 2019
try
    tpts = size(mfile_surf_obj, 'isosurfs', 2); %#ok<GTARG>
catch
    disp('This is a struct not a MatFile.')
    tpts = length(mfile_surf_obj.isosurfs);
end

null_points_3d = struct([]); 

for tt=1:tpts
    null_points_3d(tt).xyz_idx = locate_null_surf_coordinates(mfile_surf_obj.isosurfs(1, tt), X, Y, Z, index_mode, in_bdy_mask);
    null_points_3d(tt).x = X(null_points_3d(tt).xyz_idx);
    null_points_3d(tt).y = Y(null_points_3d(tt).xyz_idx);
    null_points_3d(tt).z = Z(null_points_3d(tt).xyz_idx);
end 


% Uses surfaces to locate singularities
function xyz_idx = locate_null_surf_coordinates(temp_surf_struct, X, Y, Z, index_mode, in_bdy_mask)
        %xyz_lidx_ux = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_ux, X, Y, Z);
        %xyz_lidx_uy = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_uy, X, Y, Z);
        %xyz_lidx_uz = vertex_coordinate_to_linear_index(temp_surf_struct.vertices_uz, X, Y, Z);
        
        [xyz_lidx_ux, xyz_lidx_uy, xyz_lidx_uz] = vertex_to_linear_index(temp_surf_struct.vertices_ux, ...
                                                                         temp_surf_struct.vertices_uy, ...
                                                                         temp_surf_struct.vertices_uz, ...
                                                                         X, Y, Z, in_bdy_mask);
        xyz_lidx = find(xyz_lidx_ux.*xyz_lidx_uy.*xyz_lidx_uz);
        %xyz_lidx = intersect(intersect(xyz_lidx_ux, xyz_lidx_uy), xyz_lidx_uz);
        xyz_idx  = switch_index_mode(xyz_lidx, index_mode, X);
        
end



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
    distance_threshold = 0.2;
    
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
        
        % Assigning 1 means the surface goes through that point                        
        xyz_lidx_ux(idx)    = min_temp_ux(idx) < distance_threshold;                                                
        xyz_lidx_uy(idx)    = min_temp_uy(idx) < distance_threshold;
        xyz_lidx_uz(idx)    = min_temp_uz(idx) < distance_threshold;
        
    end
                                                                                                                                              
end

end % use_isosurfaces()


