function plot3d_nodal_streamlines(obj_streams)


locs = obj_streams.seeding_locs;


% Start locations
plot3(locs(:, 1), locs(:, 2), locs(:, 3), 'k.')
hold on

for tt = 1:10
	temp_frame = obj_streams.streamlines(1, tt);
    streams = temp_frame.paths;

    for ii=1:length(streams)
       plot3(squeeze(streams{ii}(:, 1)), ...
             squeeze(streams{ii}(:, 2)), ...
             squeeze(streams{ii}(:, 3)), 'color', [0.5 0.5 0.5 0.1]);
        plot3(squeeze(streams{ii}(end, 1)), ...
              squeeze(streams{ii}(end, 2)), ...
              squeeze(streams{ii}(end, 3)), '.', 'markeredgecolor', [1 0.0 0.0], 'markersize', 0.042);
    end
end 
end % function plot3d_nodal_streamlines()