function classification_cell = singularity3d_classify_serial(nullflow_points3d, params)
% ARGUMENTS: XXXX: Document
%           
%    
% OUTPUT
%
% AUTHOR:   
%     Paula Sanz-Leon
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

    % Load flows data - nonwritable
    obj_flows = load_iomat_flows(params);
    % Get important parameters
    tpts = params.flows.data.shape.t;
    grid_size = [params.flows.data.shape.y, params.flows.data.shape.x, params.flows.data.shape.z]; 
    hx = params.flows.data.hx; 
    hy = params.flows.data.hy; 
    hz = params.flows.data.hz; 

    % Calculate jacobian and classify singularities
    classification_cell = cell(size(nullflow_points3d));
  for tt=1:tpts % parallizable stuff but the classification runs very fast if the detection threshold is stringent

         % Check if we have critical points. There are 'frames' for which
         % nothing was detected, we should not attempt to calculate jacobian.
         if isempty(nullflow_points3d(tt).locs.linear_idx)
             singularity_labels = {'empty'};
             singularity_classification_list{tt} = singularity_labels;
             continue
         end
         
         % Create temp variables with partial load of a matfile. 
         ux = obj_flows.ux(:, :, :, tt);
         uy = obj_flows.uy(:, :, :, tt);
         uz = obj_flows.uz(:, :, :, tt);
         
         num_critical_points = size(nullflow_points3d(tt).locs.subscripts, 1);
         singularity_labels  = cell(num_critical_points, 1);

         for this_cp=1:num_critical_points
             % Check if any subscript is on the boundary of the grid. 
             % This will cause a problem in the jacobian calculation. 
             point_idx = nullflow_points3d(tt).locs.subscripts(this_cp, :);
             
             % Flag points at the boundary
             boundary_point = detect_boundary_points(point_idx, grid_size);               
                              
             if boundary_point
                  singularity_labels{this_cp} = 'boundary';
              continue
             end
             
             % Calculate the Jacobian at each critical point 
             [J3D] = singularity3d_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
             singularity_labels{this_cp} = singularity3d_classify_critical_points(J3D);
         end

         singularity_classification_list{tt} = singularity_labels;
  end

end  % function singularity3d_classify_serial()

function boundary_point = detect_boundary_points(point_idx, grid_size)
% This function only detects points on the faces of the grid.
% It does not handle an irregular domain.

    xdim=2;
    ydim=1;
    zdim=3;
    
    bv_x = (points_idx(xdim) == 1 | points_idx(xdim) == grid_size(xdim));
    bv_y = (points_idx(ydim) == 1 | points_idx(ydim) == grid_size(ydim));
    bv_z = (points_idx(zdim) == 1 | points_idx(zdim) == grid_size(zdim));
    bv = bv_x + bv_y + bv_z;
    
    boundary_point = bool(bv); % 0 if point is not on the boundary, 1 if it is

end % function boundary_point
