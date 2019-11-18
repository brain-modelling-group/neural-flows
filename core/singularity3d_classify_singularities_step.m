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
       
       
       [boundary_vec_idx, in_bdy_vec_idx] = detect_boundary_points(null_pts_3d_xyz_idx, grid_size);
       
       if ~isempty(boundary_vec_idx)
           [singularity_labels{boundary_vec_idx}] = deal('boundary');
       end
       
       if isempty(in_bdy_vec_idx) % all the points where at the boundary
           return
       end

       for cc=1:length(in_bdy_vec_idx)
           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = null_pts_3d_xyz_idx(in_bdy_vec_idx(cc), :);
 
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_calculate_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels{in_bdy_vec_idx(cc)} = singularity3d_classify_critical_points(J3D);
       end

end % function singularity3d_classify_singularities_step


function [boundary_vec_idx, in_bdy_vec_idx] = detect_boundary_points(points_idx, grid_size)
% This function only detects points on the faces of the grid.
% It does not handle an irregular domain.

    xdim=2;
    ydim=1;
    zdim=3;
    
    bv_x = (points_idx(:, xdim) == 1 | points_idx(:, xdim) == grid_size(xdim));
    bv_y = (points_idx(:, ydim) == 1 | points_idx(:, ydim) == grid_size(ydim));
    bv_z = (points_idx(:, zdim) == 1 | points_idx(:, zdim) == grid_size(zdim));
    bv = bv_x + bv_y + bv_z;
    
    boundary_vec_idx = find(bv > 0);
    in_bdy_vec_idx = find(bv ==0);

end % function detect_boundary_points()
