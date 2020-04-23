function classification_cell = singularity3d_classify_serial(nullflow_points3d, tpts, obj_flows)
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
           boundary_vec = detect_boundary_points(point_idx, grid_size);               
                            
           if ~isempty(boundary_vec)
                singularity_labels{this_cp} = 'boundary';
            continue
           end
           
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels{this_cp} = singularity3d_classify_critical_points(J3D);
       end

       singularity_classification_list{tt} = singularity_labels;
end

end % singularity3d_classify()

function boundary_vec = detect_boundary_points(point_idx, grid_size)
% This function only detects points on the faces of the grid.
% It does not handle an irregular domain.

    xdim=2;
    ydim=1;
    zdim=3;
    boundary_vec = [intersect(point_idx, 1), ...
                    intersect(point_idx(xdim), grid_size(xdim)), ...
                    intersect(point_idx(ydim), grid_size(ydim)), ...
                    intersect(point_idx(zdim), grid_size(zdim))];

end % function singularity3d_classify_serial()
