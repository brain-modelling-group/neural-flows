function fig_handle = plotmov_flows(params)	
% params: structure with all the parameters for neural-flows
% Paula Sanz-Leon 2020

% Load file handles
obj_flows = load_iomat_flows(params);
uxyz = obj_flows.uxyz;
uxyz_n = obj_flows.uxyz_n;

% Load info we need for visualisation
xyz_lims = obj_flows.xyz_lims; 
num_frames = params.flows.data.shape.t;

% Create figure
fig_handle = figure('Name', 'nflows-the-flows-movie');

% Create axes
ax_handle = subplot(1, 1, 1,'Parent', fig_handle);
ax_handle.DataAspectRatio = [1 1 1];
% Set axes props
ax_handle.XLim = [xyz_lims{1}(1), xyz_lims{1}(2)];
ax_handle.YLim = [xyz_lims{2}(1), xyz_lims{2}(2)];
ax_handle.ZLim = [xyz_lims{3}(1), xyz_lims{3}(2)];
ax_handle.XLabel.String = "X";
ax_handle.YLabel.String = "Y";
ax_handle.ZLabel.String = "Z";
ax_handle.Position = [0.1300    0.1100    0.7750    0.8150];
ax_handle.View = [90 0];
colormap(inferno)
set(ax_handle, 'XLimMode', 'manual', 'YLimMode', 'manual', 'ZLimMode', 'manual');
ax_handle.Visible = 'off';

%%
fname = generate_temp_filename("p3_quiver3d-movie", 3);
vid_obj = VideoWriter([char(fname), '.avi']);
vid_obj.FrameRate = 10; 
open(vid_obj);

for tt=1:1:num_frames
    ax_handle.View = [90 0];

    [F,V,C] = quiver3Dpatch(obj_flows.locs(:,1),obj_flows.locs(:, 2), obj_flows.locs(:, 3), ...
                            uxyz(:, 1, tt), uxyz(:, 2, tt), uxyz(:, 3, tt), ...
                            uxyz_n(:, tt), [15 16]); 
    hp=patch('faces',F,'vertices',V,'cdata',C,'edgecolor','none','facecolor','flat');
    ax_handle.Position = [0.1300    0.1100    0.7750    0.8150];
    pause(0.05)
    axis off
    writeVideo(vid_obj, getframe(ax_handle));
    cla(ax_handle)
end
% Close file
close(vid_obj);

end
