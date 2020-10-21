function plot3d_pathlines_coloured(obj_streams)


locs = obj_streams.initial_seeding_locs;


% Start locations
plot3(locs(:, 1), locs(:, 2), locs(:, 3), 'k.')
fig_handle = figure('Name', 'neural-flows-pathlines');
ax = subplot(1,1,1, 'Parent', fig_handle); 
ax.Color = [0 0 0];
hold(ax, 'on')
ax.CLim = [0, 1];
cmap = magma(256);
ax.Colormap = cmap;
c_ref = linspace(0,1,256);
pathlines = obj_streams.pathlines;

    for ii=1:length(pathlines)
       x = squeeze(pathlines{ii}(:, 1));
       y = squeeze(pathlines{ii}(:, 2));
       z = squeeze(pathlines{ii}(:, 3));
       if length(x) < 600
           continue
       end
       t = linspace(0, 1, length(x));
       c = imquantize(t, c_ref);
       line_color = cmap(c, :);
       line_color = reshape(line_color, length(x), 1, 3);
       line_colormap = cat(2, line_color, line_color);
       color_line3(x, y, z, line_colormap, '.');
    end
end % function plot3d_pathlines()