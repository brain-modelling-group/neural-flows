function [flow_fields, int_dflow, error_data, error_reg, poincare_idx, time_flow] = estimate_flow_tess(data, cortex, time_data, idx_start, idx_end, hs_smoothness, embedding_dimension)
%% This fuction estimates the (neural) flow fields of data on the cortical surface,
%  that is on a discrete triangulated representation of a curved manifold, embedded in 
%  3D Euclidean space.
%  While it has been mainly developed for EEG, MEG reconstructed source timeseries,
%  it should work for any surface and any type of data. 
%  The function also kind of works for "channel" space, assuming that the data was
%  projected to a 2D topographic map, and that space has been tesselated.   
% 
% ARGUMENTS:
%   data                -- A 2D array of size [number_of_vertices x timepoints] with reconstructed sources timeseries.
%   cortex              -- Triangular mesh representing the cortex. A structure with fields:
%                           .faces
%                           .vertices
%                           .vertex_normals
%   time_data           -- 1D vector. Time vector of data.  
%   idx_start           -- Integer. Index of first time point for optical flow analysis  
%   idx_end             -- Integer. Index of last time point for optical flow analysis    
%   hs_smoothness       -- Float. Smoothness parameter of Horn-Schunck method. Values in [0, 1].
%   embedding_dimension -- Integer 2 or 3. Use 3 for surfaces in 3D  and 2 for projected M/EEG maps.
%                          Default: 3.
%    
% OUTPUT:
%   flow_fields       -- Velocity vector fields. A 3D array of size [embedding_dimension x number_of_vertices x length(idx_start:idx_end)-1]
%   int_dflow         -- Constant term in variational formulation (see refs)
%   error_data        -- Error in fit to data
%   error_reg         -- Energy in regularization
%   poincare_idx      -- Triangle-based Poincare index. This is index determines the type of critical point.
%   time_flow         -- Time vector for flow fields. Should be (time_data(1:end-1)+time_data(2:end))/2.
%
% AUTHOR:
%     Julien Lefevre  
%     Paula Sanz-Leon 

% REFERENCES
% USAGE:
%{
    % TODO: add example
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


if nargin < 7
    embedding_dimension = 3;
    flow_components = 3;
end

% NOTE: not sure this is correct?
if embedding_dimension == 2
    flow_components = 2;
end
    
% Get some info and local variables
faces    = cortex.faces; 
vertices = cortex.vertices; 

% Get vertex normals
if isfield(cortex, 'vertex_normals') 
  vertex_normals = cortex.vertex_normals;
elseif (~isfield(cortex, 'vertex_normals') && (embedding_dimension == 3))  
  TR = triangulation(faces, vertices);
  vertex_normals = vertexNormal(TR);
else 
  vertex_normals = [];
end

num_vertices = size(vertices, 1);
num_faces    = size(faces, 1);
time_flow = (time_data(idx_start:idx_end-1) + time_data(idx_start+1:idx_end))/2;
interval_length = idx_end - idx_start; % Number of timepoints used in flow calculations

% Get data we're going to use, dismiss the rest
data    = data(:, idx_start:idx_end);
max_val = max(abs(data(:)));
% Scale values to avoid precision error, 
% NOTE: maybe try with standardised ranges (eg, [-1 1],[0, 1]).
%data = data/max_val; 

% Preallocate output arrays
flow_fields(num_vertices, embedding_dimension, interval_length) = 0;
error_data(1, interval_length) = 0;
error_reg(1, interval_length) = 0;
int_dflow(1, interval_length) = 0;
poincare_idx(num_faces, interval_length) = 0;

[regularizer_matrix, gradient_basis, ...
 tangent_plane_basis_cell, tangent_plane_basis, ...
 triangle_areas, face_normals, ...
 sparse_idx1, sparse_idx2] =  regularizing_matrix_hs(faces, vertices, vertex_normals, embedding_dimension);

% Scale regularising term by the smoothness parameter.
regularizer = hs_smoothness * regularizer_matrix;

% Some constants
vx_per_face = 3;

% Projection of flow onto triangles/triangle edges (for Poincare index)
flow_projection = zeros(vx_per_face, vx_per_face, num_faces);

for face_idx = 1:num_faces
    flow_projection(:, :, face_idx) = eye(3) - (face_normals(face_idx, :)'*face_normals(face_idx, :));
end

dt = time_data(2) - time_data(1);
% Start estimation of flows
for tt_idx  = 2:interval_length 
    % TODO: I think this term should be scaled by the time step.
    delta_activity = (data(:, tt_idx) - data(:, tt_idx-1));
    [data_fit, B]  = data_fit_matrix(faces, num_vertices, ...
                                    gradient_basis, triangle_areas, tangent_plane_basis_cell, ...
                                    data(:, tt_idx), delta_activity, embedding_dimension, ...
                                    sparse_idx1, sparse_idx2);
  
  % NOTE: Solve system of equations -- this may be the worst offender in terms of runtime
  X = (data_fit + regularizer) \ B;
  
  % Save flows correctly (for a surface embedded in 3D, have to project data back to 3D)
  if embedding_dimension == 3 % X coordinates are in tangent space
      % TODO: avoid using repmat: try to use smart inexing here
      % TODO: idiomatic indexing. Also dividing by two is begging for an indexing
      %       error to happen.
      flow_fields(:, :, tt_idx-1) = repmat(X(1:end/2), [1, 3]) .* tangent_plane_basis(:, :, 1) + repmat(X(end/2+1:end), [1,3]) .* tangent_plane_basis(:,:,2);
  else % 
      flow_fields(:, :, tt_idx-1) = [X zeros(num_vertices, 1)];
  end
  
  error_data(1, tt_idx-1)= X'*data_fit*X - 2*B'*X; % Data fit error
  error_reg(1, tt_idx-1) = X'*regularizer*X;       % Regularization error

  % Variational formulation constant
  vertex_0 = 1;
  vertex_1 = 2;
  vertex_2 = 3;

  dF01 = (delta_activity(faces(:,vertex_0),:) + delta_activity(faces(:,vertex_1))).^2;
  dF12 = (delta_activity(faces(:,vertex_1),:) + delta_activity(faces(:,vertex_2))).^2;
  dF02 = (delta_activity(faces(:,vertex_0),:) + delta_activity(faces(:,vertex_2))).^2;
  int_dflow(tt_idx) = sum(triangle_areas.*(dF01 + dF12 + dF02))/24;
  
  % Precompute flow_fields on faces to save time in the loop.
  faces_flow_fields = reshape(flow_fields(faces', :, tt_idx-1)', [flow_components, vx_per_face, num_faces]);
  
  % Calculate Poincare index of each triangle
  for face_idx=1:num_faces
      % projection of flow_fields(this_face, : ,t) on triangle f
      poincare_idx(face_idx, tt_idx-1) = poincare_index(flow_projection(:, :, face_idx) * faces_flow_fields(:, :, face_idx));  
          
  end

end 

  
end % function estimate_flow_surf()

% Auxiliary functions
function [gradient_basis, triangle_areas, face_normals] = get_basic_geometry_of_tesselation(faces, vertices, embedding_dimension)
% Computes some geometric quantities from a triangulated domain/tesselation.
% 
% INPUTS:
%   faces                     - triangles of tesselation
%   vertices                  - coordinates of nodes
%   embedding_dimension       - 3 for cortical surface (default)
%                               2 for plane (channel cap, etc)
% OUTPUTS:
%   gradient_basis   - gradient of basis function (FEM) on each triangle
%   triangle_areas 	 - area of each triangle
%   face_normals     - normal of each triangle 


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
% Angles
uv = sum(u.*v, 2);
vw = sum(v.*w, 2);
wu = sum(w.*u, 2);

% 3 heights of each triangle and their norm
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

end


%% ===================== Calculate the tesselation's tangent bundle ============
function tangent_plane_basis = calculate_tangent_plane_basis(vertex_normals)
% Gives the orthonormal basis orthogonal to the vertex normals (eg, tangent plane)
%
% INPUTS:
%   vertex_normals    - a 2D array of size [number_of_vertices x 3] 
%
% OUTPUTS:
%   tangent_plane_basis - for each vertex, a pair of vectors defining
%                         the orthonormal basis of a tangent plane to that vertex,
%                         based on the (vertex) normal to the surface.
% Shortcut: if [x y z] is the normal-to-surface, then the tangent plane
% includes the vector defined by [z-y, x-z, y-x]

vector_components = 3;
num_basis_vectors = 2;
number_of_vertices  = size(vertex_normals, 1); 
vertex_normals      = -vertex_normals;
tangent_plane_basis = zeros(number_of_vertices, vector_components, num_basis_vectors);

% First vector in basis: [3-2 1-3 2-1]
zdim = 3;
ydim = 2;
xdim = 1;
basis_vec_1 = 1;
basis_vec_2 = 2;
tangent_plane_basis(:, :, 1) = diff(vertex_normals(:, [ydim zdim xdim ydim]).').';

% Correct for [1 1 1]-ish vertices: use [y -x 0]
bad = abs(dot(vertex_normals, ones(number_of_vertices,3)/sqrt(3), 2)) > 0.97;
tangent_plane_basis(bad, :, basis_vec_1) = [ vertex_normals(bad, ydim), ...
                                            -vertex_normals(bad, xdim), ...
                                                 zeros(sum(bad), xdim)];

% Second vector in basis found by cross product with the vertex normals
tangent_plane_basis(:, :, basis_vec_2) = cross(vertex_normals, tangent_plane_basis(:, : , basis_vec_1));

% Normalize to get orthonormal basis
tangent_planes_basis_norm = sqrt(sum(tangent_plane_basis.^2, 2));
tangent_plane_basis = tangent_plane_basis ./ tangent_planes_basis_norm(:,[1 1 1], :);

end

%% ===== HORN-SCHUNCK REGULARIZATION MATRIX (FOR MANIFOLD) =====
function [regularizer, gradient_basis, tangent_plane_basis_cell, ...
          tangent_plane_basis, triangle_areas, face_normals, ...
          sparse_idx1,sparse_idx2] = regularizing_matrix_hs(faces, vertices, vertex_normals, embedding_dimension)
% Computation of the regularizing part for the HS algorithm 
% in the variational approach (SS grad(v_k)grad(v_k')) and
% other geometrical quantities (eg, normals).
%
%
% INPUTS
%   faces                   - triangles of the tesselation
%   vertices                - vertices of the tesselation
%   vertex_normals          - normals to surface at each vertex
%   embedding_dimension     - 3 for scalp or cortical surface
%                             2 for flat surface
% OUTPUTS :
%   regularizer             - regularizing matrix
%   gradient_basis          - gradient of the basis functions in FEM
%   tangent_plane_basis_cell   - basis of the tangent plane at a surface vertex
%                             --> nodes listed according to tesselation
%   tangentPlaneBasis       - basis of the tangent plane at each vertex
%   triangle_areas          - area of the triangles
%   face_normals            - normal of each triangle
%   sparse_idx1            - 1st index of sparse tangent basis magnitudes
%   sparse_idx2            - 2nd index of sparse tangent basis magnitudes
%
% AUTHOR:
% Julien Lefevre circa 2010

num_vertices = size(vertices, 1); 
num_basis_vectors = 2;
num_vertex_per_face = 3;
[gradient_basis, triangle_areas, face_normals] = get_basic_geometry_of_tesselation(faces, vertices, embedding_dimension);

% Basis of the tangent plane at each vertex
tangent_plane_basis = calculate_tangent_plane_basis(vertex_normals);
tangent_plane_basis_cell = cell(num_basis_vectors, num_vertex_per_face); 

% Idiomatic indexing
tp_basis_vec_1 = 1;
tp_basis_vec_2 = 2;
vertex_0 = 1;
vertex_1 = 2;
vertex_2 = 3;

tangent_plane_basis_cell{tp_basis_vec_1, vertex_0} = tangent_plane_basis(faces(:, vertex_0),:,tp_basis_vec_1);
tangent_plane_basis_cell{tp_basis_vec_1, vertex_1} = tangent_plane_basis(faces(:, vertex_1),:,tp_basis_vec_1);
tangent_plane_basis_cell{tp_basis_vec_1, vertex_2} = tangent_plane_basis(faces(:, vertex_2),:,tp_basis_vec_1);

tangent_plane_basis_cell{tp_basis_vec_2, vertex_0} = tangent_plane_basis(faces(:, vertex_0),:,tp_basis_vec_2);
tangent_plane_basis_cell{tp_basis_vec_2, vertex_1} = tangent_plane_basis(faces(:, vertex_1),:,tp_basis_vec_2);
tangent_plane_basis_cell{tp_basis_vec_2, vertex_2} = tangent_plane_basis(faces(:, vertex_2),:,tp_basis_vec_2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Regularizing matrix SS grad(v_k)grad(v_k') %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
sparse_idx1 = [faces(:, vertex_0) faces(:, vertex_0) faces(:, vertex_1)];
sparse_idx2 = [faces(:, vertex_1) faces(:, vertex_2) faces(:, vertex_2)];

gradient_basis_sum = [sum(gradient_basis{vertex_0}.*gradient_basis{vertex_1}, 2) ...
                      sum(gradient_basis{vertex_0}.*gradient_basis{vertex_2}, 2) ...
                      sum(gradient_basis{vertex_1}.*gradient_basis{vertex_2}, 2)];

tang_scal_11 = [ ...
  sum(tangent_plane_basis_cell{1,1}.*tangent_plane_basis_cell{1,2}, 2) ...
  sum(tangent_plane_basis_cell{1,1}.*tangent_plane_basis_cell{1,3}, 2) ...
  sum(tangent_plane_basis_cell{1,2}.*tangent_plane_basis_cell{1,3}, 2) ...
  ] .* gradient_basis_sum .* repmat(triangle_areas, [1 3]);
tang_scal_12 = [ ...
  sum(tangent_plane_basis_cell{1,1}.*tangent_plane_basis_cell{2,2}, 2) ...
  sum(tangent_plane_basis_cell{1,1}.*tangent_plane_basis_cell{2,3}, 2) ...
  sum(tangent_plane_basis_cell{1,2}.*tangent_plane_basis_cell{2,3}, 2) ...
  ] .* gradient_basis_sum .* repmat(triangle_areas, [1 3]);
tang_scal_21 = [ ...
  sum(tangent_plane_basis_cell{2,1}.*tangent_plane_basis_cell{1,2}, 2) ...
  sum(tangent_plane_basis_cell{2,1}.*tangent_plane_basis_cell{1,3}, 2) ...
  sum(tangent_plane_basis_cell{2,2}.*tangent_plane_basis_cell{1,3}, 2) ...
  ] .* gradient_basis_sum .* repmat(triangle_areas, [1 3]);
tang_scal_22 = [ ...
  sum(tangent_plane_basis_cell{2,1}.*tangent_plane_basis_cell{2,2}, 2) ...
  sum(tangent_plane_basis_cell{2,1}.*tangent_plane_basis_cell{2,3}, 2) ...
  sum(tangent_plane_basis_cell{2,2}.*tangent_plane_basis_cell{2,3}, 2) ...
  ] .* gradient_basis_sum .* repmat(triangle_areas, [1 3]);

termes_diag = repmat(triangle_areas, [1 3]) .* [ ...
                     sum(gradient_basis{1}.^2,2) ...
                     sum(gradient_basis{2}.^2,2) ...
                     sum(gradient_basis{3}.^2,2) ]; 

D = sparse(faces, faces, termes_diag, num_vertices, num_vertices);
E11=sparse(sparse_idx1, sparse_idx2, tang_scal_11, num_vertices, num_vertices);
E11=E11+E11'+D;
E22=sparse(sparse_idx1, sparse_idx2,tang_scal_22, num_vertices,num_vertices);
E22=E22+E22'+D;
E12=sparse(sparse_idx1, sparse_idx2,tang_scal_12, num_vertices,num_vertices);
E21=sparse(sparse_idx1, sparse_idx2,tang_scal_21, num_vertices,num_vertices);

regularizer = [E11 E12+E21'; E12'+E21 E22];

end

%% ===== HORN-SCHUNCK DATA FIT MATRIX (FOR MANIFOLD) =====
function [data_fit, B] = data_fit_matrix(faces, num_vertices, gradient_basis, ...
                                         triangle_areas, tangent_plane_basis_cell, ...
                                         data, delta_activity, ...
                                         embedding_dimension, sparse_idx1, sparse_idx2)
% Computation of data-fit matrices of the variational formulation
% INPUTS:
%   faces                   - triangles
%   num_vertices            - number of nodes
%   gradient_basis          - gradient of the basis functions
%   triangle_areas          - area of each triangle
%   tangent_plane_basis_cell 	- basis of each tangent plane
%   data                    - activity at time step t
%   delta_activity          - change in activity between two consecutive timesteps
%   embedding_dimension               - 3 for scalp or cortical surface
%                             2 for channel surface or cap
%   sparse_idx1            - 1st index of sparse tangent basis magnitudes
%   sparse_idx2            - 2nd index of sparse tangent basis magnitudes
% OUTPUTS:
%   data_fit                - fit to data matrix:
%                             SS (grad(F).w_k)(grad(F).w_k'), where F--> data
%   B                       - fit to data vector:
%                           - 2SS(dF/dt)(grad(F).v_k), where dF --> change in activity


% Gradient of activity obtained through interpolation
grad_data = repmat(data(faces(:,1)), 1, embedding_dimension) .* gradient_basis{1} ...
          + repmat(data(faces(:,2)), 1, embedding_dimension) .* gradient_basis{2} ...
          + repmat(data(faces(:,3)), 1, embedding_dimension) .* gradient_basis{3};

% Projection of the gradient of 'activity' on the tangent space
proj_grad_data = cell(1, 3); % same structure as gradient_basis : size = num_faces, 3;
for vx_idx=1:3
    for basis_idx=1:2
       proj_grad_data{vx_idx}(:, basis_idx) = sum(grad_data.*tangent_plane_basis_cell{basis_idx, vx_idx}, 2);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Construction of B %%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

B = zeros(2*num_vertices, 1);
for basis_idx=1:2
   for vx_idx=1:3
     B(faces(:, vx_idx)+(basis_idx-1)*num_vertices) = B(faces(:, vx_idx) ...
                                                      + (basis_idx-1)*num_vertices) ...
                                                      + (-1/12 * triangle_areas .* (proj_grad_data{vx_idx}(:, basis_idx)) .* ...
                                                        (delta_activity(faces(:, vx_idx)) + sum(delta_activity(faces), 2)));
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%   Construction of data_fit  %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scal_data_11 = [proj_grad_data{1}(:,1).*proj_grad_data{2}(:,1) ...
                proj_grad_data{1}(:,1).*proj_grad_data{3}(:,1) ...
                proj_grad_data{2}(:,1).*proj_grad_data{3}(:,1)] .* repmat(triangle_areas, [1 3])/12;
scal_data_12 = [proj_grad_data{1}(:,1).*proj_grad_data{2}(:,2) ...
                proj_grad_data{1}(:,1).*proj_grad_data{3}(:,2) ...
                proj_grad_data{2}(:,1).*proj_grad_data{3}(:,2)] .* repmat(triangle_areas, [1 3])/12;
scal_data_21 = [proj_grad_data{1}(:,2).*proj_grad_data{2}(:,1) ...
                proj_grad_data{1}(:,2).*proj_grad_data{3}(:,1) ...
                proj_grad_data{2}(:,2).*proj_grad_data{3}(:,1)] .* repmat(triangle_areas, [1 3])/12;
scal_data_22 = [proj_grad_data{1}(:,2).*proj_grad_data{2}(:,2) ...
                proj_grad_data{1}(:,2).*proj_grad_data{3}(:,2) ...
                proj_grad_data{2}(:,2).*proj_grad_data{3}(:,2)] .* repmat(triangle_areas, [1 3])/12;

scal_data_diag_11 = [proj_grad_data{1}(:,1).*proj_grad_data{1}(:,1) ...
                     proj_grad_data{2}(:,1).*proj_grad_data{2}(:,1) ...
                     proj_grad_data{3}(:,1).*proj_grad_data{3}(:,1)] .* repmat(triangle_areas, [1 3])/6;
scal_data_diag_22 = [proj_grad_data{1}(:,2).*proj_grad_data{1}(:,2) ...
                     proj_grad_data{2}(:,2).*proj_grad_data{2}(:,2) ...
                     proj_grad_data{3}(:,2).*proj_grad_data{3}(:,2)] .* repmat(triangle_areas, [1 3])/6;
scal_data_diag_12 = [proj_grad_data{1}(:,1).*proj_grad_data{1}(:,2) ...
                     proj_grad_data{2}(:,1).*proj_grad_data{2}(:,2) ...
                     proj_grad_data{3}(:,1).*proj_grad_data{3}(:,2)] .* repmat(triangle_areas, [1 3])/6;

S11 = sparse(sparse_idx1, sparse_idx2, scal_data_11, num_vertices, num_vertices);
S22 = sparse(sparse_idx1, sparse_idx2, scal_data_22, num_vertices, num_vertices);
S12 = sparse(sparse_idx1, sparse_idx2, scal_data_12, num_vertices, num_vertices);
S21 = sparse(sparse_idx1, sparse_idx2, scal_data_21, num_vertices, num_vertices);

D11 = sparse(faces, faces, scal_data_diag_11, num_vertices, num_vertices); 
D22 = sparse(faces, faces, scal_data_diag_22, num_vertices, num_vertices);
D12 = sparse(faces, faces, scal_data_diag_12, num_vertices, num_vertices);

data_fit = [S11+S11'+D11 S12+S21'+D12; ...
            S12'+S21+D12 S22+S22'+D22];

end


function index = poincare_index(flow_fields)
%  0: not a critical point:
% -1: saddle
% +1: critical point
% Compute the Poincare index of a vector field along a closed curve (eg, a cricle) 
% INPUT: 
% flow_fields --- projected flow fields onto tangent space. Has dimensions [2, number_of_vectors]
%                 where number_of_vectors could be num_vertices or num_faces

  theta     = myangle(flow_fields);
  difftheta = diffangle([theta(2), theta(3), theta(1)], theta);
  index = sum(difftheta)/(2*pi);
end


function theta = myangle(flow_fields) 
% Calculates the good angle of a vector (between 0 and 2pi)
% INPUTS: 
% OUTPUTS: a 1 x 3 vector with the angle of the flow for each vertex of a triangle 
  x1dim = 1;
  x2dim = 2;
  normv = sqrt(sum(flow_fields.^2, 1));
  c = flow_fields(x1dim,:)./normv;
  s = flow_fields(x2dim,:)./normv;
  theta = acos(c);
  % Vectorised version
  % theta(s < 0) = -theta(s < 0) + 2*pi;
  for ii=1:size(flow_fields, 2)
    if s(ii) < 0
      theta(ii)= -theta(ii) + 2*pi;
    end
  end
end


function theta = diffangle(theta2, theta1)
% Difference of two angles (result between -pi and pi)
% INPUTS:
% OUTPUTS: 

  theta = theta2 - theta1;
  % Vectorized version
  % theta(theta < -pi) = theta(theta < -pi) + 2*pi;
  % theta(theta > pi) = theta(theta > pi) - 2*pi;

  for ii=1:length(theta)
    if theta(ii) < -pi
      theta(ii) = theta(ii) + 2*pi;
    elseif theta(ii) > pi
        theta(ii) = theta(ii) - 2*pi;
    end
  end
end
