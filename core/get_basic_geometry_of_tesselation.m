function [gradient_basis, triangle_areas, face_normals] = get_basic_geometry_of_tesselation(faces, vertices, embedding_dimension)
% Computes some geometric quantities from a triangulated domain/tesselation.
% 
% ARGUMENTS:
%   faces                     -- a 2D array of size [num_faces x 3]
%                                defining triangles of tesselation.
%   vertices                  -- a 2D array of size [num_vertices x 2/3]
%                                with the locations of the vertices in the embedding space
%   embedding_dimension       -- an integer specifying the dimension of the embedding space 
%                                3 for cortical surface (default)
%                                2 for plane (channel cap, etc)
% OUTPUTS:
%   gradient_basis   --  a cell of size [1 x embedding dimension] with the
%                        gradient of basis function (FEM) on each triangle. 
%                        Each element of the cell contains a [num_faces x
%                        embedding_dimension].
%   triangle_areas 	 --  a vector of size [num_faces x 1] with the areas of each triangle
%   face_normals     --  a 2D array of size [num_faces x 3] and  normal of each triangle.
%                        The array is empty if the embedding dimension is 2.
%                       
% REQUIRES: 
%         None()
%
% USAGE:
%{     
   load('neural_flows_cortex_mesh')
   [gradient_basis, triangle_areas, face_normals] = get_basic_geometry_of_tesselation(cortex.faces, cortex.vertices);

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer 2018

if nargin < 3
    embedding_dimension = 3;
end

% Idiomatic indexing
vertex_0 = 1;
vertex_1 = 2;
vertex_2 = 3;

% Edges of each triangles
u = vertices(faces(:, vertex_1),:) - vertices(faces(:, vertex_0),:);
v = vertices(faces(:, vertex_2),:) - vertices(faces(:, vertex_1),:);
w = vertices(faces(:, vertex_0),:) - vertices(faces(:, vertex_2),:);

% Edge lengths
uu = sum(u.^2, 2);
vv = sum(v.^2, 2);
ww = sum(w.^2, 2);

% Angles between pair of edges
uv = sum(u.*v, 2);
vw = sum(v.*w, 2);
wu = sum(w.*u, 2);

% 3x heights of each triangle and their norm, with respect to each edge
h1 = w-((vw./vv)*ones(1, embedding_dimension)).*v;
h2 = u-((wu./ww)*ones(1, embedding_dimension)).*w;
h3 = v-((uv./uu)*ones(1, embedding_dimension)).*u;
hh1 = sum(h1.^2, 2);
hh2 = sum(h2.^2, 2);
hh3 = sum(h3.^2, 2);

% Gradient of the 3 basis functions on a triangle 
gradient_basis = cell(1, embedding_dimension);
gradient_basis{1} = h1./(hh1*ones(1, embedding_dimension));
gradient_basis{2} = h2./(hh2*ones(1, embedding_dimension));
gradient_basis{3} = h3./(hh3*ones(1, embedding_dimension));

% Remove pathological gradients
indices1 = find(sum(gradient_basis{1}.^2,2)==0|isnan(sum(gradient_basis{1}.^2,2)));
indices2 = find(sum(gradient_basis{2}.^2,2)==0|isnan(sum(gradient_basis{2}.^2,2)));
indices3 = find(sum(gradient_basis{3}.^2,2)==0|isnan(sum(gradient_basis{3}.^2,2)));

min_norm_grad = min([ sum(gradient_basis{1}(sum(gradient_basis{1}.^2,2) > 0,:).^2,2); ...
                      sum(gradient_basis{2}(sum(gradient_basis{2}.^2,2) > 0,:).^2,2); ...
                      sum(gradient_basis{3}(sum(gradient_basis{3}.^2,2) > 0,:).^2,2) ...
                    ]);
% Replace pathological gradients with the min_norm
gradient_basis{1}(indices1,:) = repmat([1 1 1]/min_norm_grad, length(indices1), 1);
gradient_basis{2}(indices2,:) = repmat([1 1 1]/min_norm_grad, length(indices2), 1);
gradient_basis{3}(indices3,:) = repmat([1 1 1]/min_norm_grad, length(indices3), 1);

% Area of each triangle/face
triangle_areas = sqrt(hh1.*vv)/2;
% NOTE: There should not be traingles with nan or zero area.
% Checks on the integrity of meshes should be done before.
triangle_areas(isnan(triangle_areas)) = 0;

% Calculate normals to surface at each face
if embedding_dimension == 3
    face_normals = cross(w, u);
    face_normals = face_normals./repmat(sqrt(sum(face_normals.^2,2)), 1, 3);
else
    face_normals = [];
end

end % function get_basic_geometry_of_tesselation()