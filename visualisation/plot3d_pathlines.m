function plot3d_pathlines(obj_streams)


locs = obj_streams.initial_seeding_locs;
pathlines = obj_streams.pathlines;

% Start locations
fig_handle = figure('Name', 'neural-flows-pathlines');

[ax, ~] = tight_subplot(1, 3);

ax(1).Parent = fig_handle; 
ax(2).Parent = fig_handle; 
ax(3).Parent = fig_handle; 

for kk=1:3
    hold(ax(kk), 'on')
    %ax(kk).DataAspectRatio = [1 1 1];
    plot3(ax(kk), locs(:, 1), locs(:, 2), locs(:, 3), 'r.', 'markersize', 4.2)
    axis off

end

    for ii=1:length(pathlines)
       for kk=1:3
           plot3(ax(kk), squeeze(pathlines{ii}(:, 1)), ...
                 squeeze(pathlines{ii}(:, 2)), ...
                 squeeze(pathlines{ii}(:, 3)), 'color', [0.5 0.5 0.5 0.1], 'linewidth', 0.5);
           plot3(ax(kk), squeeze(pathlines{ii}(end, 1)), ...
                  squeeze(pathlines{ii}(end, 2)), ...
                  squeeze(pathlines{ii}(end, 3)), '.', 'markeredgecolor', [0 0.0 1.0], 'markersize', 4.2);
       end
    end
 
ax(1).View = [0 90];
ax(2).View = [0  0];
ax(3).View = [90 0];
end % function plot3d_pathlines()
