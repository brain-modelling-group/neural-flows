function null_points_3d = flows3d_hs3d_detect_nullflows_parallel(mfile_obj, X, Y, Z, in_bdy_mask, data_mode, index_mode)
% Locatees null regions of velocity fields. These are good 'singularity' candidates. 
% Returns the location of the singularities either as: 
% linear indices xyz_lidx, or as subscripts [x_idx, y_idx, z_idx]. 
% TODO: clean up, break down into standlaone functions, return actual
% points in space, not only indices; 
% ARGUMENTS:
%          mfile_obj -- a MatFile handle with the critical isosurfaces or
%                       the velocity/flow fields. In the cases of using
%                       isosurfaces, mfile_obj could also be a struct
%          data_mode      -- a string to determine whther to use surfaces or
%                            velocity fields to detect the critical points. 
%                            Using velocity fields is fast but very innacurate.
%                            Using surfaces is accurate but painfully slow.
%                            Values: {'surf' | 'vel'}. Default: 'surf'.
%          index_mode      -- a string to determine whther to retunr linear
%                            indices or subscripts.
%                            Values: {'linear' | 'subscript'}. 
%                            Default:'linear'.
%         X, Y, Z      -- 3D arrays of size [Nx, Ny, Nz] with the grids of the space 
%                         to be explroed.
%         in_bdy_mask -- a 3D array of size [Nx, Ny, Nz] with 1s in
%                        locations of space that are inside the boundary of 
%                        the brain and 0s for points that are outside.
%    
% OUTPUT:
%         null_points_3d  --  a struct of size [1 x no. timepoints]
%                         -- .xyz_idx linear indices of subscripts of all
%                                     null-flow points at k-th timepoint.
%                         -- .x  x-coordinates 
%                         -- .y  y-coordinates
%                         -- .z  z-coordinates
%       
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
% USAGE:
%{
    
%}

if nargin < 4
    index_mode = 'linear';
end

switch data_mode
    case 'surf'
        % Slow with full resolution surfaces (50k faces each) but seems to give precise-ish locations
        null_points_3d = use_isosurfaces(mfile_obj, X, Y, Z, index_mode, in_bdy_mask);
    case 'vel'
        % Super fast, but gives lots of points that do not seem to be
        % intersecting
        null_points_3d = use_velocity_fields(mfile_vel_obj, index_mode);   
end
        
end % function flows3d_hs3d_detect_nullflows_parallel()


% Uses the vector fields to locate singularities
function xyz_idx = locate_null_velocity_coordinates(ux, uy, uz, size_grid, index_mode, detection_threshold)
        
        % Find linear indices
        %uu = abs(ux(:) .* uy(:) .* uz(:)); % based on magnitude
        [~, uu] = normalise_vector_field([ux(:) uy(:) uz(:)], 2); % based on the norm
        xyz_lidx = find(uu >= detection_threshold(1) & uu < detection_threshold(2));
        %null_ux = find(ux < detection_threshold);
        %null_uy = find(uy < detection_threshold);
        %null_uz = find(uz < detection_threshold);

        %xyz_lidx = intersect(intersect(null_ux, null_uy), null_uz);
        xyz_idx = switch_index_mode(xyz_lidx, index_mode, size_grid);
end

function xyz_idx = use_velocity_fields(mfile_vel_obj, index_mode)

tpts = size(mfile_vel_obj, 'ux', 4); %#ok<GTARG>
size_grid  = size(mfile_vel_obj, 'X');

xyz_idx = struct([]); 
detection_threshold = mfile_vel_obj.detection_threshold;

    parfor tt=1:tpts
         xyz_idx(tt).xyz_idx = locate_null_velocity_coordinates(mfile_vel_obj.ux(:, :, :, tt), ...
                                                                mfile_vel_obj.uy(:, :, :, tt), ...
                                                                mfile_vel_obj.uz(:, :, :, tt), size_grid, ...
                                                                index_mode, ...
                                                                detection_threshold);        %#ok<PFBNS>
    end 

end





function xyz_idx = switch_index_mode(xyz_lidx, index_mode, size_grid)

        switch index_mode
            case 'linear'
                xyz_idx = xyz_lidx;
            case 'subscript' % NOTE: I vaguely remember this part not working properly.
                [x_idx, y_idx, z_idx] = ind2sub(size_grid, xyz_lidx); 
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
