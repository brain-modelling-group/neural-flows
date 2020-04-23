function singularity3d_classify(params)
% 1) calculates jacobian for each critical point, and then 
% 2) classify type of critical point. 
% ARGUMENTS:
%          nullflow_points3d     -- a struct of size [1 x no. timepoints]
%                                -- locs.linear_idx [no. of singularities x 1] -- linear indices 
%                                -- locs.subscripts [no. of singularities x 3] -- subscripts
%          mvel_obj              -- a MatFile handle pointing to the flows/velocity
%                            fields. Needed for the calculation of the
%                            jacobian matrix. Or a matlab structure with
%                            the same fields as the matfile produced by the
%                            code.
% OUTPUT:
%         singularity_classification  --  a cell array of size [1 x no. timepoints]
%                                         where each element is a cell of size
%                                         [no. of singularities]. The cells
%                                         have human readable strings with
%                                         the type of singularity detected. 
% REQUIRES:
%          switch_index_mode()
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
% USAGE:
%{
    
%}
% NOTE: as the timeseries get longer, we can in principle parallelise this
% function.

    % Load flows data - nonwritable
    obj_flows = load_iomat_flows(params);

    % Load singularity data- writable
    obj_singularity = load_iomat_singularity(params);

    tpts = params.flows.data.shape.t;
    grid_size = [params.flows.data.shape.y, params.flows.data.shape.x, params.flows.data.shape.z]; 


    singularity_classification_list = cell(size(nullflow_points3d));

    % Check if we stored linear indices or subscripts 
    if ~isfield(nullflow_points3d(1).locs, 'subscripts')
        for tt=1:tpts
            nullflow_points3d(tt).locs.subscripts = switch_index_mode(nullflow_points3d(tt).xyz_idx, 'subscript', grid_size);;
        end    
        
    end

    hx = params.flows.data.hx; 
    hy = params.flows.data.hy; 
    hz = params.flows.data.hz; 


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
obj_singularity.classification_list = singularity_classification_list;

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

end % function detect_boundary_points()
