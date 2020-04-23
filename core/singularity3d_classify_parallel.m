function classification_cell = singularity3d_classify_parallel(nullflow_points3d, params)
% ARGUMENTS:
%           locs: locations of known data
%           data: scatter data known at locs of size tpts x nodes
%           X, Y Z: -- grid points to get interpolation out, must be 3D
%                      arrays
%           mask -- indices of points within the brain's convex hull boundary. 
%                    Same size as X, Y, or Z.
%    
% OUTPUT:
%       mfile_interp_obj: matfile handle to the file with the interpolated
%                         data.
%       mfile_interp_sentinel: OnCleanUp object. If keep_interp_data is
%                              true, then this variable is an empty array.
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

    % TODO: CHECK THIS STILL WORKS
    null_points_cell = struct2cell(nullflow_points3d);
    % Get only relevant data -- subscripts
    null_points_cell = squeeze(null_points_cell(1, 1, :));

    fprintf('\n%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started classification of singularities.'))

    parfor tt=1:tpts 
           % Check if we have critical points. There are 'frames' for which
           % nothing was detected, we should not attempt to calculate jacobian.
           nullflow_points3d_subscripts = null_points_cell{tt};

           if isempty(nullflow_points3d_subscripts)
               singularity_labels = {'empty'};
               %msings_obj.classification_cell(1, tt) = {singularity_labels};
               classification_cell{1, tt} = singularity_labels;

               continue
           end
           
           num_critical_points = size(nullflow_points3d_subscripts, 1);
           singularity_labels  = cell(num_critical_points, 1);

           [boundary_vec_idx, innies_vec_idx] = detect_boundary_points(nullflow_points3d_subscripts, grid_size);

           % Create temp variables with partial load of a matfile. 
           ux = obj_flows.ux(:, :, :, tt);
           uy = obj_flows.uy(:, :, :, tt);
           uz = obj_flows.uz(:, :, :, tt);
           
           temp_labels = classify_points(subscripts, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz);
           singularity_labels(innies_vec_idx) = temp_labels;
           singularity_labels(boundary_vec_idx) = {'boundary'};
           
           %msings_obj.classification_cell(1, tt) = {singularity_labels};
           classification_cell{1, tt} = singularity_labels;


    end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished classification of singularities.'))

end % singularity3d_classify_parallel()

   
function label = classify_points(nullflow_points3d_xyz_idx, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz)
    num_points = length(in_bdy_vec_idx);
     parfor idx=1:num_points
         tmp = classification_step(idx, nullflow_points3d_xyz_idx, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz)
         label{idx} = tmp;
     end

end % function classify_points()

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

function temp_data = classification_step(idx, nullflow_points3d_subscripts, innies_vec_idx, ux, uy, uz, hx, hy, hz)

           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = nullflow_points3d_subscripts(innies_vec_idx(idx), :);
 
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           temp_data = singularity3d_classify_critical_points(J3D);
end % function classification_step()
