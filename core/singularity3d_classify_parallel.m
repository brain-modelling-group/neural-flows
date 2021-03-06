function [classification_cell_str, classification_cell_num, singularity_count] = singularity3d_classify_parallel(nullflow_points3d, params)
% ARGUMENTS: XXXX Document
%      .null_points_3d        -- a struct of size [1 x no. timepoints]
%                                                -- .xyz_idx [no. of singularities x 1] -- linear indices 
%                                                            [no. of singularities x 3] -- subscripts      
%    
% OUTPUT:
%    % classification_cell  --  a cell array of size [1 x no. timepoints]
%                                                          where each element is a cell of size
%                                                          [no. of singularities]. The cells
%                                                          have human readable strings with
%                                                          the type of singularity detected.    
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
    %TODO: ENABLE: grid_size = params.flows.data.shape.grid; 
    hx = params.flows.data.hx; 
    hy = params.flows.data.hy; 
    hz = params.flows.data.hz; 

    % Calculate jacobian and classify singularities
    classification_cell_str = cell(size(nullflow_points3d));
    classification_cell_num = cell(size(nullflow_points3d));
    base_singularity_num_list = cellfun(@(x) s3d_get_numlabel(x), s3d_get_base_singularity_list());
    singularity_count = zeros(length(classification_cell_num), length(base_singularity_num_list));

    null_points_cell = struct2cell(nullflow_points3d);
    % Get only relevant data -- subscripts
    null_points_cell = squeeze(null_points_cell(1, 1, :));
    
    % Convert string labels to numeric labels based on our mapping
    str2num_cellfun = @(y) cellfun(@(x) s3d_get_numlabel(x), y); 

    fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started classification of singularities.'))
    parfor tt=1:tpts 
           % Check if we have critical points. There are 'frames' for which
           % nothing was detected, we should not attempt to calculate jacobian.
           nullflow_points3d_frame = null_points_cell{tt};

           if isempty(nullflow_points3d_frame.subscripts)
               singularity_labels = {'empty'};
               %obj_singularity.classification_cell(1, tt) = {singularity_labels};
               classification_cell{1, tt} = singularity_labels;
               continue
           end
           
           num_critical_points = size(nullflow_points3d_frame, 1);
           singularity_labels  = cell(num_critical_points, 1);

           [boundary_vec_idx, innies_vec_idx] = detect_boundary_points(nullflow_points3d_frame.subscripts, grid_size);

           % Create temp variables with partial load of a matfile. 
           ux = obj_flows.ux(:, :, :, tt);
           uy = obj_flows.uy(:, :, :, tt);
           uz = obj_flows.uz(:, :, :, tt);
           tmp = classify_points(nullflow_points3d_frame.subscripts, innies_vec_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels(innies_vec_idx) = tmp;
           singularity_labels(boundary_vec_idx) = {'boundary'};
           
           %obj_singularity.classification_cell(1, tt) = {singularity_labels};
           classification_cell_str{1, tt} = singularity_labels;
           % Get numeric labels
           classification_cell_num{1, tt} = str2num_cellfun(singularity_labels);
           % Count singularities
           singularity_count(tt, :) = singularity3d_count(classification_cell_num{1, tt}, base_singularity_num_list);
    end
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished classification of singularities.'))
end % singularity3d_classify_parallel()

function [boundary_vec_idx, innies_vec_idx] = detect_boundary_points(points_idx, grid_size)
% This function only detects points on the faces of the grid.
% It does not handle an irregular domain.

    xdim=2;
    ydim=1;
    zdim=3;
    
    bv_x = (points_idx(:, xdim) == 1 | points_idx(:, xdim) == grid_size(xdim));
    bv_y = (points_idx(:, ydim) == 1 | points_idx(:, ydim) == grid_size(ydim));
    bv_z = (points_idx(:, zdim) == 1 | points_idx(:, zdim) == grid_size(zdim));
    bv = bv_x + bv_y + bv_z;
    
    boundary_vec_idx = find(bv > 0);
    innies_vec_idx = find(bv ==0);

end % function detect_boundary_points()

function label = classify_points(nullflow_points3d_subscripts, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz)
    num_points = length(in_bdy_vec_idx);
     parfor idx=1:num_points
         tmp = classification_step(idx, nullflow_points3d_subscripts, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz);
         label{idx} = tmp;
     end

end % function classify_points()

function temp_data = classification_step(idx, nullflow_points3d_subscripts, innies_vec_idx, ux, uy, uz, hx, hy, hz)

           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = nullflow_points3d_subscripts(innies_vec_idx(idx), :);
 
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           temp_data = singularity3d_classify_critical_points(J3D);
end % function classification_step()
