function null_points_3d = flows3d_grid_detect_nullflows_velocities(mfile_vel_obj)

tpts = size(mfile_vel_obj, 'ux', 4); %#ok<GTARG>

null_points_3d = struct([]); 
detection_threshold = mfile_vel_obj.detection_threshold;
X = mfile_vel_obj.X;
Y = mfile_vel_obj.Y;
Z = mfile_vel_obj.Z;

    for tt=1:tpts
         null_points_3d(tt).xyz_idx = locate_null_velocity_coordinates(mfile_vel_obj.ux(:, :, :, tt), ...
                                                                       mfile_vel_obj.uy(:, :, :, tt), ...
                                                                       mfile_vel_obj.uz(:, :, :, tt), ...
                                                                       detection_threshold);      
                                                            
         null_points_3d(tt).x = locate_points(X, null_points_3d(tt).xyz_idx);
         null_points_3d(tt).y = locate_points(Y, null_points_3d(tt).xyz_idx);
         null_points_3d(tt).z = locate_points(Z, null_points_3d(tt).xyz_idx);
    end 
    
    

end

% Uses the vector fields to locate singularities
function xyz_idx = locate_null_velocity_coordinates(ux, uy, uz, detection_threshold)
        
        % Find linear indices
        %uu = abs(ux(:) .* uy(:) .* uz(:)); % based on magnitude
        % NOTE: need to come up with better ways to detect these points
        [~, uu] = normalise_vector_field([ux(:) uy(:) uz(:)], 2); % based on the norm
        xyz_idx = find(uu >= detection_threshold(1) & uu < detection_threshold(2));

end

function p = locate_points(XX, idx)
    p = XX(idx);
end


