function [tracking_3d_matrix, tracking_2d_matrix] = step_nodal_singularity_occupancy(singularity_classification_frame, singularity_locs, nodal_locs, num_base_sngs, dist_th)
% Function to be invoked by a parfor

    num_nodes = size(nodal_locs, 1);
    tracking_3d_matrix(num_base_sngs, num_nodes) = 0;
    tracking_2d_matrix(num_nodes) = 0;
    idx = find(singularity_classification_frame <= num_base_sngs);
    base_sings_temp = singularity_classification_frame(idx);
   if ~isempty(idx)
       for nn=1:size(nodal_locs, 1)
             singularity_locs_struct = singularity_locs{1};
             xyz_sings = [singularity_locs_struct.x(idx), singularity_locs_struct.y(idx), singularity_locs_struct.z(idx)];
             for ss=1:length(idx)
                 [val_dis, nn_idx] = min(dis(xyz_sings(ss), nodal_locs.'));
                 if val_dis <= dist_th
                     tracking_3d_matrix(base_sings_temp(ss), nn_idx) = 1;
                     tracking_2d_matrix(nn_idx) = base_sings_temp(ss);
                 end
             end
             
       end       
   end
end % step_nodal_singularity()