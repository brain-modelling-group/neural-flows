function plot3d_pathlines(obj_streams)

node_locs = obj_streams.locs;
locs = obj_streams.initial_seeding_locs;
pathlines = obj_streams.pathlines;
these_locs_idx = 1:4:length(pathlines);

% Start locations
fig_handle = figure('Name', 'neural-flows-pathlines');

[ax, ~] = tight_subplot(1, 3);

ax(1).Parent = fig_handle; 
ax(2).Parent = fig_handle; 
ax(3).Parent = fig_handle; 

for kk=1:3
    hold(ax(kk), 'on')
    %ax(kk).DataAspectRatio = [1 1 1];
    plot3(ax(kk), locs(these_locs_idx, 1), locs(these_locs_idx, 2), locs(these_locs_idx, 3), 'ro', 'markeredgecolor', 'r', 'markerfacecolor', 'r', 'markersize', 4.2)
    scatter3(ax(kk), node_locs(:, 1), node_locs(:, 2), node_locs(:, 3), 100, [0.5 0.5 0.5], 'filled', 'markeredgecolor', 'none', 'markerfacealpha', 0.2)
    axis(ax(kk), 'off')
end

    for ii=1:4:length(pathlines)
       for kk=1:3
           plot3(ax(kk), squeeze(pathlines{ii}(:, 1)), ...
                 squeeze(pathlines{ii}(:, 2)), ...
                 squeeze(pathlines{ii}(:, 3)), 'color', [0 0 0 0.5], 'linewidth', 0.5);
           plot3(ax(kk), squeeze(pathlines{ii}(end, 1)), ...
                  squeeze(pathlines{ii}(end, 2)), ...
                  squeeze(pathlines{ii}(end, 3)), 'bo', 'markeredgecolor', 'b', 'markerfacecolor', 'b', 'markersize', 4.2);
       end
    end
 
ax(1).View = [0 90];
ax(1).DataAspectRatio = [1 1 1];
ax(2).View = [0  0];
ax(2).DataAspectRatio = [1 1 1];
ax(3).View = [90 0];
ax(3).DataAspectRatio = [1 1 1];

end % function plot3d_pathlines()
