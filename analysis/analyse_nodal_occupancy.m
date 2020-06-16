function [params, output] = analyse_singularity_occupancy(params)
%function [nodal_occupancy_matrix, total_nodal_occupancy, transition_matrix, tracking_matrix, valid_node_idx] = analyse_nodal_occupancy(msing_obj, locs, nodes_str_lab, dis_th)
% This function calculates singularity occupancy rates at the nodes of the connectome 
% ARGUMENTS:
%         msing_obj   -- a MatFile or structure handle pointing to the singularities
%         locs        -- a 2D array of size [num_nodes x 3], with the 3d
%                        locations of brain regions/sources/vertices
% OUTPUT:
%         tracking_3D_matrix   -- a 3D array of size [8 x num_nodes x tpts]
%                                filled with 0s and 1s, if the node was close to a singularity, at that time point. 
%         tracking_2D_matrix -- a 2D array of size [num_nodes x tpts],
%                               filled with integers representing
%                               singularities 
% REQUIRES:
%         s3d_str2num_label()
%         dis()
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer October 2019
% USAGE:
%{
    
%}

obj_singularity = load_iomat_singularity(params);
obj_flows = load_iomat_flows(params);

if nargin < 3 || isempty(node_str_lab)
    for nn=1:size(locs, 1)
        nodes_str_lab{nn} = num2str(nn, '%03d');
    end
end

dist_threshold = params.singularity.qunatification.nodal_occupancy.distance_threshold;


% Sizes
tpts = params.flows.data.shape.t;
num_base_sngs = 8; % Hardcoded
num_nodes = size(locs, 1);

locs = obj_flows.locs;


% Preallocate arrays
tracking_3d_matrix(num_base_sngs, num_nodes, tpts) = 0;
tracking_2d_matrix(num_nodes, tpts) = 0;

% Load data
null_points_3d = obj_singularity.nullflow_points3d;

% Convert to cell
n3d_cell =  squeeze(struct2cell(null_points_3d));

% NOTE: The following nested for loops are surprisingly fast
classification_num = obj_singularity.classification_num;

parfor tt=1:tpts
    sings_temp = classification_num{tt};
    [tracking_3d_matrix(:, :, tt), tracking_2d_matrix(:, tt)] = step_nodal_occupancy_singularity(sings_temp, n3d_cell(tt), locs, num_base_sngs, dist_threshold);
end

% The following matrix gives an idea of how much time a nodes spends time being 
% or is (close to) a particular singularity type. 
nodal_occupancy_matrix = sum(tracking_3d_matrix, 3);

% Find the singularity that is most frequent (in time) in each region
% sing_indx is a 1 x num_nodes vector whose elements are the numeric label
% of the singularity with the highest occupancy value
% This is choice, as we could have the case two singularities with the same
% occupancy, but that's a problem for later. 
[~, nodal_max_occupancy_idx] = max(nodal_occupancy_matrix); 

% Sum across occupancy of different singularity types, total occupancy is time spent as a valid
% type of singularity vs none/undefined.
nodal_time_occupancy = sum(nodal_occupancy_matrix, 1);

% Find valid indices of nodes/regions that spend most of the time being a
% particular type of singularity
valid_node_idx = find(nodal_max_occupancy_idx & nodal_time_occupancy);

% Singularity types of the nodes that actually soend time close to a
% singularity. There will be repetition because the same singularity can be
% assigned to multiple regions, which is fine as it should give us an idea
% of a continuum for fine-grained parcellations.
singularity_type = nodal_max_occupancy_idx(valid_node_idx);

% Save stuff
obj_singularity.tracking_3d_matrix = tracking_3d_matrix;
obj_singularity.tracking_2d_matrix = tracking_2d_matrix;
obj_singularity.nodal_occupancy_matrix = nodal_occupancy_matrix;

end % function analyse_nodal_occupancy()


