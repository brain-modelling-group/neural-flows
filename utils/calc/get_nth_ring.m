function [local_vertices, local_triangles, global_vx_indices, global_tri_indices, nth_ring_size] = get_nth_ring(tr, focus_vertex_idx, nth_ring)
%% Returns a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS:
%           tr -- a Matlab's triangulation object with the original/complete lobal surface
%           focus_vertex_idx -- an integer representing the index with the vertex of interest for which           
%           nth_ring -- an integer describing how many rings around the focal vertex we need.
%
% OUTPUT: 
%         local_vertices  -- an array with the vertices of the local patch
%                            representing the nth ring (nvertices x 3)
%         local_triangles -- the indices of the triangles making up the local patch
%         global_vx_indices -- an array with the vertex indices of the
%                              local patch, with numbering is relative to the original surface
%         global_tri_indices -- the indices of the triangles making up the
%                               local patch, but indices are relative to the original surface
%         nth_ring_size -- an array of size 1 x nth_ring, with the size
%                          (ie, num neighbours) of each ring
% REQUIRES: 
%         Matlab's triangulation
%         
% USAGE:
%{
      load('Cortex_reg13_to_513parc.mat', 'Vertices', 'Triangles', 'VertexNormals'); 
      tr = triangulation(Triangles, Vertices); % Convert to triangulation object
      focus_vx_idx = 42;
      nth_ring = 3;
      [local_vertices, local_triangles, global_vx_indices, global_tri_indices, nth_ring_size] = get_nth_ring(tr, focus_vx_idx, nth_ring);    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 if nargin <3
   nth_ring = 1;
 end
 
 % Get indices of local vertices and triangles
 local_vertices = focus_vertex_idx;
 local_triangles = [];
 
 new_vertices = focus_vertex_idx;
 nth_ring_size = zeros(1, nth_ring);
 
 for kk = 1:nth_ring
   tri_indices = vertexAttachments(tr, new_vertices); 
   new_triangles = setdiff(unique([tri_indices{:}].'),                   local_triangles);   %
   new_vertices  = setdiff(unique(tr.ConnectivityList(new_triangles,:)), local_vertices);    %find vertices that make up that set of triangles
   nth_ring_size(1,kk) = length(new_vertices);
   local_triangles = [local_triangles ; new_triangles];
   local_vertices  = [local_vertices  ; new_vertices];
 end
 
  if nargout>2
    global_vx_indices   = local_vertices;
  end
  if nargout>3
    global_tri_indices = local_triangles;
  end
 
 local_triangles = tr.ConnectivityList(local_triangles, :);
 
 % Map triangles from "global vertices" indices to "local vertices" indices 
 temp = zeros(size(local_triangles));
 for j = 1:length(local_vertices) 
   temp(local_triangles==local_vertices(j)) = j;
 end
 local_triangles = temp;
 local_vertices = tr.Points(local_vertices,:);
  
end % function get_nth_ring()
