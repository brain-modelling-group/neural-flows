function fig_handles = plot3d_singularity_temporal_occupancy(params)

obj_singularity = load_iomat_singularity(params);
% TODO: configiure graphics property to handle paper units so we can plot
% stuff and give figure sizes
cmap = s3d_get_colours('critical-points');
num_base_sngs = size(obj_singularity, 'tracking_3d_matrix', 1);
total_frames = size(obj_singularity, 'tracking_3d_matrix', 3);

% Load data to plot
nodal_singularity_summary = obj_singularity.nodal_singularity_summary;

fig_handles = plot_spheres();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting functions %%%%%%%%%%%%%%%%%%%%%%%
    function fig_handles = plot_spheres()
         
        color_a = [0 0 0];
        fig_handles = cell(num_base_sngs, 1);
        for kk=1:num_base_sngs
            data = nodal_singularity_summary.occupancy_partial(kk, :) / total_frames; 
            color_c = cmap(kk, :);
            color_b = color_c/2;
            color_map = interpolated_colourmap(color_a, color_b, color_c, 64);
            sizedata = data;
            sizedata(sizedata > 0) = 4;
            sizedata(sizedata == 0)= 1;
            min_val = 0.0;
            max_val = max(data)*100;
            [fig_handles{kk}] = plot_sphereanim(data*100, obj_singularity.locs, 1, [min_val max_val], color_map, 'handle', sizedata);
            fig_handles{kk}.Children(2).Visible = 'off';
        end 
    end % function plot_spheres()
   
end % function plot3d_singularity_local_occupancy()
