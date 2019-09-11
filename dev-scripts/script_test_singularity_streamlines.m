X = mfile_vel.X;
Y = mfile_vel.Y;
Z = mfile_vel.Z;

% Get colors for each singularity

num_sing = cellfun(@length, singularity_classification);

% get colors
for tt=5:200
    
    for ss=1:num_sing(tt)
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_classification{tt}{ss});
    
    end
end


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


for tt=this_frame+1:200
    
    for ss=1:num_sing(tt)
        
        if strcmp(singularity_classification{tt}{ss}, 'nan')
                       streamline(ax, X, Y, Z,...
                       mfile_vel.ux(:, :, :, tt), ...
                       mfile_vel.uy(:, :, :, tt), ...
                       mfile_vel.uz(:, :, :, tt),...
                       X(xyz_idx(tt).xyz_idx(ss)), ...
                       Y(xyz_idx(tt).xyz_idx(ss)),...
                       Z(xyz_idx(tt).xyz_idx(ss)))
        else
            p3_handle = scatter3(ax, X(xyz_idx(tt).xyz_idx(ss)), ...
             Y(xyz_idx(tt).xyz_idx(ss)), ...
             Z(xyz_idx(tt).xyz_idx(ss)), 100, color_map(tt).colormap(ss, 1:3), 'filled');
            h = streamline(ax, X, Y, Z,...
                       mfile_vel.ux(:, :, :, tt), ...
                       mfile_vel.uy(:, :, :, tt), ...
                       mfile_vel.uz(:, :, :, tt),...
                       X(xyz_idx(tt).xyz_idx(ss))+randn(1), ...
                       Y(xyz_idx(tt).xyz_idx(ss))+randn(1),...
                       Z(xyz_idx(tt).xyz_idx(ss))+randn(1), 10000);
            h.Color = 'k';
        end    
            
        
    
    end
    
 drawnow
 pause(0.1)   
end