%% Plot only part of a tessellated surface, return the local surface.
%
% ARGUMENTS:
%           TR -- A matlab TriRep object of the global surface.
%           FocalVertex -- Index of the vertex on which to centre the plot.
%           Neighbourhood -- Number of "rings" to include in plot.
%           normals -- An Nx3 array specifying either Triangle or Vertex normals.
%                      Where N equals either the number of Vertices or Triangles.
%
% OUTPUT: 
%          LocalSurfaceFigureHandle -- <description>
%
% REQUIRES: 
%          TriRep -- A Matlab object, not yet available in Octave.
%          GetLocalSurface() -- Returns a local patch of surface of the 
%                               neighbourhood around a vertex. Is in the
%                               Surfaces directory.
%
% USAGE:
%{    
    ThisSurface = 'reg13';
    load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals');
    tr = TriRep(Triangles, Vertices);
    
    LocalSurfaceFigureHandleVnorm = PlotLocalSurface(tr, 42, 3, VertexNormals);
    %or
    LocalSurfaceFigureHandleTnorm = PlotLocalSurface(tr, 42, 3, TriangleNormals);
   
%}
%
% MODIFICATION HISTORY:
%     SAK(22-07-2010) -- Original.
%     PSL(21-12-2018) -- Use struct or triangulation object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function figure_handle = plot_local_surface(surfobj, focal_vertex, nth_ring, normals)  
  %% Set defaults for any argument that weren't specified
  if nargin<3
    nth_ring = 1;
  end
  if nargin<4
    normals = zeros(size(surfobj.X));
  end
   
 if isstruct(surfobj)
     surfobj = triangulation(surfobj.faces, surfobj.vertices);
 end
  
  number_of_vertices  = size(surfobj.Points, 1);
  number_of_triangles = size(surfobj.ConnectivityList, 1);
  number_of_normals   = size(normals, 1);
  
% Get the local patch of surface from a focal vertex
  switch number_of_normals
    case number_of_vertices
      [local_vertices, local_triangles, global_vertex_indices, ~] = get_local_surface(surfobj, focal_vertex, nth_ring);
      local_normals = normals(global_vertex_indices, :);
    case number_of_triangles
      [local_vertices, local_triangles, ~, global_triangle_indices] = GetLocalSurface(surfobj, focal_vertex, nth_ring);
      local_normals = normals(global_triangle_indices, :);
      local_centres = incenters(surfobj, global_triangle_indices);
    otherwise
      msg = 'The normals should be the size of either *triangles* or *vertices* ...';
      error(['patchflow:vis:' mfilename ':WrongNumberOfNormals'], msg);
  end

% Plot the patch
  figure_handle = figure('Name', 'plot_local_surf');
    
    patch('Faces', local_triangles, 'Vertices', local_vertices, ...
          'Edgecolor',[0.5 0.5 0], 'FaceColor', [0.3 0.3 0.3], 'FaceAlpha',0.3); %
    hold on 
    scatter3(local_vertices(:,1), local_vertices(:,2), local_vertices(:,3), 'g.')
    scatter3(surfobj.Points(focal_vertex, 1), surfobj.Points(focal_vertex,2), surfobj.Points(focal_vertex,3), 'r.')
    
    switch number_of_normals
      case number_of_vertices
        % Plot vertex normals at the vertices
        plot3([local_vertices(:,1).' ; local_vertices(:,1).'+local_normals(:,1).'], ...
              [local_vertices(:,2).' ; local_vertices(:,2).'+local_normals(:,2).'], ...
              [local_vertices(:,3).' ; local_vertices(:,3).'+local_normals(:,3).'], 'b')
      case number_of_triangles
        % Plot triangle normals at the incentres
        scatter3(local_centres(:,1), local_centres(:,2), local_centres(:,3), 'b.')
        plot3([local_centres(:,1).' ; local_centres(:,1).'+local_normals(:,1).'], ...
              [local_centres(:,2).' ; local_centres(:,2).'+local_normals(:,2).'], ...
              [local_centres(:,3).' ; local_centres(:,3).'+local_normals(:,3).'], 'b')
    end
    daspect([1 1 1])

end %function plot_local_surface()
