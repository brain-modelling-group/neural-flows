function analyse_nodal_occupancy()




%%
tpts = 8192; 

num_base_sngs = 8;
num_nodes = size(locs, 1);
dis_th = 30; % mm distance threhsold for a singularity to be considered to ahppen at a node.

tracking_matrix(num_base_sngs, num_nodes, tpts) = 0;
transition_matrix(num_nodes, tpts) = 0;
null_points_3d = mfile_sing.null_points_3d;
for tt=1:tpts
    for nn=1:size(locs, 1)
         sings_temp = singularity_list_num{tt};
         idx = find(sings_temp < 9);
         base_sings_temp = sings_temp(idx);
         if ~isempty(idx)
             xyz_sings = [null_points_3d(tt).x(idx), null_points_3d(tt).y(idx), null_points_3d(tt).z(idx)];
             for ss=1:length(idx)
                 [val_dis, nn_idx] = min(dis(xyz_sings(ss), locs.'));
                 if val_dis <= dis_th
                     tracking_matrix(base_sings_temp(ss), nn_idx, tt) = 1;
                     transition_matrix(nn_idx, tt) = base_sings_temp(ss);
                 end
             end
         end
                
    end
end


%% Some statistics
% sum across time
sing_nodal_occupancy = sum(tracking_matrix, 3);
% find the singularity that is most frequent in each region 
[max_occupancy, sing_idx] = max(sing_nodal_occupancy); % probably divide by time_period/num_frames so as to 

% sum across singularity types, total occupancy is time spent as a valid
% type of singularity/vs none/undefined.
total_nodal_occupancy = sum(sing_nodal_occupancy, 1);

% Find indices of nodes/regions that spend most of the time being a
% particular type of singularity
valid_node_idx = find(sing_idx & total_nodal_occupancy);

sing_type = sing_idx(valid_node_idx);

% Plot the occupancy of every type of singularity for valid nodes
stairs(sing_nodal_occupancy(:, valid_node_idx).')


bh = bar(sing_nodal_occupancy(:, valid_node_idx).', 'stacked');
colormap(cmap)

end % function analyse_nodal_occupancy()