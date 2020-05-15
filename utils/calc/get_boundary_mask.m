function get_boundary_masks(params, obj_data, left_idx, right_idx)
%% Returns a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS: params    -- almighty structure
%            obj_data  -- handle to matfile with original unstructured data
%            left_idx  -- indices of nodes on the left hemisphere
%            right_idx -- indices of nodes on the right hemisphere
%
% OUTPUT: 
%         None, saves automagically to obj_data    
%         
% REQUIRES: 
%         
% USAGE:
%{
     
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the convex hull of scattered points for each hemisphere separately and both

% Calculate individual convex hulls


num_nodes_left = length(left_idx);
num_nodes_right = length(right_idx);

tri_left  = get_boundary_triangles(obj_data.locs(left_idx, :), params.data.boundary.alpha_radius);
tri_right = get_boundary_triangles(obj_data.locs(right_idx, :), params.data.boundary.alpha_radius);
tri_right = tri_right + num_nodes_left; % fix numbering of vertex indices, assumes all the left nodes are contiguous

tri_both = get_boundary_triangles(obj_data.locs, params.data.boundary.alpha_radius);

masks.inner_triangles_bi = tri_both;
masks.inner_triangles_lr = [tri_left; tri_right]


obj_data.masks = masks;

end % get_boundary_masks()

function get_boundary_triangles(locs, alpha_radius)
shp = alphaShape(locs, alpha_radius);
% The boundary of the centroids is an approximation of the cortex
tri_list = shp.boundaryFacets;
end