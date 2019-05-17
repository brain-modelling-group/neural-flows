X = mfile_vel.X;
Y = mfile_vel.Y;
Z = mfile_vel.Z;

% Get colors for each singularity

num_sing = cellfun(@length, singularity_classification);

% get colors
for tt=1:200
    
    for ss=1:num_sing(tt)
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_classification{tt}{ss});
    
    end
end

%%
figure_handle = figure;
ax = subplot(1,1,1);
hold(ax, 'on')
this_frame = 5;
size_marker = 100;
ax.XLim = [min(X(:)) max(X(:))];
ax.YLim = [min(Y(:)) max(Y(:))];
ax.ZLim = [min(Z(:)) max(Z(:))];

locs = COG(1:256, :);
[~, bdy] = get_boundary_info(locs, X(:), Y(:), Z(:));
patch(ax, 'Faces', bdy, 'Vertices', locs, 'FaceAlpha', 0.1, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'EdgeAlpha', 0.1)

alpha_val = linspace(0, 1, 200);


for tt=1:200
   if ~isempty(xyz_idx(tt).xyz_idx)
       p3_handle = scatter3(ax, X(xyz_idx(tt).xyz_idx), ...
                            Y(xyz_idx(tt).xyz_idx), ...
                            Z(xyz_idx(tt).xyz_idx), 10, color_map(tt).colormap(:, 1:3), 'filled');
   end
 %drawnow
 pause(0.1)   
end