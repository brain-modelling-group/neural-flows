function  [singularity_classification] =   classify_singularities(xyz_idx, mfile_vel_obj)
% This function is kind of a wrapper: 
% 1) calculate jacobian for each critical point, and then 
% 2) classify type of critical point. 
% In: xyz_idx -- for the time being  struct with the position of the
% crtitical points for each velocity (time) frame.
%  The indices are supposed to be subscripts not linear indices
%     mfile_vel_obj -- matfile object handle to the velocity fields, need
%     them to calculate the jacobian 3D. 

singularity_classification = cell(size(xyz_idx));
tpts = size(xyz_idx, 2);

for tt=1:tpts % parallizable stuff but the classification runs very fast

       hx = 1; % NOTE: to updated once I figure out the dimensionality of stuff
       hy = 1; % NOTE: to updated once I figure out the dimensionality of stuff
       hz = 1; % NOTE: to updated once I figure out the dimensionality of stuff
       
       % Check if we have critical points. There are 'frames' for which
       % nothing was detected, we should not attempt to calculate jacobian.
       if isempty(xyz_idx(tt).xyz_idx)
           continue
       end
       
       num_critical_points = size(xyz_idx(tt).xyz_idx, 1);
       singularity_labels  = cell(num_critical_points, 1);

       for ss=1:num_critical_points
           % Calculate the Jacobian at each critical point 
           [J3D] = jacobian3d(xyz_idx(tt).xyz_idx(ss, :), mfile_vel_obj.ux(:, :, :, tt), mfile_vel_obj.uy(:, :, :, tt), mfile_vel_obj.uz(:, :, :, tt), hx, hy, hz);
           singularity_labels{ss} = classify_critical_points_3d(J3D);
       end

       singularity_classification{tt} = singularity_labels;
end

end % classify_singularities()
