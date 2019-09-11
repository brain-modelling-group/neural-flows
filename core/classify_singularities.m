function  [singularity_classification] =   classify_singularities(xyz_idx, mfile_vel_obj)
% 1) calculates jacobian for each critical point, and then 
% 2) classify type of critical point. 
% ARGUMENTS:
%          xyz_idx        -- a struct of size [1 x no. timepoints]
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
%       
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer 2019
% USAGE:
%{
    
%}
% NOTE: as the timeseries get longer, we can in principle parallelise this
% function.
singularity_classification = cell(size(xyz_idx));
tpts = size(xyz_idx, 2);

if size(xyz_idx(1).xyz_idx, 2) < 2

    for tt=1:tpts
        xyz_subs = switch_index_mode(xyz_idx(tt).xyz_idx, 'subscript', mfile_vel_obj.X);
        xyz_idx(tt).xyz_idx = xyz_subs;
    end    
    
end

hx = mfile_vel_obj.hx; % NOTE: to updated once I figure out the dimensionality of stuff
hy = mfile_vel_obj.hy; % NOTE: to updated once I figure out the dimensionality of stuff
hz = mfile_vel_obj.hz; % NOTE: to updated once I figure out the dimensionality of stuff


grid_size =  size(mfile_vel_obj, 'X');

for tt=1:tpts % parallizable stuff but the classification runs very fast

       % Create temp variables with partial load of a matfile. 
       ux = mfile_vel_obj.ux(:, :, :, tt);
       uy = mfile_vel_obj.uy(:, :, :, tt);
       uz = mfile_vel_obj.uz(:, :, :, tt);
       
       % Check if we have critical points. There are 'frames' for which
       % nothing was detected, we should not attempt to calculate jacobian.
       if isempty(xyz_idx(tt).xyz_idx)
           continue
       end
       
       num_critical_points = size(xyz_idx(tt).xyz_idx, 1);
       singularity_labels  = cell(num_critical_points, 1);

       for ss=1:num_critical_points
           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point = xyz_idx(tt).xyz_idx(ss, :);
           % Move points a little
           %point = rectify_boundary_points(point, grid_size);
           % Flag points at the boundary
           boundary_vec = detect_boundary_points(point, grid_size);               
                            
           if ~isempty(boundary_vec)
                singularity_labels{ss} = 'boundary';
            continue
           end
           
           
           % Calculate the Jacobian at each critical point 
           [J3D] = jacobian3d(point, ux, uy, uz, hx, hy, hz);
           singularity_labels{ss} = classify_critical_points_3d(J3D);
       end

       singularity_classification{tt} = singularity_labels;
end

end % classify_singularities()

function boundary_vec = detect_boundary_points(point, grid_size)
    xdim=1;
    ydim=2;
    zdim=3;
    boundary_vec = [intersect(point, 1), ...
                    intersect(point(xdim), grid_size(xdim)), ...
                    intersect(point(ydim), grid_size(ydim)), ...
                    intersect(point(zdim), grid_size(zdim))];

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