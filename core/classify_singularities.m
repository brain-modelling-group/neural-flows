function  [singularity_classification] =   classify_singularities(xyz_idx, mfile_vel_obj)
% This function is kind of a wrapper: 1) calculate jacobian for each
% critical point, and then 2) classify type of critical point. 
% In: xyz_idx -- for the time being  cell array with the position of the
% crtitical points for each velocity (time) frame.
%     mfile_vel_obj -- matfile object handle to the velocity fields, need
%     them to calculate the jacobian 3D. 

singularity_classification = cell(size(xyz_idx), 1);
   for tt=1:size(xyz_idx, 1) % parallizable stuff but the classification runs very fas

       hx = 1;
       hy = 1;
       hz = 1;
    
       [J3D] = jacobian3d(xyz_idx{tt}, mfile_vel_obj.ux(:, :, :, tt), mfile_vel_obj.uy(:, :, :, 1), mfile_vel_obj.uz(:, :, :, 1), hx, hy, hz);
       
       singularity_labels = cell(size(J3D, 3), 1);
       for ss = 1:size(J3D, 3)
    
           singularity_labels{ss} = classify_critical_points_3d(J3D(:, :, ss));
    
       end

       singularity_classification{tt} = singularity_labels;

   end

end
