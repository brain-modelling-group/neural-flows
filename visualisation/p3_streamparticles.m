function ax_handle = p3_streamparticles(fig_handle, verts, xyz_lims, display_modality)

if nargin < 4
    display_modality = "workspace";
end

ax_handle = subplot(1, 1, 1,'Parent', fig_handle);
ax_handle.DataAspectRatio = [1 1 1];
sl = streamline(verts);

set(sl,'LineWidth',1.5);
set(sl,'Color',[0.5 0.5 0.5 0.5]);
%set(sl,'Visible','off');
%interpolated vertices
%iverts = interpstreamspeed(X, Y, Z, mfile_vel.ux(:, :, :, tt), ...
%                                    mfile_vel.uy(:, :, :, tt), ....
%                                    mfile_vel.uz(:, :, :, tt), verts,.5);
%
%axis tight; view(30,30); 
%haxes.SortMethod = 'ChildOrder';
%camproj perspective; box on
%camva(44); camlookat; camdolly(0,0,.4, 'f');
%h = line;
ax_handle.XLim = [xyz_lims{1}(1), xyz_lims{1}(2)];
ax_handle.YLim = [xyz_lims{2}(1), xyz_lims{2}(2)];
ax_handle.ZLim = [xyz_lims{3}(1), xyz_lims{3}(2)];
ax_handle.XLabel.String = "X";
ax_handle.YLabel.String = "Y";

switch display_modality
    case {"workspace", "desktop"}
         streamparticles(ax_handle, verts, 2, 'animate', 4, 'ParticleAlignment', 'on', ...
	                     'MarkerfaceColor', 'red', 'MarkerSize', 0.1);
    case {"movie"}
        set(sl,'Color',[0.5 0.5 0.5 1.0]); % looks weird in the movie otherwise
        fname = generate_temp_filename("p3_particles", 3);
        vid_obj = VideoWriter([char(fname), '.avi']);
        open(vid_obj);
        set(ax_handle,'DrawMode','fast')
        [~, M]=streamparticlesMod(ax_handle, verts, 2, 'animate', 4, 'ParticleAlignment', 'on', ...
	                             'MarkerfaceColor', 'red', 'MarkerSize', 2);
        %movie(M, 2, 100)   % play the movie. Do not close the figure window before playing the movie
        writeVideo(vid_obj, M);
        close(vid_obj)
end

end % function p3_streamparticles