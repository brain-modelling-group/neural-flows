function  [singularity_classification_list] =  singularity3d_classify(nullflow_points3d, mvel_obj)
% 1) calculates jacobian for each critical point, and then 
% 2) classify type of critical point. 
% ARGUMENTS:
%          nullflow_points3d        -- a struct of size [1 x no. timepoints]
%                                -- .xyz_idx [no. of singularities x 1] -- linear indices 
%                                            [no. of singularities x 3] -- subscripts
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
singularity_classification_list = cell(size(nullflow_points3d));
tpts = size(nullflow_points3d, 2);

% Load options structure
options = mvel_obj.options;
grid_size = options.flow_calculation.grid_size;

% Check if we stored linear indices or subscripts 
if size(nullflow_points3d(1).xyz_idx, 2) < 2
    for tt=1:tpts
        xyz_subs = switch_index_mode(nullflow_points3d(tt).xyz_idx, 'subscript', grid_size);
        nullflow_points3d(tt).xyz_idx = xyz_subs;
    end    
    
end

hx = mvel_obj.hx; 
hy = mvel_obj.hy; 
hz = mvel_obj.hz; 


for tt=1:tpts % parallizable stuff but the classification runs very fast

       % Check if we have critical points. There are 'frames' for which
       % nothing was detected, we should not attempt to calculate jacobian.
       if isempty(nullflow_points3d(tt).xyz_idx)
           singularity_labels = {'empty'};
           singularity_classification_list{tt} = singularity_labels;
           continue
       end
       
       % Create temp variables with partial load of a matfile. 
       ux = mvel_obj.ux(:, :, :, tt);
       uy = mvel_obj.uy(:, :, :, tt);
       uz = mvel_obj.uz(:, :, :, tt);
       
       num_critical_points = size(nullflow_points3d(tt).xyz_idx, 1);
       singularity_labels  = cell(num_critical_points, 1);

       for ss=1:num_critical_points
           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = nullflow_points3d(tt).xyz_idx(ss, :);
           % Move points a little
           %point = rectify_boundary_points(point, grid_size);
           % Flag points at the boundary
           boundary_vec = detect_boundary_points(point_idx, grid_size);               
                            
           if ~isempty(boundary_vec)
                singularity_labels{ss} = 'boundary';
            continue
           end
           
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_calculate_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels{ss} = singularity3d_classify_critical_points(J3D);
       end

       singularity_classification_list{tt} = singularity_labels;
end

end % singularity3d_classify_singularities()

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
