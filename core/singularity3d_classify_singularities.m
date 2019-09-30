function  [singularity_classification] =   singularity3d_classify_singularities(null_points_3d, mfile_vel_obj)
% 1) calculates jacobian for each critical point, and then 
% 2) classify type of critical point. 
% ARGUMENTS:
%          null_points_3d        -- a struct of size [1 x no. timepoints]
%                         -- .xyz_idx [no. of singularities x 1] -- linear indices 
%                                     [no. of singularities x 3] -- subscripts
%          mfile_vel_obj  -- a MatFile handle pointing to the flows/velocity
%                            fields. Needed for the calculation of the
%                            jacobian matrix. 
% OUTPUT:
%         singularity_classification  --  a cell array of size [1 x no. timepoints]
%                                         where each element is a cell of size
%                                         [no. of singularities]. The cells
%                                         have human readable strings with
%                                         the type of singularity detected. 
% REQUIRES:
%          switch_index_mode()
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
% USAGE:
%{
    
%}
% NOTE: as the timeseries get longer, we can in principle parallelise this
% function.
singularity_classification = cell(size(null_points_3d));
tpts = size(null_points_3d, 2);

% Load options structure
options = mfile_vel.options;
grid_size = options.flow_calculation.grid_size;

% Check if we stored linear indices or subscripts 
if size(null_points_3d(1).xyz_idx, 2) < 2
    for tt=1:tpts
        xyz_subs = switch_index_mode(null_points_3d(tt).xyz_idx, 'subscript', grid_size);
        null_points_3d(tt).xyz_idx = xyz_subs;
    end    
    
end

hx = mfile_vel_obj.hx; 
hy = mfile_vel_obj.hy; 
hz = mfile_vel_obj.hz; 


for tt=1:tpts % parallizable stuff but the classification runs very fast

       % Check if we have critical points. There are 'frames' for which
       % nothing was detected, we should not attempt to calculate jacobian.
       if isempty(null_points_3d(tt).xyz_idx)
           continue
       end
       
       % Create temp variables with partial load of a matfile. 
       ux = mfile_vel_obj.ux(:, :, :, tt);
       uy = mfile_vel_obj.uy(:, :, :, tt);
       uz = mfile_vel_obj.uz(:, :, :, tt);
       
       num_critical_points = size(null_points_3d(tt).xyz_idx, 1);
       singularity_labels  = cell(num_critical_points, 1);

       for ss=1:num_critical_points
           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = null_points_3d(tt).xyz_idx(ss, :);
           % Move points a little
           %point = rectify_boundary_points(point, grid_size);
           % Flag points at the boundary
           boundary_vec = detect_boundary_points(point_idx, grid_size);               
                            
           if ~isempty(boundary_vec)
                singularity_labels{ss} = 'boundary';
            continue
           end
           
           % Calculate the Jacobian at each critical point 
           [J3D] = jacobian3d(point_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels{ss} = classify_critical_points_3d(J3D);
       end

       singularity_classification{tt} = singularity_labels;
end

end % classify_singularities()

function boundary_vec = detect_boundary_points(point_idx, grid_size)
    xdim=1;
    ydim=2;
    zdim=3;
    boundary_vec = [intersect(point_idx, 1), ...
                    intersect(point_idx(xdim), grid_size(xdim)), ...
                    intersect(point_idx(ydim), grid_size(ydim)), ...
                    intersect(point_idx(zdim), grid_size(zdim))];

end % function detect_boundary_points


function rectified_point = rectify_boundary_points(point, grid_size)
    xdim=1;
    ydim=2;
    zdim=3;
    % This function just moves the location of the point to the next
    % nearest neighbour along the offending dimension
    
    point(point == 1) = 4;
    if point(xdim) >= grid_size(xdim)-3
        point(xdim) = grid_size(xdim)-4; % This assumes our spatial sampling is not terrible
    end
    
    if point(ydim) >= grid_size(ydim)-3
        point(ydim) = grid_size(ydim)-4; % This assumes our spatial sampling is not terrible
    end
    
    if point(zdim) >= grid_size(zdim)-3
        point(zdim) = grid_size(zdim)-4; % This assumes our spatial sampling is not terrible
    end
        
    rectified_point = point;

end % function rectify_boundary_points()