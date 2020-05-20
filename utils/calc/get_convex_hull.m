function get_convex_hull(obj_data, alpha_radius, hemi1_idx, hemi2_idx)
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


num_nodes_hemi1 = length(hemi1_idx);

if ~isempty(hemi2_idx)
    tri_hemi1  = get_boundary_triangles(obj_data.locs(hemi1, :), alpha_radius);
    tri_hemi2 = get_boundary_triangles(obj_data.locs(hemi2_idx, :), alpha_radius);
    tri_hemi2 = tri_right + num_nodes_hemi1; % fix numbering of vertex indices, assumes all the left nodes are contiguous
    tri_both = get_boundary_triangles(obj_data.locs, alpha_radius);

    masks.innies_triangles_bi = tri_both;
    masks.innies_triangles_lr = [tri_left; tri_right];
else
    tri_hemi1  = get_boundary_triangles(obj_data.locs(hemi1_idx, :), alpha_radius);
    masks.innies_triangles_bi = tri_hemi1;
    masks.innies_triangles_lr = tri_hemi1; 
end
obj_data.masks = masks;

end % get_boundary_masks()

function tri_list = get_boundary_triangles(locs, alpha_radius)
shp = alphaShape(locs, alpha_radius);
% The boundary of the centroids is an approximation of the cortex
tri_list = shp.boundaryFacets;
end