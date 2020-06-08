function plot3d_nodal_streamlines(obj_streams)


locs = obj_streams.seed_locs;


% Start locations
plot3(locs(:, 1), locs(:, 2), locs(:, 3), 'k.')
hold on

for tt = 1:200
	streams = obj_streams.streamlines(1, tt).streams;

    for ii=1:length(streams);
       plot3(squeeze(streams{ii}(:, 1)), ...
             squeeze(streams{ii}(:, 2)), ...
             squeeze(streams{ii}(:, 3)), 'color', [0.5 0.5 0.5 0.1]);
       % plot3(squeeze(streams{ii}(end, 1)), ...
       %       squeeze(streams{ii}(end, 2)), ...
       %       squeeze(streams{ii}(end, 3)), 'r.');
    end
end 
end % function plot3d_nodal_streamlines()