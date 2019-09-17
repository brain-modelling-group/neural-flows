function [energy_sum, energy_face, energy_vertex] = kinetic_energy_tess(flow_field, surf_tess, embedding_dimension)
% Csompute_energy_states  Computation of low and high energy states based on optical flow estimates 
% ARGUMENTS:
%   flow_field          -- an array with optical flow field of size
%                          [vertices, 3, timepoints], or [vertices, 2, timepoints]
%   surf_tess           -- structure with the tesselation of the spatial
%                          domain.
%          .vertices    -- an array of size (vertices, 3) or (vertices, 2)
%          .faces   -- an array of size (2-v+e, 3) for triangular
%                          meshes/surfaces with genus=0
%          
%   embedding_dimension -- dimension of the embedding space 
%                          3: for mesh surfaces  (eg, sphere)
%                          2: for projections on 2D (eg, disk)
%
%   energy_mode         -- string with the mode we should use to
%                          calculate energy. {'vertex', 'face'}
% OUTPUT:
%
%   energy_sum             -- Displacement energy in the flow,
%                             summed over space. 
%   energy_face            -- Displacement energy in the flow field,
%                             returns energy for every face area of the mesh
%                             array of size [num_faces, interval(2)-interval(1)]
% 
%   energy_vertex          -- displacement energy  in the flow field,
%                             returns energy for every vertex area in the domain
% REQUIRES: 
%         get_basic_geometry_of_tesselation()
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer 2018
%
% REFERENCE:
% Julien Lefèvre and Sylvain Baillet
% Estimation of Velocity Fields and Propagation on Non-Euclidian Domains: Application
% to the Exploration of Cortical Spatiotemporal Dynamics
% Lecture Notes in Mathematics 1983, DOI 10.1007/978-3-642-03444-2 5,
% Springer-Verlag Berlin Heidelberg 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vx0 = 1;
vx1 = 2;
vx2 = 3;

% NOTE: Displacement energy, this is a kinectic energy-like expression: 1/2 m v^2
% The mass is m=1, although vertices could have different masses/weigths (eg, hubs/nonhubs)
% This step calculates the kinetic energy per edge (between vertex pairs)
% adds them all and multiply it by the area of the triangle.

[~, triangle_areas, ~] = get_basic_geometry_of_tesselation(surf_tess.faces, surf_tess.vertices, embedding_dimension);

% Preallocate memory
energy_sum  = zeros(1, size(flow_field, 3)); % Energy at each vertex 
energy_face = zeros(size(surf_tess.faces, 1), size(flow_field,3)); % Energy per face
%      vx0
%      /\
%     /  \
%    /    \
%   --------
% vx1      vx2

for tpt = 1:size(flow_field, 3)
  % Average kinetic energy between vertex 0 and vertex 1  
  v12 = sum((flow_field(surf_tess.faces(:, vx0),:,tpt) + flow_field(surf_tess.faces(:, vx1), : , tpt)).^2, 2) / 4;
  % Average kinetic energy between vertex 1 and vertex 2   
  v23 = sum((flow_field(surf_tess.faces(:, vx1),:,tpt) + flow_field(surf_tess.faces(:, vx2), : , tpt)).^2, 2) / 4;
  % Average kinetic energy between vertex 0 and vertex 2  
  v13 = sum((flow_field(surf_tess.faces(:, vx0),:,tpt) + flow_field(surf_tess.faces(:, vx2), : , tpt)).^2, 2) / 4;
  energy_sum(tpt) = sum(triangle_areas.*(v12 + v23 + v13));
  energy_face(:, tpt) = triangle_areas.*(v12 + v23 + v13);
end


%Energy per vertex area NOTE: this quantity needs to be scaled by the voronoi area
xdim = 1;
ydim = 2;
zdim = 3;
energy_vertex = squeeze((((flow_field(:, xdim, :).^2 + flow_field(:, ydim, :).^2 + flow_field(:, zdim, :).^2)/2)));

if strcmp(energy_mode, 'vertex')
  % replace original vector with vertex-based energy
  energy_sum = sum(energy_vertex);
end
end % end calculate_kinetic_energy()
