% This script plots a 3D scatter plot of singularities
% but it projectcs the points to the 3 orthogonal planes


% Load some graphics accesories
load('convex_hull_lh_513parc_projections.mat')

figure_handle = figure;
ax = subplot(1,1,1);
hold(ax, 'on')

% Initialise indices and more
tt = 1;
xcoord = -115;
ycoord =  150;
zcoord = -55;


% Plot projection of surfaces
sxy = xy_boundary;
szy = zy_boundary(2);
szx = zx_boundary(2);

xdim = 1;
ydim = 2;
zdim = 3;

% Push them toward one plane
sxy.vertices(:, zdim) = zcoord;
szy.vertices(:, xdim) = xcoord;
szx.vertices(:, ydim) = ycoord;

scaling_factor = 1;
trisurf(sxy.faces, scaling_factor*sxy.vertices(:,xdim), ...
                   scaling_factor*sxy.vertices(:,ydim), ...
                   scaling_factor*sxy.vertices(:,zdim),...
                       'EdgeColor', 'k', 'FaceColor', 'k', 'marker', '.');


trisurf(szy.faces, scaling_factor*szy.vertices(:,xdim), ...
                   scaling_factor*szy.vertices(:,ydim), ...
                   scaling_factor*szy.vertices(:,zdim),...
                       'EdgeColor', 'k', 'FaceColor', 'k', 'marker', '.');
                   

trisurf(szx.faces, scaling_factor*szx.vertices(:,xdim), ...
                   scaling_factor*szx.vertices(:,ydim), ...
                   scaling_factor*szx.vertices(:,zdim),...
                       'EdgeColor', 'k', 'FaceColor', 'k', 'marker', '.');

                   
szy = zy_boundary(1);
szx = zx_boundary(1);
szy.vertices(:, xdim) = xcoord;
szx.vertices(:, ydim) = ycoord;

trisurf(szy.faces, scaling_factor*szy.vertices(:,xdim), ...
                   scaling_factor*szy.vertices(:,ydim), ...
                   scaling_factor*szy.vertices(:,zdim),...
                       'EdgeColor', [0.5 0.5 0.5], 'FaceColor', [0.5 0.5 0.5], 'marker', '.');
                   

trisurf(szx.faces, scaling_factor*szx.vertices(:,xdim), ...
                   scaling_factor*szx.vertices(:,ydim), ...
                   scaling_factor*szx.vertices(:,zdim),...
                       'EdgeColor', [0.5 0.5 0.5], 'FaceColor', [0.5 0.5 0.5], 'marker', '.');
                   
grid(ax, 'on')
ax.GridAlpha = 0.15;
ax.GridLineStyle = '--';

view(ax, [50, 37])
ax.XLabel.String = 'X [mm]';
ax.YLabel.String = 'Y [mm]';
ax.ZLabel.String = 'Z [mm]';



num_sing = cellfun(@length, singularity_cell);
for tt=1:length(num_sing)
    for ss=1:num_sing(tt)
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_cell{tt}{ss});
    
    end
end

load('convex_hull_lh_513parc.mat')
patch(ax, 'Faces', boundary_lh.faces, 'Vertices', boundary_lh.vertices, 'FaceAlpha', 0.1, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'EdgeAlpha', 0.1)

% Get colours                
for ii=1:length(singularity_list)
  [~, cmap(ii, :)] = map_str2int(singularity_list{ii});
end



dot_radius = 142;
alpha_value = 0.25;
this_singularity = 1;
for tt=1:999
   if ~isempty(xyz_idx(tt).xyz_idx)
       %cidx = sum(color_map(tt).colormap(:, 1:3),2); 
       %idx = find(cidx == 1);
       
       idx = find(label(tt).label == this_singularity);
       
       if ~isempty(idx)
       %p3_handle.XData = X(xyz_idx(tt).xyz_idx(idx));
       %p3_handle.YData = Y(xyz_idx(tt).xyz_idx(idx));
       %p3_handle.ZData = Z(xyz_idx(tt).xyz_idx(idx));
       %p3_handle.CData = color_map(tt).colormap(idx, 1:3);
       
       pxy_handle = scatter3(ax,  X(xyz_idx(tt).xyz_idx(idx)), ...
                                  Y(xyz_idx(tt).xyz_idx(idx)), ...
                                  zcoord*ones(length(xyz_idx(tt).xyz_idx(idx)), 1), dot_radius, color_map(tt).colormap(idx, 1:3), 'filled', ...
                          'Markerfacealpha', alpha_value);
       
       pzy_handle = scatter3(ax, xcoord*ones(length(xyz_idx(tt).xyz_idx(idx)), 1), ...
                                 Y(xyz_idx(tt).xyz_idx(idx)), ...
                                 Z(xyz_idx(tt).xyz_idx(idx)), dot_radius, color_map(tt).colormap(idx, 1:3), 'filled', ...
                          'Markerfacealpha', alpha_value);
       pzx_handle = scatter3(ax,  X(xyz_idx(tt).xyz_idx(idx)), ...
                                  ycoord*ones(length(xyz_idx(tt).xyz_idx(idx)), 1), ...
                                  Z(xyz_idx(tt).xyz_idx(idx)), dot_radius, color_map(tt).colormap(idx, 1:3), 'filled', ...
                          'Markerfacealpha', alpha_value);
       %pxyz_handle = scatter3(ax, X(xyz_idx(tt).xyz_idx(idx)), ...
       %                           Y(xyz_idx(tt).xyz_idx(idx)), ...
       %                           Z(xyz_idx(tt).xyz_idx(idx)), dot_radius, color_map(tt).colormap(idx, 1:3), 'filled', ...
       %                   'Markerfacealpha', alpha_value);

       end
   end
   %drawnow
end

% Build legend
h(this_singularity) = plot(NaN,NaN,'o', ... 
                          'markerfacecolor', cmap(this_singularity, 1:3), ...
                          'markeredgecolor', cmap(this_singularity, 1:3), ...
                          'markersize', 14);

legend(h(this_singularity), singularity_list{this_singularity})

lh = findobj(figure_handle,'Type','Legend');
lh.Location = 'northwest';
lh.EdgeColor = 'none';
