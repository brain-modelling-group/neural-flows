function butterfly_brain(mfile_surf)
% this function plots a brain as a butterfly
% only for visualisation purposes

% input: a matfile object where the velocity components are saved


% Get size without loading data into memory
%tpts = size(mfile_surf, 'isosurfs', 2);

%
color_x = 'a412ff';
color_y = '6dff12';
color_z = 'ff5d12';

color_x = hex2rgb(color_x);
color_y = hex2rgb(color_y);
color_z = hex2rgb(color_z);


figure_butterfly = figure;
ax = subplot(1,1,1);
ax.XLim = [-70 0];
ax.YLim = [-100 60];
ax.ZLim = [-40 80];

hold(ax, 'on')

% Plot first frame and then update

this_tpt = 1;
temp_struct = mfile_surf.result(1, this_tpt);

EdgeAlphaValue = 0.05;
FaceAlphaValue = 0.1;


patch_handle_x = patch(ax, 'Faces', temp_struct.faces_x, 'Vertices', temp_struct.vertices_x/factor, ....
                           'FaceAlpha', FaceAlphaValue,'FaceColor', color_x,  ...
                           'EdgeAlpha', EdgeAlphaValue, 'EdgeColor', color_x);

patch_handle_y = patch(ax, 'Faces', temp_struct.faces_y, 'Vertices', temp_struct.vertices_y/factor, ....
                           'FaceAlpha', FaceAlphaValue,'FaceColor', color_y,  ...
                           'EdgeAlpha', EdgeAlphaValue, 'EdgeColor', color_y);
    
patch_handle_z = patch(ax, 'Faces', temp_struct.faces_z, 'Vertices', temp_struct.vertices_z/factor, ....
                           'FaceAlpha', FaceAlphaValue, 'FaceColor', color_z,  ...
                           'EdgeAlpha', EdgeAlphaValue, 'EdgeColor', color_z);
                       

for this_tpt = 1:tpts
    temp_struct = mfile_surf.result(1, this_tpt);
    set(patch_handle_x, 'Faces', temp_struct.faces_x, 'Vertices', temp_struct.vertices_x)
    set(patch_handle_y, 'Faces', temp_struct.faces_y, 'Vertices', temp_struct.vertices_y)
    set(patch_handle_z, 'Faces', temp_struct.faces_z, 'Vertices', temp_struct.vertices_z)
    export_fig(sprintf( './frame_%03d.png', this_tpt ), '-r150', '-nocrop', figure_butterfly)
end

alpha_value = linspace(0.01, 0.1, tpts);

ax.ZLim = [-0.4 0.8];
ax.View = [90 0];

factor = 100;
spacing = 0.05;
for this_tpt = 10:10:tpts
    temp_struct = mfile_surf.result(1, this_tpt);
    vertices_x = temp_struct.vertices_x/factor;
    vertices_x(:, 2) = vertices_x(:, 2) + spacing*this_tpt;
    vertices_y = temp_struct.vertices_y/factor;
    vertices_y(:, 2) = vertices_y(:, 2) + spacing*this_tpt;
    vertices_z = temp_struct.vertices_z/factor;
    vertices_z(:, 2) = vertices_z(:, 2) + spacing*this_tpt;
    
    patch(ax, 'Faces', temp_struct.faces_x, 'Vertices', vertices_x, ....
                           'FaceAlpha', alpha_value(this_tpt), 'FaceColor', color_x,  ...
                           'EdgeAlpha', alpha_value(this_tpt), 'EdgeColor', color_x);
    patch(ax, 'Faces', temp_struct.faces_y, 'Vertices', vertices_y, ....
                           'FaceAlpha', alpha_value(this_tpt), 'FaceColor', color_y,  ...
                           'EdgeAlpha', alpha_value(this_tpt), 'EdgeColor', color_y);
    patch(ax, 'Faces', temp_struct.faces_z, 'Vertices', vertices_z, ....
                           'FaceAlpha', alpha_value(this_tpt), 'FaceColor', color_z,  ...
                           'EdgeAlpha', alpha_value(this_tpt), 'EdgeColor', color_z);
    drawnow()
    %export_fig(sprintf( './frame_%03d.png', this_tpt ), '-r150', '-nocrop', figure_butterfly)
end
% load locs
load('/home/paula/Work/Code/Networks/patchflow/test-data/lh_mbw_bnm_chaosc_c_0-6_delay_1ms.mat')
clear data

[~, bdy] = get_boundary_info(locs, X(:), Y(:), Z(:));
locs = locs / factor;
locs(:, 2) = locs(:, 2) + spacing*this_tpt;

patch(ax, 'Faces', bdy, 'Vertices', locs, 'FaceAlpha', 0.7, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'EdgeAlpha', 0.1)

end % function butterfly brain