function [tracking_matrix, transition_matrix] = step_nodal_occupancy_singularity(singularity_classification_frame, singularity_locs, nodal_locs, num_base_sngs, dist_th)
    num_nodes = size(nodal_locs, 1);
    tracking_matrix(num_base_sngs, num_nodes) = 0;
    transition_matrix(num_nodes) = 0;
    for nn=1:size(nodal_locs, 1)
         idx = find(singularity_classification_frame <= num_base_sngs);
         base_sings_temp = singularity_classification_frame(idx);
         if ~isempty(idx)
             xyz_sings = [singularity_locs{2}(idx), singularity_locs{3}(idx), singularity_locs{4}(idx)];
             for ss=1:length(idx)
                 [val_dis, nn_idx] = min(dis(xyz_sings(ss), nodal_locs.'));
                 if val_dis <= dist_th
                     tracking_matrix(base_sings_temp(ss), nn_idx) = 1;
                     transition_matrix(nn_idx) = base_sings_temp(ss);
                 end
             end
             
         end       
    end
end % step_nodal_singularity()