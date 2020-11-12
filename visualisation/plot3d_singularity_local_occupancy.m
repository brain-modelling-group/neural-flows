function plot3d_singularity_local_occupancy(params)

obj_singularity = load_iomat_singularity(params);
% TODO: configiure graphics property to handle paper units so we can plot
% stuff and give figure sizes
cmap = s3d_get_colours('critical-points');
num_base_sngs = size(obj_singularity, 'tracking_3d_matrix', 1);
total_frames = size(obj_singularity, 'tracking_3d_matrix', 3);

% Load data to plot
data = sum(obj_singularity.tracking_3d_matrix, 3);

plot_spheres();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting functions %%%%%%%%%%%%%%%%%%%%%%%
    function plot_spheres()
         
        color_a = [0 0 0];
        for kk=1:num_base_sngs
            color_c = cmap(kk, :);
            color_b = color_c/2;
            color_map = interpolated_colourmap(color_a, color_b, color_c, 64);
            sizedata = data(kk, :);
            sizedata(sizedata > 0) = 4;
            sizedata(sizedata == 0)= 1;
            plot_sphereanim(data(kk, :)/total_frames, obj_singularity.locs, 1, [0 0.35], color_map, 'workspace', sizedata)
        end 
    end % function plot_spheres()
   
end % function plot1d_singularity_spheres()
