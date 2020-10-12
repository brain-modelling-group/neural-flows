%% Return a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS:
%           surfobj      -- a triangulation object for the whole triangulated surface
%                           or a struct with fields .vertices and .faces
%           focal_vertex -- an integer, with the central index whose nth-neighbourhood we're extracting 
%           nth-ring     -- an integer, indicating the maximum to be extracted
%
% OUTPUT: 
%         loc_vertices  -- an array of size [n x 3] with the cooordinates of the vertices 
%         loc_triangles -- an array of size [n x 3] with the local indices
%                          of vertices making up the local traingles of the patch 
%
% REQUIRES: 
%         Matlab's triangulation function
%         
% USAGE:
%{
      surfobj = triangulation(Triangles, Vertices);  
      % or
      surfobj.vertices = Vertices;
      surfobj.faces = Triangles.
      focal_vertex = 42;
      nth_ring = 3;
      [loc_vertices, loc_triangles, ...
       glob_vertex_indices, glob_triangle_indices, ...
       nth_ring = get_local_surface(surfobj, focal_vertex, nth_ring);    
%}
%
% MODIFICATION HISTORY:
%     SAK(22-07-2010) -- Original.
%     PSL(21-12-2018) -- Updated to use Matlab's triangulation or a struct,
%                        document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [loc_vertices, loc_triangles, glob_vertex_indices, glob_triangle_indices, nth_ring_size] = get_local_surface(surfobj, focal_vertex, nth_ring)
%% Set any argument that weren't specified
 if nargin < 3
   nth_ring = 1;
 end
 
 if isstruct(surfobj)
     surfobj = triangulation(surfobj.faces, surfobj.vertices);
 end
 
 % Get indices of local vertices and triangles 
 loc_vertices = focal_vertex;
 loc_triangles = [];
 new_vertices = focal_vertex;
 nth_ring_size = zeros(1, nth_ring);
 
 for k = 1:nth_ring
   tri_indices   = vertexAttachments(surfobj, new_vertices); 
   new_triangles = setdiff(unique([tri_indices{:}].'), loc_triangles);   %
   %find vertices that make up that set of triangles
   new_vertices  = setdiff(unique(surfobj.ConnectivityList(new_triangles,:)), loc_vertices);    
   nth_ring_size(1, k) = length(new_vertices);
   loc_triangles = [loc_triangles; new_triangles]; %#ok<AGROW>
   loc_vertices  = [loc_vertices; new_vertices];   %#ok<AGROW>
 end
 
 % Save indices of vertices and triangles wrt to whole surface object
 glob_vertex_indices   = loc_vertices;
 glob_triangle_indices = loc_triangles;

 
 loc_triangles = surfobj.ConnectivityList(loc_triangles,:);
 % Map triangle indices from global to local, and 
 % map their vertices from global to local "local_vertices" indices 
 temp = zeros(size(loc_triangles));
 for jj = 1:length(loc_vertices) 
   temp(loc_triangles == loc_vertices(jj)) = jj;
 end
 loc_triangles = temp;
 loc_vertices  = surfobj.Points(loc_vertices,:);
  
end %function get_local_surface()