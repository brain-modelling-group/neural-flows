function params = analyse_nodal_singularity_occupancy(params)
% TODOC
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

% TODO: split function into smaller functions
%       or, save locations into obj_singularity

obj_singularity = load_iomat_singularity(params);
obj_flows = load_iomat_flows(params);


dist_threshold = params.singularity.quantification.nodal_occupancy.distance_threshold;
%dist_threshold = 20;
locs = obj_flows.locs;

% Sizes
tpts = params.flows.data.shape.t;
num_base_sngs = 8; % Hardcoded
num_nodes = size(locs, 1);

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
    [tracking_3d_matrix(:, :, tt), tracking_2d_matrix(:, tt)] = step_nodal_singularity_occupancy(sings_temp, n3d_cell(tt), locs, num_base_sngs, dist_threshold);
end

% The following matrix gives an idea of how much time a nodes spends time being 
% or is (close to) a singularity type. 
% Values are expressed in # time frames
nodal_occupancy_singularity = sum(tracking_3d_matrix, 3);

% Find the singularity that is most frequent (in time) in each region
% sing_indx is a 1 x num_nodes vector whose elements are the numeric label
% of the singularity with the highest occupancy value
% This is choice, as we could have the case two singularities with the same
% occupancy, but that's a problem for later. 
[nodal_max_occupancy, nodal_max_occupancy_idx] = max(nodal_occupancy_singularity); 

% Sum across occupancy of different singularity types, total occupancy is time spent as a valid
% type of singularity vs none/undefined. Size is 1 x num nodes. values are
% in timeframes
nodal_occupancy_total = sum(nodal_occupancy_singularity, 1);

% Find valid indices of nodes/regions that spend most of the time being a
% particular type of singularity
valid_node_idx = find(nodal_max_occupancy & nodal_occupancy_total);

% Singularity types of the nodes that actually send time close to a
% singularity. There will be repetition because the same singularity can be
% assigned to multiple regions, which is fine as it should give us an idea
% of a continuum for fine-grained parcellations.
nodal_singularity_summary.active_nodes.idx = valid_node_idx;
nodal_singularity_summary.active_nodes.singularity = nodal_max_occupancy_idx(valid_node_idx);

nodal_singularity_summary.occupancy_total = nodal_occupancy_total;
nodal_singularity_summary.occupancy_partial = nodal_occupancy_singularity;

% Save stuff
obj_singularity.tracking_3d_matrix = tracking_3d_matrix;
obj_singularity.tracking_2d_matrix = tracking_2d_matrix;
obj_singularity.nodal_singularity_summary = nodal_singularity_summary;

end % function analyse_nodal_singularity_occupancy()
