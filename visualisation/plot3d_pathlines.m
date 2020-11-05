function plot3d_pathlines(obj_streams)


locs = obj_streams.initial_seeding_locs;


% Start locations
plot3(locs(:, 1), locs(:, 2), locs(:, 3), 'k.')
hold on


	pathlines = obj_streams.pathlines;

    for ii=1:length(pathlines)
       plot3(squeeze(pathlines{ii}(:, 1)), ...
             squeeze(pathlines{ii}(:, 2)), ...
             squeeze(pathlines{ii}(:, 3)), 'color', [0.5 0.5 0.5 0.2], 'linewidth', 2);
        plot3(squeeze(pathlines{ii}(end, 1)), ...
              squeeze(pathlines{ii}(end, 2)), ...
              squeeze(pathlines{ii}(end, 3)), '.', 'markeredgecolor', [1 0.0 0.0], 'markersize', 0.042);
    end
 
end % function plot3d_pathlines()