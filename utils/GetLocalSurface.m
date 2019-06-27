%% Return a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS:
%           triobj -- a triangulation object for the whole triangulated surface
%                     or a struct with fields .vertices and .faces
%           focal_vertex -- <description>
%           Neighbourhood -- <description>
%
% OUTPUT: 
%         LocalVertices  -- <description>
%         LocalTriangles -- <description>
%
% REQUIRES: 
%         none
%         
% USAGE:
%{
      load('Cortex_213.mat', 'Vertices', 'Triangles', 'VertexNormals'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
      tr = TriRep(Triangles, Vertices); % Convert to TriRep object
      [LocalVertices LocalTriangles GlobalVertexIndices GlobalTriangleIndices nRing] = GetLocalSurface(tr, 42, 3);    
%}
%
% MODIFICATION HISTORY:
%     SAK(22-07-2010) -- Original.
%     PSL(21-12-2018) -- Updated to use Matlab's triangulation or a struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [loc_vertices, loc_triangles, glob_vertex_indices, glob_triangle_indices, nth_ring] = GetLocalSurface(triobj, focal_vertex, Neighbourhood)
%% Set any argument that weren't specified
 if nargin<3,
   Neighbourhood = 1;
 end
 % Get indices of local vertices and triangles 
 loc_vertices = focal_vertex;
 loc_triangles = [];
 new_vertices = FocalVertex;
 nth_ring = zeros(1,Neighbourhood);
 for k = 1:Neighbourhood,
   TrIndices = vertexAttachments(tr, newVertices); 
   newTriangles = setdiff(unique([TrIndices{:}].'),                 loc_triangles);   %
   newVertices  = setdiff(unique(tr.Triangulation(newTriangles,:)), loc_vertices);    %find vertices that make up that set of triangles
   nth_ring(1,k) = length(newVertices);
   
   loc_triangles = [loc_triangles ; newTriangles];
   loc_vertices  = [loc_vertices  ; newVertices];
 end
 
  if nargout>2,
    glob_vertex_indices   = loc_vertices;
  end
  if nargout>3,
    GlobalTriangleIndices = loc_triangles;
  end
 
 loc_triangles = tr.Triangulation(loc_triangles,:);
 % Map triangles from "vertices" indices to "LocalVertices" indices 
 temp = zeros(size(loc_triangles));
 for j = 1:length(loc_vertices) 
   temp(loc_triangles==loc_vertices(j)) = j;
 end
 loc_triangles = temp;
 loc_vertices = tr.X(loc_vertices,:);
  
%% 

end %function GetLocalSurface()