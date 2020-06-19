function ax_handle = p3_streamparticles(fig_handle, verts, xyz_lims)


ax_handle = subplot(1, 1, 1,'Parent', fig_handle)

sl = streamline(verts);

set(sl,'LineWidth',1);
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

streamparticles(ax_handle, verts, 42, 'animate', Inf, 'ParticleAlignment', 'on', 'MarkerfaceColor', 'blue');

displaynow 

end