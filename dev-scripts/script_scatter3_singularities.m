X = mfile_vel.X;
Y = mfile_vel.Y;
Z = mfile_vel.Z;

% Get colors for each singularity

num_sing = cellfun(@length, singularity_class);

% get colors
for tt=1:999
    %if num_sing(tt) == 0
    %    singularity_classification{tt}{ss}
    for ss=1:num_sing(tt)
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_class{tt}{ss});
    
    end
end

%%
figure_handle = figure;
ax = subplot(1,1,1);
hold(ax, 'on')
this_frame = 5;
size_marker = 100;


locs = COG(1:256, :);
[~, bdy] = get_boundary_info(locs, X(:), Y(:), Z(:));
patch(ax, 'Faces', bdy, 'Vertices', locs, 'FaceAlpha', 0.1, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'EdgeAlpha', 0.1)

alpha_val = linspace(0, 1, 200);
axis equal 

tt = 1;
p3_handle = scatter3(ax, X(xyz_idx(tt).xyz_idx), ...
                            Y(xyz_idx(tt).xyz_idx), ...
                            Z(xyz_idx(tt).xyz_idx), 50, [0 0 0], 'filled', ...
                            'Markerfacealpha', 0.7);

for tt=1:999
   if ~isempty(xyz_idx(tt).xyz_idx)
       cidx = sum(color_map(tt).colormap(:, 1:3),2); 
       idx = find(cidx ~= 0);
       
       if ~isempty(idx)
       p3_handle.XData = X(xyz_idx(tt).xyz_idx(idx));
       p3_handle.YData = Y(xyz_idx(tt).xyz_idx(idx));
       p3_handle.ZData = Z(xyz_idx(tt).xyz_idx(idx));
       p3_handle.CData = color_map(tt).colormap(idx, 1:3);
       

       end
   end
 ax.XLim = [min(X(:)) max(X(:))];
 ax.YLim = [min(Y(:)) max(Y(:))];
 ax.ZLim = [min(Z(:)) max(Z(:))];
 drawnow
 pause(0.01)
 %export_fig(sprintf( './frame_%03d.png', tt ), '-r150', '-nocrop', figure_handle)
end