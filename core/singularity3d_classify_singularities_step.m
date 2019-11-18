function singularity_labels = singularity3d_classify_singularities_step(null_pts_3d_xyz_idx, ux, uy, uz, hx, hy, hz, grid_size)

% This function is for each time point 
% 1) calculates jacobian for each critical point, and then 
% 2) classify type of critical point. 
% ARGUMENTS:
%          null_points_3d_xyz_idx -- the current vector/element of null_points_3d.xyz_idx 
%          ux, uy, uz, -- 3D arrays with current value of flow field
%          hx, hy, hz -- resolution in space
% OUTPUT:
%         singularity_labels  --  a cell array of size [1 x no. singularities]
%                                         where each element is a human readable strings with
%                                         the type of singularity detected. 
% REQUIRES:
%          ()
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
% USAGE:
%{
    
%}


       if isempty(null_pts_3d_xyz_idx)
           singularity_labels = {'empty'};
           return
       end
       
       num_critical_points = size(null_pts_3d_xyz_idx, 1);
       singularity_labels  = cell(num_critical_points, 1);

       for cc=1:num_critical_points
           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = null_pts_3d_xyz_idx(cc, :);
           
           % Flag points at the boundary
           %boundary_vec = detect_boundary_points(point_idx, grid_size);               
                            
           %if ~isempty(boundary_vec)
           %     singularity_labels{cc} = 'boundary';
           %     continue
           %end
           
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_calculate_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels{cc} = singularity3d_classify_critical_points(J3D);
       end

end % function singularity3d_classify_singularities_step


function boundary_vec = detect_boundary_points(point_idx, grid_size)
% This function only detects points on the faces of the grid.
% It does not handle an irregular domain.

    xdim=2;
    ydim=1;
    zdim=3;
    boundary_vec = [intersect(point_idx, 1), ...
                    intersect(point_idx(xdim), grid_size(xdim)), ...
                    intersect(point_idx(ydim), grid_size(ydim)), ...
                    intersect(point_idx(zdim), grid_size(zdim))];

end % function detect_boundary_points()


