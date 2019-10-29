% This script plots a 3D scatter plot of singularities
% but it projectcs the points to the 3 orthogonal planes


% Load some graphics accesories
load('convex_hull_bh_lh_rh_513parc_free_boundary_projections')

figure_handle = figure;
ax = subplot(1,1,1);
hold(ax, 'on')

% Initialise indices and more
tt = 1;
xcoord = -115;
ycoord =  150;
zcoord = -55;

% XY projection
plot3(x(fb_bh.xy), y(fb_bh.xy), zcoord.*ones(size(fb_bh.xy)), 'k')
plot3(x(fb_lh.xy), y(fb_lh.xy), zcoord.*ones(size(fb_lh.xy)), 'color', [0.65 0.65 0.65], 'linestyle', '--')
plot3(x(fb_rh.xy), y(fb_rh.xy), zcoord.*ones(size(fb_rh.xy)), 'color', [0.65 0.65 0.65], 'linestyle', '--')

% ZX projection
plot3(x(fb_bh.zx), ycoord.*ones(size(fb_bh.zx)), z(fb_bh.zx), 'k')
plot3(x(fb_lh.zx), ycoord.*ones(size(fb_lh.zx)), z(fb_lh.zx), 'color', [0.65 0.65 0.65], 'linestyle', '--')
plot3(x(fb_rh.zx), ycoord.*ones(size(fb_rh.zx)), z(fb_rh.zx), 'color', [0.65 0.65 0.65], 'linestyle', '--')

% ZY projection
plot3(xcoord.*ones(size(fb_bh.zy)), y(fb_bh.zy), z(fb_bh.zy), 'k')
plot3(xcoord.*ones(size(fb_lh.zy)), y(fb_lh.zy), z(fb_lh.zy), 'color', [0.65 0.65 0.65], 'linestyle', '--')
plot3(xcoord.*ones(size(fb_rh.zy)), y(fb_rh.zy), z(fb_rh.zy), 'color', [0.65 0.65 0.65], 'linestyle', '--')

%% Plot projection of surfaces
% sxy = xy_boundary;
% szy = zy_boundary(2);
% szx = zx_boundary(2);
% 
% xdim = 1;
% ydim = 2;
% zdim = 3;
% 
% % Push them toward one plane
% sxy.vertices(:, zdim) = zcoord;
% szy.vertices(:, xdim) = xcoord;
% szx.vertices(:, ydim) = ycoord;
% 
% scaling_factor = 1;
% trisurf(sxy.faces, scaling_factor*sxy.vertices(:,xdim), ...
%                    scaling_factor*sxy.vertices(:,ydim), ...
%                    scaling_factor*sxy.vertices(:,zdim),...
%                        'EdgeColor', 'k', 'FaceColor', 'k', 'marker', '.');
% 
% 
% trisurf(szy.faces, scaling_factor*szy.vertices(:,xdim), ...
%                    scaling_factor*szy.vertices(:,ydim), ...
%                    scaling_factor*szy.vertices(:,zdim),...
%                        'EdgeColor', 'k', 'FaceColor', 'k', 'marker', '.');
%                    
% 
% trisurf(szx.faces, scaling_factor*szx.vertices(:,xdim), ...
%                    scaling_factor*szx.vertices(:,ydim), ...
%                    scaling_factor*szx.vertices(:,zdim),...
%                        'EdgeColor', 'k', 'FaceColor', 'k', 'marker', '.');
% 
%                    
% szy = zy_boundary(1);
% szx = zx_boundary(1);
% szy.vertices(:, xdim) = xcoord;
% szx.vertices(:, ydim) = ycoord;
% 
% trisurf(szy.faces, scaling_factor*szy.vertices(:,xdim), ...
%                    scaling_factor*szy.vertices(:,ydim), ...
%                    scaling_factor*szy.vertices(:,zdim),...
%                        'EdgeColor', [0.5 0.5 0.5], 'FaceColor', [0.5 0.5 0.5], 'marker', '.');
%                    
% 
% trisurf(szx.faces, scaling_factor*szx.vertices(:,xdim), ...
%                    scaling_factor*szx.vertices(:,ydim), ...
%                    scaling_factor*szx.vertices(:,zdim),...
%                        'EdgeColor', [0.5 0.5 0.5], 'FaceColor', [0.5 0.5 0.5], 'marker', '.');
                   
grid(ax, 'on')
ax.GridAlpha = 0.15;
ax.GridLineStyle = '--';
view(ax, [50, 37])
ax.XLabel.String = 'X [mm]';
ax.YLabel.String = 'Y [mm]';
ax.ZLabel.String = 'Z [mm]';


cmap = s3d_get_colours('all');
cmap(:, 4) = []; 

% singularity to numeric labels
singularity_list_num = s3d_str2num_label(mfile_sing.singularity_classification_list);

load('convex_hull_lh_513parc.mat')
patch(ax, 'Faces', boundary_lh.faces, 'Vertices', boundary_lh.vertices, 'FaceAlpha', 0.1, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'EdgeAlpha', 0.1)

  


%%

dot_radius = 142;
alpha_value = 0.5;
this_singularity = 2;
%%

for tt=3000:3150
       %cidx = sum(color_map(tt).colormap(:, 1:3),2); 
       %idx = find(cidx == 1);
       null_points_3d = mfile_sing.null_points_3d(1, tt);
       idx = find(singularity_list_num{tt} == this_singularity);
       
       if ~isempty(idx)
     
       
       pxy_handle = scatter3(ax,  null_points_3d.x(idx), ...
                                  null_points_3d.y(idx), ...
                                  zcoord*ones(length(idx), 1), dot_radius, cmap(this_singularity*ones(length(idx), 1), :), 'filled', ...
                                  'Markerfacealpha', alpha_value);
       
       pzy_handle = scatter3(ax, xcoord*ones(length(idx), 1), ...
                                 null_points_3d.y(idx), ...
                                 null_points_3d.z(idx), ...
                                 dot_radius,cmap(this_singularity*ones(length(idx), 1), :), 'filled', ...
                                 'Markerfacealpha', alpha_value);
       pzx_handle = scatter3(ax,  null_points_3d.x(idx), ...
                                  ycoord*ones(length(idx), 1), ...
                                  null_points_3d.z(idx), ... 
                                  dot_radius, cmap(this_singularity*ones(length(idx), 1), :), 'filled', ...
                          'Markerfacealpha', alpha_value);
                      
       %pxyz_handle = scatter3(ax, X(xyz_idx(tt).xyz_idx(idx)), ...
       %                           Y(xyz_idx(tt).xyz_idx(idx)), ...
       %                           Z(xyz_idx(tt).xyz_idx(idx)), dot_radius, color_map(tt).colormap(idx, 1:3), 'filled', ...
       %                           'Markerfacealpha', alpha_value);
       drawnow
       end
       
end
   %drawnow


%% Build legend
% h(this_singularity) = plot(NaN,NaN,'o', ... 
%                          'markerfacecolor', cmap(this_singularity, 1:3), ...
%                          'markeredgecolor', cmap(this_singularity, 1:3), ...
%                          'markersize', 14);

%legend(h([1 2]), singularity_list{[1 2]})

%lh = findobj(figure_handle,'Type','Legend');
%lh.Location = 'northwest';
%lh.EdgeColor = 'none';
