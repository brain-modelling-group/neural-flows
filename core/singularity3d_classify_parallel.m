function [msings_obj] = singularity3d_classify_parallel(msings_obj, mflow_obj)
% This is a wrapper function for Matlab's ScatteredInterpolant. We can interpolate
% each frame of a 4D array independtly using parfor and save the interpolated data for 
% later use with optical flow. Then, just delete the interpolated data
% or offer to keep it, because this step is really a time piggy.
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



% Calculate jacobian and classify singularities

null_points_3d =  msings_obj.null_points_3d; 
singularity_classification_list = cell(size(null_points_3d));
msings_obj.singularity_classification_list = cell(size(null_points_3d)); 


tpts = size(null_points_3d, 2);

% Load options structure
options   = mflow_obj.options;
grid_size = options.flows.grid_size;

% Check if we stored linear indices or subscripts 
if size(null_points_3d(1).xyz_idx, 2) < 2
    fprintf('\n %s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started converting lindear indices into subscripts.'))

    for tt=1:tpts
        xyz_subs = switch_index_mode(null_points_3d(tt).xyz_idx, 'subscript', grid_size);
        null_points_3d(tt).xyz_idx = xyz_subs;
    end    
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished converting lindear indices into subscripts.'))
 
end

hx = options.interpolation.hx; 
hy = options.interpolation.hy; 
hz = options.interpolation.hz; 
grid_size = options.interpolation.grid_size;

null_points_cell = struct2cell(null_points_3d);
% Get only relevant data -- subscripts
null_points_cell = squeeze(null_points_cell(1, 1, :));
fprintf('\n %s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started classification of singularities.'))

parfor tt=1:tpts 
       % Check if we have critical points. There are 'frames' for which
       % nothing was detected, we should not attempt to calculate jacobian.
       null_points_3d_xyz_idx = null_points_cell{tt};

       if isempty(null_points_3d_xyz_idx)
           singularity_labels = {'empty'};
           %msings_obj.singularity_classification_list(1, tt) = {singularity_labels};
           singularity_classification_list{1, tt} = singularity_labels;

           continue
       end
       
       num_critical_points = size(null_points_3d_xyz_idx, 1);
       singularity_labels  = cell(num_critical_points, 1);

       [boundary_vec_idx, in_bdy_vec_idx] = detect_boundary_points(null_points_3d_xyz_idx, grid_size);

       % Create temp variables with partial load of a matfile. 
       ux = mflow_obj.ux(:, :, :, tt);
       uy = mflow_obj.uy(:, :, :, tt);
       uz = mflow_obj.uz(:, :, :, tt);
       
       temp_labels = classify_points(null_points_3d_xyz_idx, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz);
       singularity_labels(in_bdy_vec_idx) = temp_labels;
       singularity_labels(boundary_vec_idx) = {'boundary'};
       
       %msings_obj.singularity_classification_list(1, tt) = {singularity_labels};
       singularity_classification_list{1, tt} = singularity_labels;


end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished classification of singularities.'))
fprintf('\n %s \n', strcat('neural-flows:: ', mfilename, '::Info:: Saving classification list to file.'))

msings_obj.singularity_classification_list = singularity_classification_list;

end % singularity3d_classify_singularities_parallel()

   
function label = classify_points(null_points_3d_xyz_idx, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz)
    num_points = length(in_bdy_vec_idx);
     parfor idx=1:num_points
         tmp = classification_step(idx, null_points_3d_xyz_idx, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz)
         label{idx} = tmp;
     end

end % function data3d_interpolate_parallel()

function [boundary_vec_idx, in_bdy_vec_idx] = detect_boundary_points(points_idx, grid_size)
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
    in_bdy_vec_idx = find(bv ==0);

end % function detect_boundary_points()


function temp_data = classification_step(idx, null_points_3d_xyz_idx, in_bdy_vec_idx, ux, uy, uz, hx, hy, hz)

           % Check if any subscript is on the boundary of the grid. 
           % This will cause a problem in the jacobian calculation. 
           point_idx = null_points_3d_xyz_idx(in_bdy_vec_idx(idx), :);
 
           % Calculate the Jacobian at each critical point 
           [J3D] = singularity3d_calculate_jacobian(point_idx, ux, uy, uz, hx, hy, hz);
           temp_data = singularity3d_classify_critical_points(J3D);
end
