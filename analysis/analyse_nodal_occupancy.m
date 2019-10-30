function analyse_nodal_occupancy(msing_obj, locs, dis_th)
% This function calculates singularity occupancy rates at the nodes of the connectome 
% ARGUMENTS:
%         msing_obj   -- a MatFile or structure handle pointing to the singularities
%         locs        -- a 2D array of size [num_nodes x 3], with the 3d
%                        locations of brain regions/sources/vertices
% OUTPUT:
%         tracking_matrix   -- a 3D array of size [8 x num_nodes x tpts]
%                              filled with 0s and 1s, if the node was close to a singularity, at that time point. 
%         transition_matrix -- a 2D matrix of size [num_nodes x tpts],
%                              filled with integers representing
%                              singularities 
% REQUIRES:
%         s3d_get_numlabel()
%         dis()
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer October 2019
% USAGE:
%{
    
%}

if nargin < 3
    dis_th = 30; % mm distance threhsold for a singularity to be considered to happen at(ish) a node.
end

% NOTE: Perhaps we shpuld do this once at the end of the classificationa and
% store in the file.
singularity_list_num = s3d_get_numlabel(msing_obj.singularity_classification_list);
tpts = length(singularity_list_num);

% Quantify only critical points
num_base_sngs = 8;
num_nodes = size(locs, 1);

% Preallocate stuff
tracking_matrix(num_base_sngs, num_nodes, tpts) = 0;
transition_matrix(num_nodes, tpts) = 0;
null_points_3d = mfile_sing.null_points_3d;

% NOTE: The following nested for loops are surprisingly fast
for tt=1:tpts
    for nn=1:size(locs, 1)
         sings_temp = singularity_list_num{tt};
         idx = find(sings_temp <= num_base_sngs);
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


% Some statistics
% The following matrix gives an idea of how much time a nodes is (close to)
% a specific singularity. 
nodal_occupancy_matrix = sum(tracking_matrix, 3);

% Find the singularity that is most frequent (in time) in each region
% sing_indx is a 1 x num_nodes vector whose elements are the numeric label
% of the singularity with the highest occupancy value
[max_occupancy, sing_idx] = max(nodal_occupancy_matrix); % probably divide by time_period/num_frames so as to 

% sum across occupancy of different singularity types, total occupancy is time spent as a valid
% type of singularity vs none/undefined.
total_nodal_occupancy = sum(nodal_occupancy_matrix, 1);

% Find valid indices of nodes/regions that spend most of the time being a
% particular type of singularity
valid_node_idx = find(sing_idx & total_nodal_occupancy);

% Singularity types of the nodes that actually soend time close to a
% singularity. There will be repetition because the same singularity can be
% assigned to multiple regions, which is fine as it should give us an idea
% of a continuum for fine-grained parcellations.
sing_type = sing_idx(valid_node_idx);

% Plot the occupancy of every type of singularity for valid nodes
stairs(nodal_occupancy_matrix(:, valid_node_idx).')


bh = bar(nodal_occupancy_matrix(:, valid_node_idx).', 'stacked');
colormap(cmap)

end % function analyse_nodal_occupancy()