function [nth_ring_matrix] = get_nth_ring_matrix(tr, focus_vertex_idx_list, nth_ring)
%% Returns a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS:
%           tr                    -- a Matlab's triangulation object with the original/complete lobal surface
%           focus_vertex_idx_list -- a 1D array (column vector) of size (n x 1) with the indices of the vertices for which we will extract the nth ring           
%           nth_ring              -- an integer describing how many rings around the focal vertices we need.
%
% OUTPUT: 
%         nth_ring_matrix -- a sparse matrix with nonzero entries if the
%                            vertices are part of the nth ring neighbourhood. Weight is 1 divided by number of neighbours. 
% REQUIRES: 
%         Matlab's triangulation and get_nth_ring()
%         
% USAGE:
%{
      load('CortexBdy_alpha-30_513parc.mat', 'Vertices', 'Triangles'); 
      tr = triangulation(Triangles, Vertices); % Convert to triangulation object
      focus_vx_idx_list = [1:513].';
      nth_ring = 1;
      [nth_ring_matrix] = get_nth_ring_matrix(tr, focus_vx_idx_list, nth_ring);    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 if nargin <3
   nth_ring = 1;
 end
 
 num_vertices = size(focus_vertex_idx_list, 1);
 nth_ring_matrix = sparse(num_vertices, num_vertices); 

 for vv = 1:num_vertices
     [~, ~, global_vx_indices, ~, nth_ring_size] = get_nth_ring(tr, focus_vertex_idx_list(vv), nth_ring);
     nth_ring_matrix(vv, global_vx_indices(2:end)) = 1/max(nth_ring_size);
 end
 
 
end % function get_nth_ring_matrix()
